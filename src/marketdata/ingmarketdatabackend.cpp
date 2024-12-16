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
#include "ingmarketdata.h"

#include <QDateTime>
#include <QDebug>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QUrl>

IngMarketDataBackend::IngMarketDataBackend(QNetworkAccessManager *manager, QObject *parent)
    : QObject(parent) {
    qDebug() << "Initializing Ing Market Data Backend...";
    this->manager = manager;

    QList<IngMarketData> marketDataList;

    // Index
    // DE
    marketDataList.append(IngMarketData("DE0008469008", "998032", "INDEX_DAX"));
    marketDataList.append(IngMarketData("DE0008467416", "252367", "INDEX_MDAX"));
    marketDataList.append(IngMarketData("DE0009653386", "701259", "INDEX_SDAX"));
    marketDataList.append(IngMarketData("DE0007203275", "1548840", "INDEX_TECDAX"));

    // US
    marketDataList.append(IngMarketData("US78378X1072", "998434", "INDEX_S&P500"));
    marketDataList.append(IngMarketData("XC0009694271", "998356", "INDEX_NASDAQ_COMP"));
    marketDataList.append(IngMarketData("US6311011026", "985336", "INDEX_NASDAQ_100"));
    marketDataList.append(IngMarketData("US2605661048", "998313", "INDEX_DOWJONES"));

    // France
    marketDataList.append(IngMarketData("FR0003500008", "998033", "INDEX_CAC40"));

    // Other
    marketDataList.append(IngMarketData("EU0009658145", "846480", "INDEX_EUROSTOXX50"));
    marketDataList.append(IngMarketData("CH0009980894", "998089", "INDEX_SMI"));
    marketDataList.append(IngMarketData("AT0000999982", "998663", "INDEX_ATX"));

    // Commodities
    marketDataList.append(IngMarketData("XD0002747026", "274702", "COM_GOLD"));
    marketDataList.append(IngMarketData("XD0002747208", "274720", "COM_SILVER"));
    marketDataList.append(IngMarketData("XD0002876395", "287639", "COM_PLATINUM"));
    marketDataList.append(IngMarketData("XD0002876429", "287642", "COM_PALLADIUM"));
    marketDataList.append(IngMarketData("XC0007203216", "274234", "COM_COPPER"));
    marketDataList.append(IngMarketData("XD0002742308", "274230", "COM_WHEAT"));
    marketDataList.append(IngMarketData("XC0009677409", "274207", "COM_OIL_BRENT"));
    marketDataList.append(IngMarketData("XD0257705190", "25770519", "COM_OIL_WTI"));

    // Currencies
    marketDataList.append(IngMarketData("EU0009654664", "946690", "CUR_EUR_CAD"));
    marketDataList.append(IngMarketData("EU0009654078", "897789", "CUR_EUR_CHF"));
    marketDataList.append(IngMarketData("EU0009653088", "946684", "CUR_EUR_GBP"));
    marketDataList.append(IngMarketData("EU0001458346", "946869", "CUR_EUR_RUB"));
    marketDataList.append(IngMarketData("EU0009652759", "946681", "CUR_EUR_USD"));
    marketDataList.append(IngMarketData("GB0031973075", "275017", "CUR_GBP_USD"));
    marketDataList.append(IngMarketData("XD0009689841", "968984", "CUR_USD_EUR"));

    // Crypto Currencies
    marketDataList.append(IngMarketData("XD0394751214", "39475121", "CRYPTO_BITCOIN"));
    marketDataList.append(IngMarketData("XD0401495615", "40149561", "CRYPTO_ETHEREUM"));
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

    foreach (const IngMarketData &marketData, marketDataList) {
        marketDataId2ExtRefId[marketData.getIndexName()] = marketData.getExtRefId();
        extRefIdToIsinMap[marketData.getInternalId()] = marketData.getExtRefId();
    }
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
                qWarning() << "IngMarketDataBackend::handleRequestError:" << static_cast<int>(error)
                           << reply->errorString() << reply->readAll();
                emit requestError("Return code: " + QString::number(static_cast<int>(error)) + " - "
                                  + reply->errorString());
            });
}

void IngMarketDataBackend::handleLookupMarketDataFinished() {
    qDebug() << "IngMarketDataBackend::handleLookupMarketDataFinished";
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    reply->deleteLater();
    if (reply->error() != QNetworkReply::NoError) {
        return;
    }

    QJsonObject result = processQuoteResultSingle(reply->readAll());
    searchQuoteResults.append(result);

    if (searchQuoteResults.size() == this->numberOfRequestedIds) {
        QJsonArray resultArray;

        foreach (const QJsonObject &quoteResultObject, searchQuoteResults) {
            resultArray.push_back(quoteResultObject);
        }

        QJsonDocument resultDocument(resultArray);
        emit marketDataResultAvailable(QString(resultDocument.toJson()));
    }
}

void IngMarketDataBackend::handleRequestError(QNetworkReply::NetworkError error) {
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    qWarning() << "IngMarketDataBackend::handleRequestError:" << static_cast<int>(error) << reply->errorString()
               << reply->readAll();

    emit requestError("Return code: " + QString::number(static_cast<int>(error)) + " - " + reply->errorString());
}

QString IngMarketDataBackend::convertToDatabaseDateTimeFormat(const QDateTime &time) {
    return time.toString("yyyy-MM-dd") + " " + time.toString("hh:mm:ss");
}

QJsonObject IngMarketDataBackend::processQuoteResultSingle(QByteArray searchQuoteReply) {
    qDebug() << "IngMarketDataBackend::processQuoteResultSingle";
    QJsonDocument jsonDocument = QJsonDocument::fromJson(searchQuoteReply);
    if (!jsonDocument.isObject()) {
        qDebug() << "not a json object!";
    }

    QJsonObject rootObject = jsonDocument.object();

    QString extRefIdString = QString::number(rootObject.value("id").toInt());

    QJsonObject resultObject;
    resultObject.insert("extRefId", extRefIdToIsinMap[extRefIdString]);
    resultObject.insert("name", rootObject.value("name"));
    resultObject.insert("currency", rootObject.value("currencySign"));
    resultObject.insert("last", rootObject.value("price"));
    resultObject.insert("symbol", QString());          // not available
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
