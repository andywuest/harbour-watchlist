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
#ifndef EUROINVESTORBACKEND_H
#define EUROINVESTORBACKEND_H

#include <QObject>
#include <QNetworkReply>
#include <QNetworkAccessManager>

const char MIME_TYPE_JSON[] = "application/json";
const char USER_AGENT[] = "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:73.0) Gecko/20100101 Firefox/73.0";
const char API_SEARCH[] = "https://search.euroinvestor.dk/instruments?q=";
const char API_QUOTE[] = "https://api.euroinvestor.dk/instruments?ids=";
const char API_CLOSE_PRICES[] = "https://api.euroinvestor.dk/instruments/%1/closeprices?fromDate=%2";
const char API_INTRADAY_PRICES[] = "https://api.euroinvestor.dk/instruments/%1/intradays";

class EuroinvestorBackend : public QObject {
    Q_OBJECT
public:
    explicit EuroinvestorBackend(QNetworkAccessManager *manager, const QString &applicationName, const QString applicationVersion, QObject *parent = 0);
    ~EuroinvestorBackend();
    Q_INVOKABLE void searchName(const QString &searchString);
    Q_INVOKABLE void searchQuote(const QString &searchString);
    Q_INVOKABLE void fetchPricesForChart(const QString &extRefId, const int chartType);
    Q_INVOKABLE bool isChartTypeSupported(const int chartType);

    // signals for the qml part
    Q_SIGNAL void searchResultAvailable(const QString &reply);
    Q_SIGNAL void quoteResultAvailable(const QString &reply);
    Q_SIGNAL void fetchPricesForChartAvailable(const QString &reply, const int chartType);
    Q_SIGNAL void requestError(const QString &errorMessage);

signals:

protected:

    QString convertCurrency(const QString &currencyString);

public slots:

private:

    enum ChartType {
      INTRADAY = 0,
      MONTH = 1,
      THREE_MONTHS = 2,
      YEAR = 3,
      THREE_YEARS = 4,
      FIVE_YEARS = 5
    };

    QString applicationName;
    QString applicationVersion;
    QNetworkAccessManager *manager;

    QNetworkReply *executeGetRequest(const QUrl &url);

    // is triggered after name search because the first json request does not contain all information we need
    void searchQuoteForNameSearch(const QString &searchString);
    QString processQuoteSearchResult(QByteArray searchReply);
    QString parsePriceResponse(QByteArray priceReply);

private slots:
    void handleRequestError(QNetworkReply::NetworkError error);
    void handleSearchNameFinished();
    void handleSearchQuoteForNameFinished();
    void handleSearchQuoteFinished();
    void handleFetchPricesForChartFinished();
};

#endif // EUROINVESTORBACKEND_H
