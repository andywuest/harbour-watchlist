/*
 * harbour-watchlist - Sailfish OS Version
 * Copyright © 2020 Andreas Wüst (andreas.wuest.freelancer@gmail.com)
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
#include "onvistanews.h"

#include <QDebug>
#include <QUrl>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>

OnvistaNews::OnvistaNews(QNetworkAccessManager *manager, QObject *parent) : QObject(parent) {
    qDebug() << "Initializing Onvista News...";
    this->manager = manager;
}

OnvistaNews::~OnvistaNews() {
    qDebug() << "Shutting down Onvista News...";
}

void OnvistaNews::searchStockNews(const QString &isin) {
    QNetworkReply *reply = executeGetRequest(QUrl(QString(API_NEWS_SEARCH).arg(isin).arg(15)));

    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(handleRequestError(QNetworkReply::NetworkError)));
    connect(reply, SIGNAL(finished()), this, SLOT(handleSearchStockNews()));
}

QNetworkReply *OnvistaNews::executeGetRequest(const QUrl &url) {
    qDebug() << "OnvistaNews::executeGetRequest " << url;
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::UserAgentHeader, NEWS_USER_AGENT);

    return manager->get(request);
}

void OnvistaNews::handleSearchStockNews() {
    qDebug() << "OnvistaNews::handleSearchStockNews";
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    reply->deleteLater();
    if (reply->error() != QNetworkReply::NoError) {
        return;
    }

    QJsonArray resultArray;

    QByteArray searchReply = reply->readAll();
    QJsonDocument jsonDocument = QJsonDocument::fromJson(searchReply);
    if (jsonDocument.isObject()) {
        QJsonObject rootObject = jsonDocument.object();
        QJsonObject onvistaObject = rootObject["onvista"].toObject();
        QJsonObject newsListObject = onvistaObject["NewsList"].toObject();
        QJsonArray newsArray = newsListObject["news"].toArray();

        foreach (const QJsonValue & newsEntry, newsArray) {
            QJsonObject newsObject = newsEntry.toObject();
            QString headline = newsObject["headline"].toString();
            QString content = newsObject["content"].toString();
            QString source = newsObject["source"].toString();
            QString url = newsObject["url"].toString();
            QString dateTime = newsObject["datetime"].toString();

            QJsonObject resultObject;

            resultObject.insert("headline", headline);
            resultObject.insert("content", filterContent(content));
            resultObject.insert("source", source);
            resultObject.insert("url", url);
            resultObject.insert("dateTime", dateTime);

            // TODO for godmode trader data - we have to remove at least the contained image
            // TODO alles ab Ebenfalls interessant sollte entfernt werden
            // Link-Tags entfernen <a>

            resultArray.push_back(resultObject);
        }
    }

    // response objects
    QJsonObject resultObject;
    resultObject.insert("newsItems", resultArray);

    QJsonDocument resultDocument;
    resultDocument.setObject(resultObject);

    QString dataToString(resultDocument.toJson());

    emit searchNewsResultAvailable(dataToString);
}

QString OnvistaNews::filterContent(QString &content) {
    QRegExp allTagsRegExp("<[^>]*>");
    QRegExp godmodeTraderTableRegExp("<table>(.*)</table>");
    content.replace(godmodeTraderTableRegExp, " ");
    content.replace(allTagsRegExp, " ");
    content.replace("&amp;", "&");

    return content;
}

void OnvistaNews::handleRequestError(QNetworkReply::NetworkError error) {
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    qWarning() << "OnvistaNews::handleRequestError:" << static_cast<int>(error) << reply->errorString() << reply->readAll();

    emit requestError("Return code: " + QString::number(static_cast<int>(error)) + " - " + reply->errorString());
}
