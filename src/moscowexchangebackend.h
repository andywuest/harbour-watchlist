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
#ifndef MOSCOWEXCHANGEBACKEND_H
#define MOSCOWEXCHANGEBACKEND_H

#include "abstractdatabackend.h"

#include <QObject>
#include <QNetworkReply>
#include <QNetworkAccessManager>

// TODO FIX URLS
const char MOSCOW_EXCHANGE_API_SEARCH[] = "http://iss.moex.com/iss/securities.json?q=%1&lang=en&group_by_filter=stock_shares&limit=15";
const char MOSCOW_EXCHANGE_QUOTE[] = "https://iss.moex.com/iss/engines/stock/markets/shares/boards/TQBR/securities.json?securities=%1&lang=en";
// can fetch max 100 entries at a time - so about a quarter
const char MOSCOW_EXCHANGE_API_CLOSE_PRICES[] = "https://iss.moex.com/iss/history/engines/stock/markets/shares/boards/TQBR/securities/%1.json?from=%2&lang=en";

const char MAPI_INTRADAY_PRICES[] = "https://api.euroinvestor.dk/instruments/%1/intradays";

class MoscowExchangeBackend : public AbstractDataBackend {
    Q_OBJECT
public:
    explicit MoscowExchangeBackend(QNetworkAccessManager *manager, const QString &applicationName, const QString applicationVersion, QObject *parent = 0);
    ~MoscowExchangeBackend();
    Q_INVOKABLE void searchName(const QString &searchString) override;
    Q_INVOKABLE void searchQuote(const QString &searchString) override;
    Q_INVOKABLE void fetchPricesForChart(const QString &extRefId, const int chartType) override;
    Q_INVOKABLE bool isChartTypeSupported(const int chartType) override;

//    // signals for the qml part
//    Q_SIGNAL void searchResultAvailable(const QString &reply);
//    Q_SIGNAL void quoteResultAvailable(const QString &reply);
//    Q_SIGNAL void fetchPricesForChartAvailable(const QString &reply, const int chartType);
//    Q_SIGNAL void requestError(const QString &errorMessage);

signals:

//protected:
protected:
    QString convertCurrency(const QString &currencyString) override;

public slots:

private:

//    enum ChartType {
//      INTRADAY = 0,
//      MONTH = 1,
//      THREE_MONTHS = 2,
//      YEAR = 3,
//      THREE_YEARS = 4,
//      FIVE_YEARS = 5
//    };

    static const QString MIME_TYPE_JSON;

//    QString applicationName;
//    QString applicationVersion;
//    QNetworkAccessManager *manager;

//    QNetworkReply *executeGetRequest(const QUrl &url);

    // is triggered after name search because the first json request does not contain all information we need
    void searchQuoteForNameSearch(const QString &searchString);
    QString processSearchResult(QByteArray searchReply);
    QString processQuoteResult(QByteArray searchReply);
    QString parsePriceResponse(QByteArray priceReply);

private slots:
//    void handleRequestError(QNetworkReply::NetworkError error);
    void handleSearchNameFinished();
    void handleSearchQuoteForNameFinished();
    void handleSearchQuoteFinished();
    void handleFetchPricesForChartFinished();
};

#endif // MOSCOWEXCHANGEBACKEND_H
