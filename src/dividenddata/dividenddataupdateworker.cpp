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
#include <QDebug>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QUrl>

#include <QQmlApplicationEngine>
#include <QSqlError>
#include <QUrlQuery>

#include "../constants.h"
#include "dividenddataupdateworker.h"

DividendDataUpdateWorker::DividendDataUpdateWorker(QObject *parent)
    : QThread(parent) {
    qDebug() << "Initializing Dividend Data Update worker";
    database = QSqlDatabase::addDatabase("QSQLITE");

    if (database.databaseName().isEmpty()) {
        QQmlApplicationEngine engine;
        qDebug() << "path : " << engine.offlineStoragePath();

        // https://lists.qt-project.org/pipermail/interest/2016-March/021316.html
        QString path(engine.offlineStoragePath() + "/Databases/"
                     + QCryptographicHash::hash(APP_NAME, QCryptographicHash::Md5).toHex() + ".sqlite");

        qDebug() << "path : " << path;

        database.setDatabaseName(path);

        qDebug() << "is valid : " << database.isValid();
        qDebug() << "open error : " << database.isOpenError();
    }
}

DividendDataUpdateWorker::~DividendDataUpdateWorker() {
    qDebug() << "DividendDataUpdateWorker::destroy";
    database.close();
}

void DividendDataUpdateWorker::setParameters(const QJsonDocument &jsonDocument,
                                             const QMap<QString, QVariant> exchangeRateMap) {
    this->jsonDocument = jsonDocument;
    this->exchangeRateMap = exchangeRateMap;
}

void DividendDataUpdateWorker::performUpdate() {
    int rows = 0;
    if (jsonDocument.isObject()) {
        qDebug() << "removing old dividend data";
        executeQuery(QString("DELETE FROM dividends"), QMap<QString, QVariant>());

        QJsonObject rootObject = jsonDocument.object();
        QJsonArray dividendsArray = rootObject["dividends"].toArray();

        const QString convertedEuroCurrency = convertCurrency("EUR");
        const QString query = QString(
                                  "INSERT INTO dividends(exDate, exDateInteger, payDate, payDateInteger, isin, wkn, "
                                  "symbol, amount, currency, convertedAmount, convertedAmountCurrency) ")
                              + QString("VALUES (:exDate, :exDateInteger, :payDate, :payDateInteger, :isin, :wkn, "
                                        ":symbol, :amount, :currency, :convertedAmount, :convertedAmountCurrency)");

        const QTime defaultTime = QTime(0, 0);

        foreach (const QJsonValue &dividendsEntry, dividendsArray) {
            QJsonObject dividendsObject = dividendsEntry.toObject();

            // add new ones
            QDate payDate = QDate::fromString(dividendsObject["payDate"].toString(), "yyyy-MM-dd");
            QDate exDate = QDate::fromString(dividendsObject["exDate"].toString(), "yyyy-MM-dd");
            QDateTime payDateTime = QDateTime(payDate, defaultTime, Qt::LocalTime);
            QDateTime exDateTime = QDateTime(exDate, defaultTime, Qt::LocalTime);

            double amount = dividendsObject["amount"].toDouble();
            QString currency = dividendsObject["currency"].toString();
            double convertedAmount = calculateConvertedAmount(amount, currency);

            QMap<QString, QVariant> dataMap;
            dataMap.insert(":exDate", exDate.toString("dd.MM.yyyy"));
            dataMap.insert(":exDate", exDate.toString("dd.MM.yyyy"));
            dataMap.insert(":payDate", payDate.toString("dd.MM.yyyy"));
            dataMap.insert(":exDateInteger", exDateTime.toMSecsSinceEpoch());
            dataMap.insert(":payDateInteger", payDateTime.toMSecsSinceEpoch());
            dataMap.insert(":isin", dividendsObject["isin"].toString());
            dataMap.insert(":wkn", dividendsObject["wkn"].toString());
            dataMap.insert(":symbol", dividendsObject["symbol"].toString());
            dataMap.insert(":amount", amount);
            dataMap.insert(":currency", convertCurrency(currency));
            dataMap.insert(":convertedAmount", convertedAmount);
            dataMap.insert(":convertedAmountCurrency", convertedEuroCurrency);

            executeQuery(query, dataMap);
            rows++;
        }
    }

    if (database.open()) {
        database.commit();
        database.close();
    }

    emit updateCompleted(rows);
}

// TODO testcase
double DividendDataUpdateWorker::calculateConvertedAmount(double amount, QString currency) {
    if (QString("EUR").compare(currency) == 0) {
        qDebug() << " EURO amount " << amount << ", currency : " << currency;
        return amount;
    }
    bool hasConvertedAmount = this->exchangeRateMap.contains(currency);
    qDebug() << " EURO amount calculated " << (amount / this->exchangeRateMap[currency].toDouble())
             << ", currency : " << currency;
    return (hasConvertedAmount ? (amount / this->exchangeRateMap[currency].toDouble()) : 0.0);
}

void DividendDataUpdateWorker::executeQuery(const QString &queryString, const QMap<QString, QVariant> &dataMap) {
    if (database.open()) {
        QSqlQuery query;
        query.prepare(queryString);

        if (!dataMap.empty()) {
            const QList<QString> keys = dataMap.keys();
            for (auto &key : keys) {
                query.bindValue(key, dataMap.value(key));
            }
        }

        if (!query.exec()) {
            qDebug() << "SQL Statement Error" << query.lastError();
        } else {
            database.commit();
        }
        database.commit();

        // qDebug() << " executed query : " << queryString;
    } else {
        qDebug() << "Cant open DB";
    }
}

QString DividendDataUpdateWorker::convertCurrency(const QString &currencyString) {
    if (QString("EUR").compare(currencyString, Qt::CaseInsensitive) == 0) {
        return QString("\u20AC");
    }
    if (QString("USD").compare(currencyString, Qt::CaseInsensitive) == 0) {
        return QString("$");
    }
    if (QString("GBP").compare(currencyString, Qt::CaseInsensitive) == 0) {
        return QString("\u00A3");
    }
    if (QString("JPY").compare(currencyString, Qt::CaseInsensitive) == 0) {
        return QString("\u00A5");
    }
    return currencyString;
}
