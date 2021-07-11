/*
 * harbour-watchlist - Sailfish OS Version
 * Copyright © 2021 Andreas Wüst (andreas.wuest.freelancer@gmail.com)
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
#include "ingdibanews.h"
#include "../constants.h"
#include "../ingdibautils.h"

#include <QDebug>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QUrl>

IngDibaNews::IngDibaNews(QNetworkAccessManager *manager, QObject *parent)
    : QObject(parent) {
    qDebug() << "Initializing IngDiba News...";
    this->manager = manager;
}

IngDibaNews::~IngDibaNews() {
    qDebug() << "Shutting down IngDiba News...";
}

void IngDibaNews::searchStockNews(const QString &isin) {
    QNetworkReply *reply = executeGetRequest(QUrl(QString(ING_DIBA_NEWS).arg(isin).arg(1))); // pageNumber 1

    connect(reply,
            SIGNAL(error(QNetworkReply::NetworkError)),
            this,
            SLOT(handleRequestError(QNetworkReply::NetworkError)));
    connect(reply, SIGNAL(finished()), this, SLOT(handleSearchStockNews()));
}

QNetworkReply *IngDibaNews::executeGetRequest(const QUrl &url) {
    qDebug() << "IngDibaNews::executeGetRequest " << url;
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::UserAgentHeader, USER_AGENT);

    return manager->get(request);
}

void IngDibaNews::handleSearchStockNews() {
    qDebug() << "IngDibaNews::handleSearchStockNews";
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    reply->deleteLater();
    if (reply->error() != QNetworkReply::NoError) {
        return;
    }

    emit searchNewsResultAvailable(processSearchResult(reply->readAll()));
}

QString IngDibaNews::processSearchResult(QByteArray searchReply) {
    QJsonArray resultArray;
    QJsonDocument jsonDocument = QJsonDocument::fromJson(searchReply);
    if (jsonDocument.isObject()) {
        QJsonObject rootObject = jsonDocument.object();
        QJsonArray newsItemArray = rootObject["items"].toArray();

        foreach (const QJsonValue &newsEntry, newsItemArray) {
            QJsonObject newsObject = newsEntry.toObject();
            QString headline = newsObject["headline"].toString();
            QString content = newsObject["content"].toString();
            QString source = newsObject["id"].toString();
            QString url = QString::null;                          // not supported
            QString dateTime = newsObject["newsDate"].toString(); // TODO parsen in richtiges datetime

            QJsonObject resultObject;

            resultObject.insert("headline", headline);
            resultObject.insert("content", filterContent(content));
            resultObject.insert("source", source);
            resultObject.insert("url", url);
            resultObject.insert("dateTime", IngDibaUtils::convertTimestampToLocalTimestamp(dateTime, QTimeZone::systemTimeZone()).toString());

            // TODO evtl. html tags filtern -  Link-Tags entfernen <a>

            resultArray.push_back(resultObject);
        }
    }

    // response objects
    QJsonObject resultObject;
    resultObject.insert("newsItems", resultArray);

    QJsonDocument resultDocument;
    resultDocument.setObject(resultObject);

    QString dataToString(resultDocument.toJson());

    return dataToString;
}

QString IngDibaNews::filterContent(QString &content) {
    QRegExp allTagsRegExp("<[^>]*>");
    QRegExp whiteSpaces("[\\s\\n]+");
    content.replace(allTagsRegExp, " ");
    content.replace(whiteSpaces, " ");
    return content;
}

void IngDibaNews::handleRequestError(QNetworkReply::NetworkError error) {
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    qWarning() << "IngDibaNews::handleRequestError:" << static_cast<int>(error) << reply->errorString()
               << reply->readAll();

    emit requestError("Return code: " + QString::number(static_cast<int>(error)) + " - " + reply->errorString());
}
