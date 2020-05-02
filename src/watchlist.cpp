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
#include "watchlist.h"

Watchlist::Watchlist(QObject *parent) : QObject(parent),
    networkAccessManager(new QNetworkAccessManager(this)),
    networkConfigurationManager(new QNetworkConfigurationManager(this)),
    settings("harbour-watchlist", "settings") {
    // data backends
    euroinvestorBackend = new EuroinvestorBackend(this->networkAccessManager, "harbour-watchlist", QString(VERSION_NUMBER), this);
    moscowExchangeBackend = new MoscowExchangeBackend(this->networkAccessManager, "harbour-watchlist", QString(VERSION_NUMBER), this);
    // news backends
    onvistaNews = new OnvistaNews(this->networkAccessManager, this);
}

Watchlist::~Watchlist() {
}

bool Watchlist::isWiFi() {
    QList<QNetworkConfiguration> activeConfigurations = networkConfigurationManager->allConfigurations(QNetworkConfiguration::Active);
    QListIterator<QNetworkConfiguration> configurationIterator(activeConfigurations);
    while (configurationIterator.hasNext()) {
        QNetworkConfiguration activeConfiguration = configurationIterator.next();
        if (activeConfiguration.bearerType() == QNetworkConfiguration::BearerWLAN || activeConfiguration.bearerType() == QNetworkConfiguration::BearerEthernet) {
            qDebug() << "Watchlist::isWiFi : WiFi ON!";
            return true;
        }
    }
    qDebug() << "Watchlist::isWiFi : WiFi OFF!";
    return false;
}

EuroinvestorBackend *Watchlist::getEuroinvestorBackend() {
    return this->euroinvestorBackend;
}

MoscowExchangeBackend *Watchlist::getMoscowExchangeBackend() {
    return this->moscowExchangeBackend;
}

OnvistaNews *Watchlist::getOnvistaNews() {
    return this->onvistaNews;
}
