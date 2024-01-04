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
#ifndef INGMARKETDATABACKEND_H
#define INGMARKETDATABACKEND_H

#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QObject>

class IngMarketDataBackend : public QObject {
    Q_OBJECT
public:
    explicit IngMarketDataBackend(QNetworkAccessManager *manager, QObject *parent = nullptr);
    ~IngMarketDataBackend();

    Q_INVOKABLE void lookupMarketData(const QString &marketDataIds);
    Q_INVOKABLE QString getMarketDataExtRefId(const QString &marketDataId);

    // signals for the qml part
    Q_SIGNAL void marketDataResultAvailable(const QString &reply);
    Q_SIGNAL void requestError(const QString &errorMessage);

protected:
    QNetworkAccessManager *manager;

    QNetworkReply *executeGetRequest(const QUrl &url);

    void connectErrorSlot(QNetworkReply *reply);

private:
    QMap<QString, QString> marketDataId2ExtRefId;
    QMap<QString, QString> extRefIdToIsinMap;

    int numberOfRequestedIds = 0;
    QList<QJsonObject> searchQuoteResults;

    QJsonObject processQuoteResultSingle(QByteArray searchQuoteReply);

    // TODO next two methods are also in the euroinvestor backend hierarchy - needs to be consolidated
    QString convertToDatabaseDateTimeFormat(const QDateTime &time);
    QDateTime convertUTCDateTimeToLocalDateTime(const QString &utcDateTimeString);

protected slots:

    // TODO also in the euroinvestor backend hierarchy - needs to be consolidated
    void handleRequestError(QNetworkReply::NetworkError error);

private slots:
    void handleLookupMarketDataFinished();
};

#endif // INGMARKETDATABACKEND_H
