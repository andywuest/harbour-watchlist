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
#ifndef ABSTRACTDATABACKEND_H
#define ABSTRACTDATABACKEND_H

#include <QObject>
#include <QNetworkReply>
#include <QNetworkAccessManager>

class AbstractDataBackend : public QObject {
  Q_OBJECT
public:
    explicit AbstractDataBackend(QNetworkAccessManager *manager, const QString &applicationName, const QString applicationVersion, QObject *parent = 0);
    ~AbstractDataBackend();

    Q_INVOKABLE virtual void searchName(const QString &searchString) = 0;
    Q_INVOKABLE virtual void searchQuote(const QString &searchString) = 0;
    Q_INVOKABLE virtual void fetchPricesForChart(const QString &extRefId, const int chartType) = 0;
    Q_INVOKABLE virtual bool isChartTypeSupported(const int chartType) = 0;

    // signals for the qml part
    Q_SIGNAL void searchResultAvailable(const QString &reply);
    Q_SIGNAL void quoteResultAvailable(const QString &reply);
    Q_SIGNAL void fetchPricesForChartAvailable(const QString &reply, const int chartType);
    Q_SIGNAL void requestError(const QString &errorMessage);

protected:

    QString applicationName;
    QString applicationVersion;
    QNetworkAccessManager *manager;

    enum ChartType {
      INTRADAY = 0,
      MONTH = 1,
      THREE_MONTHS = 2,
      YEAR = 3,
      THREE_YEARS = 4,
      FIVE_YEARS = 5
    };

    virtual QString convertCurrency(const QString &currencyString) = 0;

    QNetworkReply *executeGetRequest(const QUrl &url);
    QDate getStartDateForChart(const int chartType);
    QString convertToDatabaseDateTimeFormat(const QDateTime time);

protected slots:

    void handleRequestError(QNetworkReply::NetworkError error);

};

#endif // ABSTRACTDATABACKEND_H
