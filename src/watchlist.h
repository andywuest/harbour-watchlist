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

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkConfigurationManager>
#include <QSettings>

#include "euroinvestorbackend.h"

class Watchlist : public QObject {
    Q_OBJECT
public:
    explicit Watchlist(QObject *parent = nullptr);
    ~Watchlist();
    EuroinvestorBackend *getEuroinvestorBackend();

    Q_INVOKABLE bool isWiFi();

signals:

public slots:

private:
    QNetworkAccessManager * const networkAccessManager;
    QNetworkConfigurationManager * const networkConfigurationManager;
    EuroinvestorBackend *euroinvestorBackend;
    QSettings settings;

};

#endif // WATCHLIST_H
