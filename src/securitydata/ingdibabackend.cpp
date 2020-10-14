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
#include "ingdibabackend.h"
#include "chartdatacalculator.h"

#include "../constants.h"

#include <QDebug>
#include <QFile>
#include <QUrl>
#include <QUrlQuery>
#include <QUuid>
#include <QJsonObject>
#include <QJsonArray>
#include <QDateTime>
#include <QVariantMap>
#include <QJsonDocument>
#include <QRegularExpression>

#define LOG(x) qDebug() << "IngDibaBackend::" << x

IngDibaBackend::IngDibaBackend(QNetworkAccessManager *manager, QObject *parent)
    : AbstractDataBackend(manager, parent) {
    qDebug() << "Initializing Ing Diba Backend...";
    this->supportedChartTypes = (ChartType::INTRADAY
                                 | ChartType::WEEK
                                 | ChartType::MONTH
                                 | ChartType::YEAR
                                 | ChartType::THREE_YEARS
                                 | ChartType::MAXIMUM);
    this->chartTypeToStringMap[ChartType::INTRADAY] = "Intraday";
    this->chartTypeToStringMap[ChartType::WEEK] = "OneWeek";
    this->chartTypeToStringMap[ChartType::MONTH] = "OneMonth";
    this->chartTypeToStringMap[ChartType::YEAR] = "OneYear";
    this->chartTypeToStringMap[ChartType::THREE_YEARS] = "ThreeYears";
    this->chartTypeToStringMap[ChartType::MAXIMUM] = "Maximum";
}

IngDibaBackend::~IngDibaBackend() {
    qDebug() << "Shutting down Ing Diba Backend...";
}

void IngDibaBackend::searchName(const QString &searchString) {
    qDebug() << "IngDibaBackend::searchName";
    QNetworkReply *reply = executeGetRequest(QUrl(QString(ING_DIBA_API_SEARCH).arg(searchString)));

    connectErrorSlot(reply);
    connect(reply, SIGNAL(finished()), this, SLOT(handleSearchNameFinished()));
}

void IngDibaBackend::searchQuoteForNameSearch(const QString &searchString) {
    // TODO check if needed
    qDebug() << "IngDibaBackend::searchQuoteForNameSearch";
    QNetworkReply *reply = executeGetRequest(QUrl(QString(ING_DIBA_API_QUOTE).arg(searchString)));

    connectErrorSlot(reply);
    connect(reply, SIGNAL(finished()), this, SLOT(handleSearchQuoteForNameFinished()));
}

void IngDibaBackend::fetchPricesForChart(const QString &extRefId, const int chartType) {
    qDebug() << "IngDibaBackend::fetchPricesForChart";

    if (!isChartTypeSupported(chartType)) {
        qDebug() << "IngDibaBackend::fetchClosePrices - chart type " << chartType << " not supported!";
        return;
    }

    QNetworkReply *reply;

    reply = executeGetRequest(QUrl(QString(ING_DIBA_API_PREQUOTE_DATA).arg(extRefId)));
    reply->setProperty(NETWORK_REPLY_PROPERTY_CHART_TYPE, chartType);
    reply->setProperty(NETWORK_REPLY_PROPERTY_EXT_REF_ID, extRefId);
    connectErrorSlot(reply);
    connect(reply, &QNetworkReply::finished, [this, reply]()
    {
        reply->deleteLater();

        qDebug() << sender();
        qDebug() << "type :" << reply->property(NETWORK_REPLY_PROPERTY_CHART_TYPE);
        qDebug() << "extRefId :" << reply->property(NETWORK_REPLY_PROPERTY_EXT_REF_ID);

        processPreQuoteData(reply);
    });
}

void IngDibaBackend::processPreQuoteData(QNetworkReply *preChartReply) {
    qDebug() << "IngDibaBackend::processPreQuoteData";
    const QJsonDocument jsonDocument = QJsonDocument::fromJson(preChartReply->readAll());
    const QString extRefId = preChartReply->property(NETWORK_REPLY_PROPERTY_EXT_REF_ID).toString();
    const int chartType = preChartReply->property(NETWORK_REPLY_PROPERTY_CHART_TYPE).toInt();

    if (!jsonDocument.isObject()) {
        qDebug() << "not a json object!";
    }

    const QJsonObject responseObject = jsonDocument.object();
    const QString valor = responseObject["valor"].toString();
    const QJsonArray chartPeriods = responseObject["chartPeriods"].toArray();
    const QString chartTypeString = this->chartTypeToStringMap[chartType];

    qDebug() << "valor : " << valor;
    qDebug() << "chartTypeString : " << chartTypeString;
    qDebug() << "chartPeriods : " << chartPeriods;

    QNetworkReply *reply = executeGetRequest(QUrl(QString(ING_DIBA_API_CHART_PRICES).arg(extRefId, chartTypeString)));
    reply->setProperty("type", chartType);
    connectErrorSlot(reply);
    connect(reply, &QNetworkReply::finished, this, &IngDibaBackend::handleFetchPricesForChartFinished);
}

void IngDibaBackend::searchQuote(const QString &searchString) {
    // TODO check if needed
    qDebug() << "IngDibaBackend::searchQuote";

    QStringList ibanList = searchString.split(",");
    this->numberOfRequestedIbans = ibanList.size();
    searchQuoteResults.clear();

    foreach (const QString &iban, ibanList) {
        qDebug() << "looking up " << iban;
        QNetworkReply *reply = executeGetRequest(QUrl(QString(ING_DIBA_API_QUOTE).arg(iban)));

        connectErrorSlot(reply);
        connect(reply, SIGNAL(finished()), this, SLOT(handleSearchQuoteFinished()));
    }
}

void IngDibaBackend::handleSearchNameFinished() {
    qDebug() << "IngDibaBackend::handleSearchNameFinished";
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    reply->deleteLater();
    if (reply->error() != QNetworkReply::NoError) {
        return;
    }

    QByteArray searchReply = reply->readAll();
    QJsonDocument jsonDocument = QJsonDocument::fromJson(searchReply);
    if (jsonDocument.isObject()) {
        emit searchResultAvailable(processSearchResult(searchReply));
    } else {
        qDebug() << "not a json object !";
    }
}

void IngDibaBackend::handleSearchQuoteForNameFinished() {
    qDebug() << "IngDibaBackend::handleSearchQuoteForNameFinished";
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    reply->deleteLater();
    if (reply->error() != QNetworkReply::NoError) {
        return;
    }

    emit searchResultAvailable(processSearchResult(reply->readAll()));
}

void IngDibaBackend::handleSearchQuoteFinished() {
    qDebug() << "IngDibaBackend::handleSearchQuoteForNameFinished";
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    reply->deleteLater();
    if (reply->error() != QNetworkReply::NoError) {
        return;
    }

    QJsonObject result = processQuoteResultSingle(reply->readAll());
    searchQuoteResults.append(result);

    if (searchQuoteResults.size() == this->numberOfRequestedIbans) {
        QJsonDocument resultDocument;
        QJsonArray resultArray;

        foreach (const QJsonObject &quoteResultObject, searchQuoteResults ) {
            resultArray.push_back(quoteResultObject);
        }

        resultDocument.setArray(resultArray);
        QString dataToString(resultDocument.toJson());

        emit quoteResultAvailable(dataToString);
    }
}

void IngDibaBackend::handleFetchPricesForChartFinished() {
    qDebug() << "IngDibaBackend::handleFetchPricesForChartFinished";
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    reply->deleteLater();
    if (reply->error() != QNetworkReply::NoError) {
        return;
    }

    QByteArray resultByteArray = reply->readAll();
    QString result = QString(resultByteArray);

    qDebug() << "IngDibaBackend::handleFetchPricesForChartFinished result " << result;

    QString jsonResponseString = parsePriceResponse(resultByteArray);

    if (!jsonResponseString.isNull()) {
        emit fetchPricesForChartAvailable(jsonResponseString, reply->property("type").toInt());
    }
}

QString IngDibaBackend::parsePriceResponse(QByteArray reply) {
    QJsonDocument jsonDocument = QJsonDocument::fromJson(reply);
    if (!jsonDocument.isObject()) {
        qDebug() << "not a json object!";
        return QString();
    }

    QJsonObject responseObject = jsonDocument.object();
    // response only contains one element in the intruments array
    QJsonObject firstInstrumentsObject = responseObject["instruments"].toArray().at(0).toObject();
    QJsonArray chartDataArray = firstInstrumentsObject["data"].toArray();

    QJsonArray resultArray;
    ChartDataCalculator chartDataCalculator;

    foreach (const QJsonValue &value, chartDataArray) {
        QJsonArray dataArray = value.toArray();
        QVariant mSecsSinceEpochVariant = dataArray.at(0).toVariant();
        qint64 mSecsSinceEpoch = static_cast<qint64>(mSecsSinceEpochVariant.toDouble());

        double closeValue = dataArray.at(1).toDouble();
        chartDataCalculator.checkCloseValue(closeValue);

        resultArray.push_back(createChartDataPoint(mSecsSinceEpoch, closeValue));
    }

    return createChartResponseString(resultArray, chartDataCalculator);
}

QString IngDibaBackend::processSearchResult(QByteArray searchReply) {
    qDebug() << "IngDibaBackend::processSearchResult";
    QJsonDocument jsonDocument = QJsonDocument::fromJson(searchReply);
    if (!jsonDocument.isObject()) {
        qDebug() << "not a json object!";
    }

    // https://api.wertpapiere.ing.de/suche-autocomplete/autocomplete?query=de

    QJsonObject responseObject = jsonDocument.object();
    QJsonArray suggestionTypes = responseObject["suggestion_types"].toArray(); // -> type: "direct_hit"
    QJsonArray suggestionGroups = suggestionTypes.at(0).toObject()["suggestion_groups"].toArray(); //  -> group: "wp"
    QJsonArray suggestionGroupsDirectHit = findFirstValueFromJsonArray(suggestionTypes, "type", "direct_hit")["suggestion_groups"].toArray(); //  -> group: "wp"
    QJsonArray suggestions = suggestionGroups.at(0).toObject()["suggestions"].toArray();
    QJsonArray suggestionsWp = findFirstValueFromJsonArray(suggestionGroupsDirectHit, "group", "wp")["suggestions"].toArray();

    qDebug() << "direct hit: " << suggestionGroupsDirectHit;

    //QJsonArray dataArray = securitiesObject["data"].toArray();

    QJsonDocument resultDocument;
    QJsonArray resultArray;

    foreach (const QJsonValue & value, suggestionsWp) {
        QJsonObject suggestion = value.toObject();
        qDebug() << " sugg : " << suggestion["score"];

        QString category = suggestion["category"].toString();
        if (isValidSecurityCategory(category)) {
            // id is not mapped so far - is it used ??
            QJsonObject resultObject;
            resultObject.insert("extRefId", suggestion["isin"]);
            resultObject.insert("symbol1", suggestion["wkn"]);
            resultObject.insert("name", suggestion["text"]);
            resultObject.insert("isin", suggestion["isin"]);
            resultObject.insert("stockMarketName", "-");
            resultObject.insert("currency", QJsonValue(""));
            resultObject.insert("price", suggestion["price_html"]);
            // not persisted - displayed on the add stock page
            resultObject.insert("genericText1", suggestion["price_html"]);

            resultArray.push_back(resultObject);
        }
    }

    resultDocument.setArray(resultArray);
    QString dataToString(resultDocument.toJson());

    return dataToString;
}

bool IngDibaBackend::isValidSecurityCategory(QString category) {
    return (category.compare(QString("Fonds"), Qt::CaseInsensitive) == 0
            || category.compare(QString("Aktien"), Qt::CaseInsensitive) == 0);
}

QJsonObject IngDibaBackend::findFirstValueFromJsonArray(QJsonArray arr, QString key, QString value) {
    for (const auto obj : arr) {
        if (obj.toObject().value(key) == value) {
            return obj.toObject();
        }
    }
    return QJsonObject();
}

QJsonObject IngDibaBackend::processQuoteResultSingle(QByteArray searchQuoteReply) {
    qDebug() << "IngDibaBackend::processQuoteResultSingle";
    QJsonDocument jsonDocument = QJsonDocument::fromJson(searchQuoteReply);
    if (!jsonDocument.isObject()) {
        qDebug() << "not a json object!";
    }

    QJsonObject responseObject = jsonDocument.object();

    // for US stocks the isin is not populated, but the internationalIsin - in this
    // case use the internationalIsin
    bool useIsin = (!responseObject.value("isin").toString().isEmpty());
    QJsonValue isin = (useIsin ? responseObject.value("isin") : responseObject.value("internalIsin"));

    QJsonObject resultObject;
    resultObject.insert("name", responseObject.value("name"));
    resultObject.insert("isin", isin);
    resultObject.insert("extRefId", isin);
    resultObject.insert("symbol1", responseObject.value("wkn"));
    resultObject.insert("currency", convertCurrency(responseObject.value("currency").toString()));
    resultObject.insert("price", responseObject.value("price"));
    resultObject.insert("ask", responseObject.value("ask"));
    resultObject.insert("bid", responseObject.value("bid"));
    resultObject.insert("changeAbsolute", responseObject.value("changeAbsolute"));
    resultObject.insert("changeRelative", responseObject.value("changePercent"));
    resultObject.insert("stockMarketName", responseObject.value("stockMarket"));

    // values we do not get
    resultObject.insert("volume", QJsonValue(0));
    resultObject.insert("high", QJsonValue(0));
    resultObject.insert("low", QJsonValue(0));
    resultObject.insert("numberOfStocks", QJsonValue(0));

    QJsonValue jsonPriceChangeDate = responseObject.value("priceChangeDate");
    QDateTime updatedAtLocalTime = convertUTCDateTimeToLocalDateTime(jsonPriceChangeDate.toString());
    resultObject.insert("quoteTimestamp", convertToDatabaseDateTimeFormat(updatedAtLocalTime));

    resultObject.insert("lastChangeTimestamp", convertToDatabaseDateTimeFormat(QDateTime::currentDateTime()));

    return resultObject;
}

QDateTime IngDibaBackend::convertUTCDateTimeToLocalDateTime(const QString &utcDateTimeString) {
    QDateTime utcDateTime = QDateTime::fromString(utcDateTimeString, Qt::ISODate);
    QDateTime localDateTime = QDateTime(utcDateTime.date(), utcDateTime.time(), Qt::UTC).toLocalTime();

    // qDebug() << " converted date from " << utcDateTimeString << " to " << localDateTime;

    return localDateTime;
}

QString IngDibaBackend::processQuoteResult(QByteArray searchReply) {
    qDebug() << "IngDibaBackend::processQuoteResult";
    // TODO remove - dead
    return QString("");
}

QString IngDibaBackend::convertCurrency(const QString &currencyString) {
    if (QString("EUR").compare(currencyString, Qt::CaseInsensitive) == 0) {
        return QString("\u20AC");
    }
    return currencyString;
}
