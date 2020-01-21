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

void EuroinvestorBackend::searchQuoteForNameSearch(const QString &searchString) {
    qDebug() << "EuroinvestorBackend::searchQuote";
    QNetworkReply *reply = executeGetRequest(QUrl(API_QUOTE + searchString));

    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(handleRequestError(QNetworkReply::NetworkError)));
    connect(reply, SIGNAL(finished()), this, SLOT(handleSearchQuoteForNameFinished()));
}

void EuroinvestorBackend::fetchClosePrices() {
    qDebug() << "EuroinvestorBackend::fetchClosePrices";
    QNetworkReply *reply = executeGetRequest(QUrl(QString(API_CLOSE_PRICES).arg("67800").arg("2019-10-5")));

    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(handleRequestError(QNetworkReply::NetworkError)));
    connect(reply, SIGNAL(finished()), this, SLOT(handleFetchClosePricesFinished()));
}

void EuroinvestorBackend::fetchIntradayPrices(const QString &extRefId) {
    qDebug() << "EuroinvestorBackend::fetchIntradayPrices";
    QNetworkReply *reply = executeGetRequest(QUrl(QString(API_INTRADAY_PRICES).arg(extRefId)));

    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(handleRequestError(QNetworkReply::NetworkError)));
    connect(reply, SIGNAL(finished()), this, SLOT(handleFetchIntradayPricesFinished()));
}

void EuroinvestorBackend::searchQuote(const QString &searchString) {
    qDebug() << "EuroinvestorBackend::searchQuote";
    QNetworkReply *reply = executeGetRequest(QUrl(API_QUOTE + searchString));

    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(handleRequestError(QNetworkReply::NetworkError)));
    connect(reply, SIGNAL(finished()), this, SLOT(handleSearchQuoteFinished()));
}

QNetworkReply *EuroinvestorBackend::executeGetRequest(const QUrl &url) {
    qDebug() << "EuroinvestorBackend::executeGetRequest " << url;
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

    QByteArray searchReply = reply->readAll();
    QJsonDocument jsonDocument = QJsonDocument::fromJson(searchReply);
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

        searchQuoteForNameSearch(quoteQueryIds);

    } else {
        qDebug() << "not a json object !";
    }
}

void EuroinvestorBackend::handleSearchQuoteForNameFinished() {
    qDebug() << "EuroinvestorBackend::handleSearchQuoteForNameFinished";
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    reply->deleteLater();
    if (reply->error() != QNetworkReply::NoError) {
        return;
    }

    emit searchResultAvailable(processQuoteSearchResult(reply->readAll()));
}

void EuroinvestorBackend::handleSearchQuoteFinished() {
    qDebug() << "EuroinvestorBackend::handleSearchQuoteForNameFinished";
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    reply->deleteLater();
    if (reply->error() != QNetworkReply::NoError) {
        return;
    }

    emit quoteResultAvailable(processQuoteSearchResult(reply->readAll()));
}

void EuroinvestorBackend::handleFetchClosePricesFinished() {
    qDebug() << "EuroinvestorBackend::handleFetchClosePricesFinished";
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    reply->deleteLater();
    if (reply->error() != QNetworkReply::NoError) {
        return;
    }

    QString result = QString(reply->readAll());

    qDebug() << "EuroinvestorBackend::handleFetchClosePricesFinished result " << result;

    emit fetchClosePricesAvailable(result);
}

void EuroinvestorBackend::handleFetchIntradayPricesFinished() {
    qDebug() << "EuroinvestorBackend::handleFetchIntradayPricesFinished";
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    reply->deleteLater();
    if (reply->error() != QNetworkReply::NoError) {
        return;
    }

    QByteArray resultByteArray = reply->readAll();
    QString result = QString(resultByteArray);

    qDebug() << "EuroinvestorBackend::handleFetchIntradayPricesFinished result " << result;

    QJsonDocument jsonDocument = QJsonDocument::fromJson(resultByteArray);
    if (!jsonDocument.isArray()) {
        qDebug() << "not a json array!";
    }

    QJsonArray responseArray = jsonDocument.array();
    QJsonDocument resultDocument;
    QJsonArray resultArray;

    double min = -1;
    double max = -1;

    foreach (const QJsonValue & value, responseArray) {
        QJsonObject rootObject = value.toObject();
        QJsonObject resultObject;

        QJsonValue updatedAt = rootObject.value("timestamp");
        QDateTime dateTimeUpdatedAt = QDateTime::fromString(updatedAt.toString(), Qt::ISODate);

        double closeValue = rootObject.value("close").toDouble();

        if (min == -1) {
            min = closeValue;
        } else if (closeValue < min) {
            min = closeValue;
        }
        if (max == -1) {
            max = closeValue;
        } else if (closeValue > max) {
            max = closeValue;
        }

        resultObject.insert("x", dateTimeUpdatedAt.toMSecsSinceEpoch() / 1000);
        resultObject.insert("y", closeValue);

        resultArray.push_back(resultObject);
    }


//    var myObj = {
//      "data": [
//        { "x":0 * d, "y":"40" },
//        { "x":1 * d, "y":"40" },
//        { "x":2 * d, "y":"25" },
//        { "x":3 * d, "y":"75" },
//        { "x":4 * d, "y":"25" },
//        { "x":5 * d, "y":"150" },
//      ]
//     }


    // top / bottom margin for chart - if the difference is too small - rounding makes no sense.
    double roundedMin = (max - min > 1.0) ? floor(min) : min;
    double roundedMax = (max - min > 1.0) ? ceil(max) : max;

    // determine how many fraction digits the y-axis is supposed to display
    int fractionsDigits = 1;
    if (max - min > 10.0) {
        fractionsDigits = 0;
    } else if (max - min < 2) {
        fractionsDigits = 2;
    }

    // resultDocument.setArray(resultArray);
    QJsonObject resultObject;
    resultObject.insert("min", roundedMin);
    resultObject.insert("max", roundedMax);
    resultObject.insert("fractionDigits", fractionsDigits);
    resultObject.insert("data", resultArray);

    resultDocument.setObject(resultObject);

    QString dataToString(resultDocument.toJson());

    emit fetchIntradayPricesAvailable(dataToString);
}

QString EuroinvestorBackend::processQuoteSearchResult(QByteArray searchReply) {
    qDebug() << "EuroinvestorBackend::processQuoteSearchResult";
    QJsonDocument jsonDocument = QJsonDocument::fromJson(searchReply);
    if (!jsonDocument.isArray()) {
        qDebug() << "not a json array!";
    }

    QJsonArray responseArray = jsonDocument.array();
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
        resultObject.insert("changeAbsolute", rootObject.value("change"));
        resultObject.insert("changeRelative", rootObject.value("changeInPercentage"));
        resultObject.insert("high", rootObject.value("high"));
        resultObject.insert("low", rootObject.value("low"));
        resultObject.insert("ask", rootObject.value("ask"));
        resultObject.insert("bid", rootObject.value("bid"));
        resultObject.insert("volume", rootObject.value("volume"));
        resultObject.insert("numberOfStocks", rootObject.value("numberOfStocks"));

        QJsonValue updatedAt = rootObject.value("updatedAt");
        // TODO move date formatting to a separate method
        QDateTime dateTimeUpdatedAt = QDateTime::fromString(updatedAt.toString(), Qt::ISODate);
        QString updateAtString = dateTimeUpdatedAt.toString("yyyy-MM-dd") + " " + dateTimeUpdatedAt.toString("hh:mm:ss");
        resultObject.insert("quoteTimestamp", updateAtString);

        QDateTime dateTimeNow = QDateTime::currentDateTime();
        QString nowString = dateTimeNow.toString("yyyy-MM-dd") + " " + dateTimeNow.toString("hh:mm:ss");
        resultObject.insert("lastChangeTimestamp", nowString);

        resultArray.push_back(resultObject);
    }

    resultDocument.setArray(resultArray);
    QString dataToString(resultDocument.toJson());

    return dataToString;
}
