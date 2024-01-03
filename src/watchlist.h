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
#ifndef WATCHLIST_H
#define WATCHLIST_H

#include <QNetworkAccessManager>
#include <QNetworkConfigurationManager>
#include <QObject>
#include <QSettings>

#include "marketdata/euroinvestormarketdatabackend.h"
#include "marketdata/ingmarketdatabackend.h"
#include "newsdata/onvistanews.h"
#include "newsdata/ingdibanews.h"
#include "securitydata/euroinvestorbackend.h"
#include "securitydata/ingdibabackend.h"
#include "securitydata/moscowexchangebackend.h"
#include "dividenddata/divvydiary.h"

class Watchlist : public QObject {
    Q_OBJECT
public:
    explicit Watchlist(QObject *parent = nullptr);
    ~Watchlist() = default;
    // market backend
    EuroinvestorBackend *getEuroinvestorBackend();
    IngMarketDataBackend *getIngMarketDataBackend();
    // quote backends
    MoscowExchangeBackend *getMoscowExchangeBackend();
    EuroinvestorMarketDataBackend *getEuroinvestorMarketDataBackend();
    IngDibaBackend *getIngDibaBackend();
    // news backends
    OnvistaNews *getOnvistaNews();
    IngDibaNews *getIngDibaNews();
    // dividend backends
    DivvyDiary *getDivvyDiaryBackend();

    Q_INVOKABLE bool isWiFi();

signals:

public slots:

private:
    QNetworkAccessManager *const networkAccessManager;
    QNetworkConfigurationManager *const networkConfigurationManager;

    // data backends
    EuroinvestorBackend *euroinvestorBackend;
    MoscowExchangeBackend *moscowExchangeBackend;
    IngDibaBackend *ingDibaBackend;

    // market data backends
    EuroinvestorMarketDataBackend *euroinvestorMarketDataBackend;
    IngMarketDataBackend *ingMarketDataBackend;

    // news backends
    OnvistaNews *onvistaNews;
    IngDibaNews *ingDibaNews;

    // dividend backends
    DivvyDiary *divvyDiaryBackend;

    QSettings settings;
};

#endif // WATCHLIST_H
