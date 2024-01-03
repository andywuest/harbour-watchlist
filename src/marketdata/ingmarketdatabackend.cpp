/*
 * harbour-watchlist - Sailfish OS Version
 * Copyright © 2024 Andreas Wüst (andreas.wuest.freelancer@gmail.com)
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
#include "ingmarketdatabackend.h"
#include "../constants.h"
#include "../ingdibautils.h"

#include <QDateTime>
#include <QDebug>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QUrl>

IngMarketDataBackend::IngMarketDataBackend(QNetworkAccessManager *manager, QObject *parent) : QObject(parent)
{
    qDebug() << "Initializing Ing Market Data Backend...";
    this->manager = manager;

    // Index
    // DE
    marketDataId2ExtRefId["INDEX_DAX"] = "DE0008469008";
    extRefIdToIsinMap["998032"] = "DE0008469008";

    marketDataId2ExtRefId["INDEX_MDAX"] = "DE0008467416";
    extRefIdToIsinMap["252367"] = "DE0008467416";

    marketDataId2ExtRefId["INDEX_SDAX"] = "DE0009653386";
    extRefIdToIsinMap["701259"] = "DE0009653386";

    marketDataId2ExtRefId["INDEX_TECDAX"] = "DE0007203275";
    extRefIdToIsinMap["1548840"] = "DE0007203275";

    // US
    marketDataId2ExtRefId["INDEX_S&P500"] = "US78378X1072";
    extRefIdToIsinMap["998434"] = "US78378X1072";

    marketDataId2ExtRefId["INDEX_NASDAQ"] = "US6311031081";
    extRefIdToIsinMap["1251097"] = "US6311031081";

    marketDataId2ExtRefId["INDEX_DOWJONES"] = "US2605661048";
    extRefIdToIsinMap["998313"] = "US2605661048";

    // France
    // marketDataId2ExtRefId["INDEX_CN20"] = "78560";

    marketDataId2ExtRefId["INDEX_CAC40"] = "FR0003500008";
    extRefIdToIsinMap["998033"] = "FR0003500008";

    // marketDataId2ExtRefId["INDEX_SFB120"] = "70498";

    // Other
    marketDataId2ExtRefId["INDEX_EUROSTOXX50"] = "EU0009658145";
    extRefIdToIsinMap["846480"] = "EU0009658145";

    marketDataId2ExtRefId["INDEX_SMI"] = "CH0009980894";
    extRefIdToIsinMap["998089"] = "CH0009980894";

    marketDataId2ExtRefId["INDEX_ATX"] = "AT0000999982";
    extRefIdToIsinMap["998663"] = "AT0000999982";

    // marketDataId2ExtRefId["INDEX_OSEBX"] = "69309";
    // marketDataId2ExtRefId["INDEX_OMC_C25"] = "64283";

    // Commodities
    marketDataId2ExtRefId["COM_GOLD"] = "XD0002747026";
    extRefIdToIsinMap["274702"] = "XD0002747026";

    marketDataId2ExtRefId["COM_SILVER"] = "XD0002747208";
    extRefIdToIsinMap["274720"] = "XD0002747208";

    marketDataId2ExtRefId["COM_PLATINUM"] = "XD0002876395";
    extRefIdToIsinMap["287639"] = "XD0002876395";

    marketDataId2ExtRefId["COM_PALLADIUM"] = "XD0002876429";
    extRefIdToIsinMap["287642"] = "XD0002876429";

    // Currencies
//    marketDataId2ExtRefId["CUR_SEK_DKK"] = "216830";

    marketDataId2ExtRefId["CUR_EUR_USD"] = "EU0009652759";
    extRefIdToIsinMap["946681"] = "EU0009652759";

    marketDataId2ExtRefId["CUR_EUR_CAD"] = "EU0009654664";
    extRefIdToIsinMap["946690"] = "EU0009654664";

    marketDataId2ExtRefId["CUR_EUR_GBP"] = "EU0009653088";
    extRefIdToIsinMap["946684"] = "EU0009653088";

    marketDataId2ExtRefId["CUR_EUR_CHF"] = "EU0009654078";
    extRefIdToIsinMap["897789"] = "EU0009654078";

    marketDataId2ExtRefId["CUR_EUR_RUB"] = "EU0001458346";
    extRefIdToIsinMap["946869"] = "EU0001458346";

//    marketDataId2ExtRefId["CUR_JPY_USD"] = "216503";
//    marketDataId2ExtRefId["CUR_CHF_EUR"] = "215878";
//    marketDataId2ExtRefId["CUR_GBP_EUR"] = "216236";
//    marketDataId2ExtRefId["CUR_GBP_RUB"] = "216298";

    marketDataId2ExtRefId["CUR_GBP_USD"] = "GB0031973075";
    extRefIdToIsinMap["275017"] = "GB0031973075";

//    marketDataId2ExtRefId["CUR_GBP_DKK"] = "216231";

    marketDataId2ExtRefId["CUR_USD_EUR"] = "XD0009689841";
    extRefIdToIsinMap["968984"] = "XD0009689841";

//    marketDataId2ExtRefId["CUR_USD_RUB"] = "217091";

//    // Crypto Currencies
//    marketDataId2ExtRefId["CRYPTO_BITCOIN"] = "275903";
//    marketDataId2ExtRefId["CRYPTO_BITCOIN_CASH"] = "252699";
//    marketDataId2ExtRefId["CRYPTO_LITECOIN"] = "252302";
//    marketDataId2ExtRefId["CRYPTO_DASH"] = "252674";
//    marketDataId2ExtRefId["CRYPTO_ETHEREUM"] = "252268";
//    marketDataId2ExtRefId["CRYPTO_TETHER"] = "252204";
//    marketDataId2ExtRefId["CRYPTO_IOTA"] = "252568";
//    marketDataId2ExtRefId["CRYPTO_MONERO"] = "252587";
//    marketDataId2ExtRefId["CRYPTO_EOS"] = "252557";
//    marketDataId2ExtRefId["CRYPTO_BINANCE_USD"] = "252094";
//    marketDataId2ExtRefId["CRYPTO_XRP"] = "252294";
//    marketDataId2ExtRefId["CRYPTO_CARDANO"] = "99577";
//    marketDataId2ExtRefId["CRYPTO_TEZOS"] = "252574";
//    marketDataId2ExtRefId["CRYPTO_CHAINLINK"] = "238649";
}

IngMarketDataBackend::~IngMarketDataBackend() {
    qDebug() << "Shutting down ING Market Backend...";
    marketDataId2ExtRefId.clear();
}

QNetworkReply *IngMarketDataBackend::executeGetRequest(const QUrl &url) {
    qDebug() << "IngMarketDataBackend::executeGetRequest " << url;
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, MIME_TYPE_JSON);
    request.setHeader(QNetworkRequest::UserAgentHeader, USER_AGENT);

    return manager->get(request);
}

QString IngMarketDataBackend::getMarketDataExtRefId(const QString &marketDataId) {
    if (marketDataId2ExtRefId.contains(marketDataId)) {
        return marketDataId2ExtRefId[marketDataId];
    }

    return QString();
}

void IngMarketDataBackend::lookupMarketData(const QString &marketDataIds) {
    qDebug() << "IngMarketDataBackend::lookupMarketData";

    QStringList idList = marketDataIds.split(",");
    this->numberOfRequestedIds = idList.size();
    searchQuoteResults.clear();

    foreach (const QString &id, idList) {
        qDebug() << "looking up id " << id;
        QNetworkReply *reply = executeGetRequest(QUrl(QString(ING_DIBA_API_QUOTE).arg(id)));

        connectErrorSlot(reply);
        connect(reply, SIGNAL(finished()), this, SLOT(handleLookupMarketDataFinished()));
    }
}

void IngMarketDataBackend::connectErrorSlot(QNetworkReply *reply) {
    // connect the error and also emit the error signal via a lambda expression
    connect(reply,
            static_cast<void (QNetworkReply::*)(QNetworkReply::NetworkError)>(&QNetworkReply::error),
            [=](QNetworkReply::NetworkError error) {
                // TODO test reply->deleteLater();
                qWarning() << "AbstractDataBackend::handleRequestError:" << static_cast<int>(error)
                           << reply->errorString() << reply->readAll();
                emit requestError("Return code: " + QString::number(static_cast<int>(error)) + " - "
                                  + reply->errorString());
            });
}

void IngMarketDataBackend::handleLookupMarketDataFinished() {
    qDebug() << "IngMarketDataBackend::handleSearchQuoteFinished";
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    reply->deleteLater();
    if (reply->error() != QNetworkReply::NoError) {
        return;
    }

    QJsonObject result = processQuoteResultSingle(reply->readAll());
    searchQuoteResults.append(result);

    if (searchQuoteResults.size() == this->numberOfRequestedIds) {
        QJsonDocument resultDocument;
        QJsonArray resultArray;

        foreach (const QJsonObject &quoteResultObject, searchQuoteResults) {
            resultArray.push_back(quoteResultObject);
        }

        resultDocument.setArray(resultArray);
        QString dataToString(resultDocument.toJson());

        emit marketDataResultAvailable(dataToString);
    }
}

void IngMarketDataBackend::handleRequestError(QNetworkReply::NetworkError error) {
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    qWarning() << "IngMarketDataBackend::handleRequestError:" << static_cast<int>(error)
               << reply->errorString() << reply->readAll();

    emit requestError("Return code: " + QString::number(static_cast<int>(error)) + " - " + reply->errorString());
}

// TODO check if we need this
QDateTime IngMarketDataBackend::convertUTCDateTimeToLocalDateTime(const QString &utcDateTimeString) {
    QDateTime utcDateTime = QDateTime::fromString(utcDateTimeString, Qt::ISODate);
    QDateTime localDateTime = QDateTime(utcDateTime.date(), utcDateTime.time(), Qt::UTC).toLocalTime();

    qDebug() << " converted date from " << utcDateTimeString << " to " << localDateTime;

    return localDateTime;
}

QString IngMarketDataBackend::convertToDatabaseDateTimeFormat(const QDateTime &time) {
    return time.toString("yyyy-MM-dd") + " " + time.toString("hh:mm:ss");
}

QJsonObject IngMarketDataBackend::processQuoteResultSingle(QByteArray searchQuoteReply) {
    qDebug() << "IngDibaBackend::processQuoteResultSingle";
    QJsonDocument jsonDocument = QJsonDocument::fromJson(searchQuoteReply);
    if (!jsonDocument.isObject()) {
        qDebug() << "not a json object!";
    }

    QJsonObject rootObject = jsonDocument.object();

    // for US stocks the isin is not populated, but the internationalIsin - in this
    // case use the internationalIsin
    //bool useIsin = (!responseObject.value("isin").toString().isEmpty());
    //QJsonValue isin = (useIsin ? responseObject.value("isin") : responseObject.value("internalIsin"));

    QString extRefIdString = QString::number(rootObject.value("id").toInt());

    QJsonObject resultObject;
    resultObject.insert("extRefId", extRefIdToIsinMap[extRefIdString]);
    resultObject.insert("name", rootObject.value("name"));
    resultObject.insert("currency", rootObject.value("currencySign"));
    resultObject.insert("last", rootObject.value("price"));
    resultObject.insert("symbol", QString()); // not availabl
    resultObject.insert("stockMarketName", QString()); // not available
    resultObject.insert("changeAbsolute", rootObject.value("changeAbsolute"));
    resultObject.insert("changeRelative", rootObject.value("changePercent"));

    QJsonValue jsonPriceChangeDate = rootObject.value("priceChangeDate");
    QDateTime updatedAtLocalTime = IngDibaUtils::convertTimestampToLocalTimestamp(jsonPriceChangeDate.toString(),
                                                                                     QTimeZone::systemTimeZone());

    resultObject.insert("quoteTimestamp", convertToDatabaseDateTimeFormat(updatedAtLocalTime));

    resultObject.insert("lastChangeTimestamp", convertToDatabaseDateTimeFormat(QDateTime::currentDateTime()));

    return resultObject;
}
