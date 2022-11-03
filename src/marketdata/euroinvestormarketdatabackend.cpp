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
#include "euroinvestormarketdatabackend.h"
#include "../constants.h"

#include <QDateTime>
#include <QDebug>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QUrl>

EuroinvestorMarketDataBackend::EuroinvestorMarketDataBackend(QNetworkAccessManager *manager, QObject *parent)
    : QObject(parent) {
    qDebug() << "Initializing Euroinvestor Market Data Backend...";
    this->manager = manager;

    // Index
    // DE
    marketDataId2ExtRefId["INDEX_DAX"] = "11876";
    marketDataId2ExtRefId["INDEX_MDAX"] = "12036";
    marketDataId2ExtRefId["INDEX_SDAX"] = "12100";
    marketDataId2ExtRefId["INDEX_TECDAX"] = "12101";
    // US
    marketDataId2ExtRefId["INDEX_S&P500"] = "15326";
    marketDataId2ExtRefId["INDEX_NASDAQ"] = "74288";
    marketDataId2ExtRefId["INDEX_DOWJONES"] = "9703";
    // France
    marketDataId2ExtRefId["INDEX_CN20"] = "78560";
    marketDataId2ExtRefId["INDEX_CAC40"] = "73594";
    marketDataId2ExtRefId["INDEX_SFB120"] = "70498";
    // Other
    marketDataId2ExtRefId["INDEX_OMXS30"] = "78541";
    marketDataId2ExtRefId["INDEX_OSEBX"] = "69309";
    marketDataId2ExtRefId["INDEX_OMC_C25"] = "64283";

    // Commodities
    marketDataId2ExtRefId["COM_GOLD"] = "224286";
    marketDataId2ExtRefId["COM_SILVER"] = "224285";
    marketDataId2ExtRefId["COM_PLATINUM"] = "224288";
    marketDataId2ExtRefId["COM_PALLADIUM"] = "224287";

    // Currencies
    marketDataId2ExtRefId["CUR_SEK_DKK"] = "216830";
    marketDataId2ExtRefId["CUR_EUR_USD"] = "216178";
    marketDataId2ExtRefId["CUR_EUR_CAD"] = "216074";
    marketDataId2ExtRefId["CUR_EUR_RUB"] = "216156";
    marketDataId2ExtRefId["CUR_JPY_USD"] = "216503";
    marketDataId2ExtRefId["CUR_CHF_EUR"] = "215878";
    marketDataId2ExtRefId["CUR_GBP_EUR"] = "216236";
    marketDataId2ExtRefId["CUR_GBP_RUB"] = "216298";
    marketDataId2ExtRefId["CUR_GBP_USD"] = "216318";
    marketDataId2ExtRefId["CUR_GBP_DKK"] = "216231";
    marketDataId2ExtRefId["CUR_USD_EUR"] = "217023";
    marketDataId2ExtRefId["CUR_USD_RUB"] = "217091";

    // Crypto Currencies
    marketDataId2ExtRefId["CRYPTO_BITCOIN"] = "252303";
    marketDataId2ExtRefId["CRYPTO_BITCOIN_CASH"] = "252699";
    marketDataId2ExtRefId["CRYPTO_LITECOIN"] = "252302";
    marketDataId2ExtRefId["CRYPTO_DASH"] = "252674";
    marketDataId2ExtRefId["CRYPTO_ETHEREUM"] = "252268";
    marketDataId2ExtRefId["CRYPTO_TETHER"] = "252204";
    marketDataId2ExtRefId["CRYPTO_IOTA"] = "252568";
    marketDataId2ExtRefId["CRYPTO_MONERO"] = "252587";
    marketDataId2ExtRefId["CRYPTO_EOS"] = "252557";
    marketDataId2ExtRefId["CRYPTO_BINANCE_USD"] = "252094";
    marketDataId2ExtRefId["CRYPTO_XRP"] = "252294";
    marketDataId2ExtRefId["CRYPTO_CARDANO"] = "99577";
    marketDataId2ExtRefId["CRYPTO_TEZOS"] = "252574";
    marketDataId2ExtRefId["CRYPTO_CHAINLINK"] = "238649";
}

EuroinvestorMarketDataBackend::~EuroinvestorMarketDataBackend() {
    qDebug() << "Shutting down Euroinvestor Backend...";
    marketDataId2ExtRefId.clear();
}

QNetworkReply *EuroinvestorMarketDataBackend::executeGetRequest(const QUrl &url) {
    qDebug() << "AbstractDataBackend::executeGetRequest " << url;
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, MIME_TYPE_JSON);
    request.setHeader(QNetworkRequest::UserAgentHeader, USER_AGENT);

    return manager->get(request);
}

QString EuroinvestorMarketDataBackend::getMarketDataExtRefId(const QString &marketDataId) {
    if (marketDataId2ExtRefId.contains(marketDataId)) {
        return marketDataId2ExtRefId[marketDataId];
    }

    return QString();
}

void EuroinvestorMarketDataBackend::lookupMarketData(const QString &marketDataIds) {
    qDebug() << "EuroinvestorMarketDataBackend::lookupMarketData";
    QNetworkReply *reply = executeGetRequest(QUrl(API_MARKET_DATA + marketDataIds));

    connect(reply,
            SIGNAL(error(QNetworkReply::NetworkError)),
            this,
            SLOT(handleRequestError(QNetworkReply::NetworkError)));
    connect(reply, SIGNAL(finished()), this, SLOT(handleLookupMarketDataFinished()));
}

void EuroinvestorMarketDataBackend::handleLookupMarketDataFinished() {
    qDebug() << "EuroinvestorMarketDataBackend::handleLookupMarketDataFinished";
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    reply->deleteLater();
    if (reply->error() != QNetworkReply::NoError) {
        return;
    }

    emit marketDataResultAvailable(processMarketDataResult(reply->readAll()));
}

QString EuroinvestorMarketDataBackend::processMarketDataResult(QByteArray marketDataResult) {
    qDebug() << "EuroinvestorMarketDataBackend::processMarketDataResult";
    QJsonDocument jsonDocument = QJsonDocument::fromJson(marketDataResult);
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
        resultObject.insert("last", rootObject.value("last"));
        resultObject.insert("symbol", rootObject.value("symbol"));
        resultObject.insert("stockMarketName", exchangeObject.value("name"));
        resultObject.insert("changeAbsolute", rootObject.value("change"));
        resultObject.insert("changeRelative", rootObject.value("changeInPercentage"));

        QJsonValue jsonUpdatedAt = rootObject.value("updatedAt");
        QDateTime updatedAtLocalTime = convertUTCDateTimeToLocalDateTime(jsonUpdatedAt.toString());
        resultObject.insert("quoteTimestamp", convertToDatabaseDateTimeFormat(updatedAtLocalTime));

        resultObject.insert("lastChangeTimestamp", convertToDatabaseDateTimeFormat(QDateTime::currentDateTime()));

        resultArray.push_back(resultObject);
    }

    resultDocument.setArray(resultArray);
    QString dataToString(resultDocument.toJson());

    return dataToString;
}

void EuroinvestorMarketDataBackend::handleRequestError(QNetworkReply::NetworkError error) {
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    qWarning() << "EuroinvestorMarketDataBackend::handleRequestError:" << static_cast<int>(error)
               << reply->errorString() << reply->readAll();

    emit requestError("Return code: " + QString::number(static_cast<int>(error)) + " - " + reply->errorString());
}

QDateTime EuroinvestorMarketDataBackend::convertUTCDateTimeToLocalDateTime(const QString &utcDateTimeString) {
    QDateTime utcDateTime = QDateTime::fromString(utcDateTimeString, Qt::ISODate);
    QDateTime localDateTime = QDateTime(utcDateTime.date(), utcDateTime.time(), Qt::UTC).toLocalTime();

    qDebug() << " converted date from " << utcDateTimeString << " to " << localDateTime;

    return localDateTime;
}

QString EuroinvestorMarketDataBackend::convertToDatabaseDateTimeFormat(const QDateTime &time) {
    return time.toString("yyyy-MM-dd") + " " + time.toString("hh:mm:ss");
}
