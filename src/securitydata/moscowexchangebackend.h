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

#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QObject>

class MoscowExchangeBackend : public AbstractDataBackend {
    Q_OBJECT
public:
    explicit MoscowExchangeBackend(QNetworkAccessManager *manager, QObject *parent = nullptr);
    ~MoscowExchangeBackend() override;
    Q_INVOKABLE void searchName(const QString &searchString) override;
    Q_INVOKABLE void searchQuote(const QString &searchString) override;
    Q_INVOKABLE void fetchPricesForChart(const QString &extRefId, const int chartType) override;

signals:

protected:
    QString convertCurrency(const QString &currencyString) override;
    QString getLanguage();

public slots:

private:
    bool debugMode = false;

    // is triggered after name search because the first json request does not contain all information we need
    void searchQuoteForNameSearch(const QString &searchString);
    QString processSearchResult(QByteArray searchReply);
    QString processQuoteResult(QByteArray searchReply);
    QString parsePriceResponse(QByteArray priceReply);

private slots:
    void handleSearchNameFinished();
    void handleSearchQuoteForNameFinished();
    void handleSearchQuoteFinished();
    void handleFetchPricesForChartFinished();
};

#endif // MOSCOWEXCHANGEBACKEND_H
