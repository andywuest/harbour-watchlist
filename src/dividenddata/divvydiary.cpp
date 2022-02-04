/*
 * harbour-watchlist - Sailfish OS Version
 * Copyright © 2022 Andreas Wüst (andreas.wuest.freelancer@gmail.com)
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
#include "divvydiary.h"
#include "../constants.h"

#include <QDebug>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QUrl>

#include <QQmlApplicationEngine>
#include <QSqlError>
#include <QUrlQuery>

DivvyDiary::DivvyDiary(QNetworkAccessManager *manager, QObject *parent)
    : QObject(parent) {
    qDebug() << "Initializing DivvyDiary ...";
    this->manager = manager;

    db = QSqlDatabase::addDatabase("QSQLITE");
}

DivvyDiary::~DivvyDiary() {
    qDebug() << "Shutting down DivvyDiary ...";
}

void DivvyDiary::initializeDatabase() {
    if (db.databaseName().isEmpty()) {
        QQmlApplicationEngine engine;
        qDebug() << "path : " << engine.offlineStoragePath();

        // https://lists.qt-project.org/pipermail/interest/2016-March/021316.html
        QString path(engine.offlineStoragePath() + "/Databases/"
                     + QCryptographicHash::hash("harbour-watchlist", QCryptographicHash::Md5).toHex() + ".sqlite");

        qDebug() << "path : " << path;

        db.setDatabaseName(path);
    }
}

void DivvyDiary::fetchDividendDates() {
    QNetworkReply *reply = executeGetRequest(QUrl(QString(DIVVYDIARY_DIVIDENDS)));

    connect(reply,
            SIGNAL(error(QNetworkReply::NetworkError)),
            this,
            SLOT(handleRequestError(QNetworkReply::NetworkError)));
    connect(reply, SIGNAL(finished()), this, SLOT(handleFetchDividendDates()));
}

QNetworkReply *DivvyDiary::executeGetRequest(const QUrl &url) {
    qDebug() << "DivvyDiary::executeGetRequest " << url;
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::UserAgentHeader, USER_AGENT);

    return manager->get(request);
}

void DivvyDiary::handleFetchDividendDates() {
    qDebug() << "DivvyDiary::handleFetchDividendDates";
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    reply->deleteLater();
    if (reply->error() != QNetworkReply::NoError) {
        return;
    }

    processSearchResult(reply->readAll());
    emit fetchDividendDatesResultAvailable();
}

QString DivvyDiary::processSearchResult(QByteArray searchReply) {
    initializeDatabase();

    QMap<QString, QVariant> emptyMap;
    QString deleteQuery = QString("DELETE FROM dividends");

    executeQuery(deleteQuery, emptyMap);

    QJsonDocument jsonDocument = QJsonDocument::fromJson(searchReply);
    if (jsonDocument.isObject()) {
        QJsonObject rootObject = jsonDocument.object();
        QJsonArray dividendsArray = rootObject["dividends"].toArray();
        rootObject.remove("exchangerates");

        // TODO run in worker
        foreach (const QJsonValue &dividendsEntry, dividendsArray) {
            QJsonObject dividendsObject = dividendsEntry.toObject();

            // add new ones
            QDate payDate = QDate::fromString(dividendsObject["payDate"].toString(), "yyyy-MM-dd");
            QDate exDate = QDate::fromString(dividendsObject["exDate"].toString(), "yyyy-MM-dd");
            QDateTime payDateTime = QDateTime(payDate, QTime(0, 0), Qt::LocalTime);
            QDateTime exDateTime = QDateTime(exDate, QTime(0, 0), Qt::LocalTime);

            QString query = QString("INSERT INTO dividends(exDate, exDateInteger, payDate, payDateInteger, isin, wkn, "
                                    "symbol, amount, currency) ")
                            + QString("VALUES (:exDate, :exDateInteger, :payDate, :payDateInteger, :isin, :wkn, "
                                      ":symbol, :amount, :currency)");

            QMap<QString, QVariant> dataMap;
            dataMap.insert(":exDate", exDate.toString("dd.MM.yyyy"));
            dataMap.insert(":exDate", exDate.toString("dd.MM.yyyy"));
            dataMap.insert(":payDate", payDate.toString("dd.MM.yyyy"));
            dataMap.insert(":exDateInteger", exDateTime.toMSecsSinceEpoch());
            dataMap.insert(":payDateInteger", payDateTime.toMSecsSinceEpoch());
            dataMap.insert(":isin", dividendsObject["isin"].toString());
            dataMap.insert(":wkn", dividendsObject["wkn"].toString());
            dataMap.insert(":symbol", dividendsObject["symbol"].toString());
            dataMap.insert(":amount", dividendsObject["amount"].toDouble());
            dataMap.insert(":currency", dividendsObject["currency"].toString());

            executeQuery(query, dataMap);
        }
    }

    if (db.open()) {
        db.commit();
        db.close();
    }

    QString dataToString(jsonDocument.toJson());

    return dataToString;
}

void DivvyDiary::executeQuery(QString &queryString, QMap<QString, QVariant> dataMap) {
    if (db.open()) {
        QSqlQuery query;
        query.prepare(queryString);

        if (!dataMap.empty()) {
            for (QString &key : dataMap.keys()) {
                query.bindValue(key, dataMap.value(key));
            }
        }

        if (!query.exec()) {
            qDebug() << "SQL Statement Error" << query.lastError();
        } else {
            db.commit();
        }

        db.close();

        // qDebug() << " executed query : " << queryString;
    } else {
        qDebug() << "Cant open DB";
    }
}

void DivvyDiary::handleRequestError(QNetworkReply::NetworkError error) {
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    qWarning() << "DivvyDiary::handleRequestError:" << static_cast<int>(error) << reply->errorString()
               << reply->readAll();

    emit requestError("Return code: " + QString::number(static_cast<int>(error)) + " - " + reply->errorString());
}
