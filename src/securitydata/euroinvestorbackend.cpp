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
#include "chartdatacalculator.h"

#include "../constants.h"

#include <QDateTime>
#include <QDebug>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QUrl>
#include <QUrlQuery>

EuroinvestorBackend::EuroinvestorBackend(QNetworkAccessManager *manager, QObject *parent)
    : AbstractDataBackend(manager, parent) {
    qDebug() << "Initializing Euroinvestor Backend...";
    this->supportedChartTypes = (ChartType::INTRADAY | ChartType::MONTH | ChartType::THREE_MONTHS | ChartType::YEAR
                                 | ChartType::THREE_YEARS);
}

EuroinvestorBackend::~EuroinvestorBackend() {
    qDebug() << "Shutting down Euroinvestor Backend...";
}

void EuroinvestorBackend::searchName(const QString &searchString) {
    qDebug() << "EuroinvestorBackend::searchName";
    QNetworkReply *reply = executeGetRequest(QUrl(EUROINVESTOR_API_SEARCH + searchString));

    connectErrorSlot(reply);
    connect(reply, SIGNAL(finished()), this, SLOT(handleSearchNameFinished()));
}

void EuroinvestorBackend::searchQuoteForNameSearch(const QString &searchString) {
    qDebug() << "EuroinvestorBackend::searchQuoteForNameSearch";
    QNetworkReply *reply = executeGetRequest(QUrl(EUROINVESTOR_API_QUOTE + searchString));

    connectErrorSlot(reply);
    connect(reply, SIGNAL(finished()), this, SLOT(handleSearchQuoteForNameFinished()));
}

void EuroinvestorBackend::fetchPricesForChart(const QString &extRefId, int chartType) {
    qDebug() << "EuroinvestorBackend::fetchClosePrices";

    if (!isChartTypeSupported(chartType)) {
        qDebug() << "EuroinvestorBackend::fetchClosePrices - chart type " << chartType << " not supported!";
        return;
    }

    QString startDateString = getStartDateForChart(chartType).toString("yyyy-MM-dd");

    QNetworkReply *reply;
    if (chartType == ChartType::INTRADAY) {
        reply = executeGetRequest(QUrl(QString(EUROINVESTOR_API_INTRADAY_PRICES).arg(extRefId)));
    } else {
        reply = executeGetRequest(QUrl(QString(EUROINVESTOR_API_CLOSE_PRICES).arg(extRefId, startDateString)));
    }

    // TODO not sure if connecting the error slot makes sense here if we have multiple charts
    // maybe we only connect one chart type
    // connectErrorSlot(reply);
    connect(reply, SIGNAL(finished()), this, SLOT(handleFetchPricesForChartFinished()));

    reply->setProperty("type", chartType);
}

void EuroinvestorBackend::searchQuote(const QString &searchString) {
    qDebug() << "EuroinvestorBackend::searchQuote";
    QNetworkReply *reply = executeGetRequest(QUrl(EUROINVESTOR_API_QUOTE + searchString));

    connectErrorSlot(reply);
    connect(reply, SIGNAL(finished()), this, SLOT(handleSearchQuoteFinished()));
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

        foreach (const QJsonValue &value, responseArray) {
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
    qDebug() << "EuroinvestorBackend::handleSearchQuoteFinished";
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    reply->deleteLater();
    if (reply->error() != QNetworkReply::NoError) {
        return;
    }

    emit quoteResultAvailable(processQuoteSearchResult(reply->readAll()));
}

void EuroinvestorBackend::handleFetchPricesForChartFinished() {
    qDebug() << "EuroinvestorBackend::handleFetchPricesForChartFinished";
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    reply->deleteLater();
    if (reply->error() != QNetworkReply::NoError) {
        return;
    }

    QByteArray resultByteArray = reply->readAll();

    // QString result = QString(resultByteArray);
    // qDebug() << "EuroinvestorBackend::handleFetchPricesForChartFinished result " << result;

    QString jsonResponseString = parsePriceResponse(resultByteArray);

    if (!jsonResponseString.isNull()) {
        emit fetchPricesForChartAvailable(jsonResponseString, reply->property("type").toInt());
    }
}

QString EuroinvestorBackend::parsePriceResponse(QByteArray reply) {
    QJsonDocument jsonDocument = QJsonDocument::fromJson(reply);
    if (!jsonDocument.isArray()) {
        qDebug() << "not a json array!";
        return QString();
    }

    QJsonArray responseArray = jsonDocument.array();
    QJsonDocument resultDocument;
    QJsonArray resultArray;

    ChartDataCalculator chartDataCalculator;

    foreach (const QJsonValue &value, responseArray) {
        QJsonObject rootObject = value.toObject();
        QJsonObject resultObject;

        QJsonValue jsonUpdatedAt = rootObject.value("timestamp");
        //        QDateTime dateTimeUpdatedAt = QDateTime::fromString(jsonUpdatedAt.toString(), Qt::ISODate);

        QDateTime updatedAtLocalTime = convertUTCDateTimeToLocalDateTime(jsonUpdatedAt.toString());

        //        qDebug() << dateTimeUpdatedAt << " - " << updatedAtLocalTime;

        double closeValue = rootObject.value("close").toDouble();

        chartDataCalculator.checkCloseValue(closeValue);

        resultObject.insert("x", updatedAtLocalTime.toMSecsSinceEpoch() / 1000);
        resultObject.insert("y", closeValue);

        resultArray.push_back(resultObject);
    }

    QJsonObject resultObject;
    resultObject.insert("min", chartDataCalculator.getMinValue());
    resultObject.insert("max", chartDataCalculator.getMaxValue());
    resultObject.insert("fractionDigits", chartDataCalculator.getFractionDigits());
    resultObject.insert("data", resultArray);

    resultDocument.setObject(resultObject);

    QString dataToString(resultDocument.toJson());
    return dataToString;
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

    foreach (const QJsonValue &value, responseArray) {
        QJsonObject rootObject = value.toObject();
        QJsonObject exchangeObject = rootObject["exchange"].toObject();

        QJsonObject resultObject;
        resultObject.insert("extRefId", rootObject.value("id"));
        resultObject.insert("name", rootObject.value("name"));
        resultObject.insert("currency", rootObject.value("currency"));
        resultObject.insert("currencySymbol", convertCurrency(rootObject.value("currency").toString()));
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

        QJsonValue jsonUpdatedAt = rootObject.value("updatedAt");
        QDateTime updatedAtLocalTime = convertUTCDateTimeToLocalDateTime(jsonUpdatedAt.toString());
        resultObject.insert("quoteTimestamp", convertToDatabaseDateTimeFormat(updatedAtLocalTime));

        resultObject.insert("lastChangeTimestamp", convertToDatabaseDateTimeFormat(QDateTime::currentDateTime()));

        // not persisted - displayed on the add stock page
        // quote result is the same as the name search
        resultObject.insert("genericText1", exchangeObject.value("name")); // stockMarketName

        resultArray.push_back(resultObject);
    }

    resultDocument.setArray(resultArray);
    QString dataToString(resultDocument.toJson());

    return dataToString;
}

QDateTime EuroinvestorBackend::convertUTCDateTimeToLocalDateTime(const QString &utcDateTimeString) {
    QDateTime utcDateTime = QDateTime::fromString(utcDateTimeString, Qt::ISODate);
    QDateTime localDateTime = QDateTime(utcDateTime.date(), utcDateTime.time(), Qt::UTC).toLocalTime();

    // qDebug() << " converted date from " << utcDateTimeString << " to " << localDateTime;

    return localDateTime;
}

QString EuroinvestorBackend::convertCurrency(const QString &currencyString) {
    if (QString("EUR").compare(currencyString, Qt::CaseInsensitive) == 0) {
        return QString("\u20AC");
    }
    if (QString("USD").compare(currencyString, Qt::CaseInsensitive) == 0) {
        return QString("$");
    }
    return currencyString;
}
