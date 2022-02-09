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
#ifndef DIVIDEND_DATA_UPDATE_WORKER_H
#define DIVIDEND_DATA_UPDATE_WORKER_H

#include <QDebug>
#include <QJsonDocument>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QObject>
#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>
#include <QThread>
#include <QVariantList>

class DividendDataUpdateWorker : public QThread {
    Q_OBJECT
    void run() Q_DECL_OVERRIDE {
        performUpdate();
    }

public:
    explicit DividendDataUpdateWorker(QObject *parent = nullptr);
    ~DividendDataUpdateWorker() override;
    void setParameters(const QJsonDocument &jsonDocument);

signals:
    void updateCompleted(int);

public slots:

private:
    QSqlDatabase database;
    QJsonDocument jsonDocument;

    void performUpdate();
    void executeQuery(const QString &queryString, const QMap<QString, QVariant> &dataMap);
};

#endif // DIVIDEND_DATA_UPDATE_WORKER_H
