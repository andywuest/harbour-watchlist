/*
 * harbour-watchlist - Sailfish OS Version
 * Copyright © 2022 Andreas Wüst (andreas.wuest.freelancer@gmail.com)
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
#ifndef DIVVYDIARY_H
#define DIVVYDIARY_H

#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QObject>

#include "dividenddataupdateworker.h"

class DivvyDiary : public QObject {
    Q_OBJECT
public:
    explicit DivvyDiary(QNetworkAccessManager *manager, QObject *parent = nullptr);
    ~DivvyDiary() override;
    Q_INVOKABLE void fetchDividendDates();

    Q_SIGNAL void fetchDividendDatesResultAvailable(int rows);
    Q_SIGNAL void requestError(const QString &errorMessage);

signals:
    void dividendDataUpdateSuccessful(const QVariantList &result);

private:
    QNetworkAccessManager *manager;
    QNetworkReply *executeGetRequest(const QUrl &url);

    // worker - separate thread since expensive
    DividendDataUpdateWorker dividendDataUpdateWorker;

    void initializeDatabase();

    void executeQuery(QString &queryString, QMap<QString, QVariant> &dataMap);

private slots:
    void handleRequestError(QNetworkReply::NetworkError error);
    void handleFetchDividendDates();
    void handleDividendDataUpdateCompleted(int);

#ifdef UNIT_TEST
    friend class IngDibaBackendTests; // to test non public methods
#endif
};

#endif // DIVVYDIARY_H
