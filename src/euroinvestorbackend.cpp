/*
 * harbour-watchlist - Sailfish OS Version
 * Copyright © 2019 Andreas Wüst (andreas.wuest.freelancer@gmail.com)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
#include "euroinvestorbackend.h"

#include <QDebug>
#include <QFile>
#include <QUrl>
#include <QUrlQuery>
#include <QUuid>
#include <QCryptographicHash>
#include <QStandardPaths>
#include <QJsonObject>
#include <QJsonArray>
#include <QDateTime>
#include <QtDBus/QDBusConnection>
#include <QtDBus/QDBusInterface>

EuroinvestorBackend::EuroinvestorBackend(QNetworkAccessManager *manager, const QString &applicationName, const QString applicationVersion, QObject *parent) : QObject(parent) {
    qDebug() << "Initializing Euroinvestor Backend...";
    this->manager = manager;
    this->applicationName = applicationName;
    this->applicationVersion = applicationVersion;
}

EuroinvestorBackend::~EuroinvestorBackend() {
    qDebug() << "Shutting down Euroinvestor Backend...";
}

void EuroinvestorBackend::searchName(const QString &searchString) {
    qDebug() << "EuroinvestorBackend::searchName";
    QNetworkReply *reply = executeGetRequest(QUrl(API_SEARCH + searchString));

    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(handleRequestError(QNetworkReply::NetworkError)));
    connect(reply, SIGNAL(finished()), this, SLOT(handleSearchNameFinished()));
}

void EuroinvestorBackend::searchQuote(const QString &searchString) {
    qDebug() << "EuroinvestorBackend::searchQuote";
    QNetworkReply *reply = executeGetRequest(QUrl(API_QUOTE + searchString));

    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(handleRequestError(QNetworkReply::NetworkError)));
    connect(reply, SIGNAL(finished()), this, SLOT(handleSearchQuoteFinished()));
}

QNetworkReply *EuroinvestorBackend::executeGetRequest(const QUrl &url) {
    qDebug() << "EuroinvestorBackend::executeGetRequest";
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, MIME_TYPE_JSON);

    return manager->get(request);
}

void EuroinvestorBackend::handleRequestError(QNetworkReply::NetworkError error) {
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    qWarning() << "EuroinvestorBackend::handleRequestError:" << (int)error << reply->errorString() << reply->readAll();

    emit requestError("Return code: " + QString::number((int)error) + " - " + reply->errorString());
}

void EuroinvestorBackend::handleSearchNameFinished() {
    qDebug() << "EuroinvestorBackend::handleSearchNameFinished";
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    reply->deleteLater();
    if (reply->error() != QNetworkReply::NoError) {
        return;
    }

    QByteArray registrationReply = reply->readAll();
    qDebug() << "EuroinvestorBackend::handleSearchNameFinished";
    QJsonDocument jsonDocument = QJsonDocument::fromJson(registrationReply);
    if (jsonDocument.isArray()) {
        QJsonArray responseArray = jsonDocument.array();
        qDebug() << "array size : " << responseArray.size();

        QStringList idList;

        foreach (const QJsonValue & value, responseArray) {
            QJsonObject rootObject = value.toObject();
            QJsonObject sourceObject = rootObject["_source"].toObject();
            idList.append(QString::number(sourceObject.value("id").toInt()));
        }

        QString quoteQueryIds = idList.join(",");

        qDebug() << "EuroinvestorBackend::handleSearchNameFinished - quoteQueryIds : " << quoteQueryIds;

        searchQuote(quoteQueryIds);

    } else {
        qDebug() << "not a json object !";
    }
}

void EuroinvestorBackend::handleSearchQuoteFinished() {
    qDebug() << "EuroinvestorBackend::handleSearchQuoteFinished";
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    reply->deleteLater();
    if (reply->error() != QNetworkReply::NoError) {
        return;
    }

    QByteArray registrationReply = reply->readAll();
    qDebug() << "EuroinvestorBackend::validateRegistrationData";
    QJsonDocument jsonDocument = QJsonDocument::fromJson(registrationReply);
    if (jsonDocument.isArray()) {
        QJsonArray responseArray = jsonDocument.array();
        qDebug() << "array size : " << responseArray.size();

        QJsonDocument resultDocument;
        QJsonArray resultArray;

        foreach (const QJsonValue & value, responseArray) {
            QJsonObject rootObject = value.toObject();
            QJsonObject exchangeObject = rootObject["exchange"].toObject();

            QJsonObject resultObject;
            resultObject.insert("extRefId", rootObject.value("id"));
            resultObject.insert("name", rootObject.value("name"));
            resultObject.insert("currency", rootObject.value("currency"));
            resultObject.insert("price", rootObject.value("last"));
            resultObject.insert("symbol1", rootObject.value("symbol"));
            resultObject.insert("isin", rootObject.value("isin"));
            resultObject.insert("stockMarketName", exchangeObject.value("name"));

            // TODO map the rest

            resultArray.push_back(resultObject);
        }

        resultDocument.setArray(resultArray);
        QString dataToString(resultDocument.toJson());
        emit searchResultAvailable(dataToString);

    } else {
        qDebug() << "not a json object !";
    }
}
