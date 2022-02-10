/*
 * harbour-watchlist - Sailfish OS Version
 * Copyright © 2020 Andreas Wüst (andreas.wuest.freelancer@gmail.com)
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
#include "abstractdatabackend.h"
#include "../constants.h"

#include <QDebug>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>

AbstractDataBackend::AbstractDataBackend(QNetworkAccessManager *manager, QObject *parent)
    : QObject(parent) {
    qDebug() << "Initializing Data Backend...";
    this->manager = manager;
}

AbstractDataBackend::~AbstractDataBackend() {
    qDebug() << "Shutting down AbstractDataBackend...";
}

QNetworkReply *AbstractDataBackend::executeGetRequest(const QUrl &url) {
    qDebug() << "AbstractDataBackend::executeGetRequest " << url;
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, MIME_TYPE_JSON);
    request.setHeader(QNetworkRequest::UserAgentHeader, USER_AGENT);

    return manager->get(request);
}

void AbstractDataBackend::connectErrorSlot(QNetworkReply *reply) {
    // connect the error and also emit the error signal via a lambda expression
    connect(reply,
            static_cast<void (QNetworkReply::*)(QNetworkReply::NetworkError)>(&QNetworkReply::error),
            [=](QNetworkReply::NetworkError error) {
                // TODO test reply->deleteLater();
                qWarning() << "AbstractDataBackend::handleRequestError:" << static_cast<int>(error)
                           << reply->errorString() << reply->readAll();
                emit requestError("Return code: " + QString::number(static_cast<int>(error)) + " - "
                                  + reply->errorString());
            });
}

QDate AbstractDataBackend::getStartDateForChart(const int chartType) {
    QDate today = QDate::currentDate();
    QDate startDate;
    switch (chartType) {
    case ChartType::INTRADAY:
        break;
    case ChartType::MONTH:
        startDate = today.addMonths(-1);
        break;
    case ChartType::THREE_MONTHS:
        startDate = today.addMonths(-3);
        break;
    case ChartType::YEAR:
        startDate = today.addYears(-1);
        break;
    case ChartType::THREE_YEARS:
        startDate = today.addYears(-3);
        break;
    case ChartType::FIVE_YEARS:
        startDate = today.addYears(-5);
        break;
    }
    return startDate;
}

QString AbstractDataBackend::convertToDatabaseDateTimeFormat(const QDateTime &time) {
    return time.toString("yyyy-MM-dd") + " " + time.toString("hh:mm:ss");
}

bool AbstractDataBackend::isChartTypeSupported(const int chartTypeToCheck) {
    return (chartTypeToCheck == (supportedChartTypes & chartTypeToCheck));
}

QJsonObject AbstractDataBackend::createChartDataPoint(qint64 mSecsSinceEpoch, double priceValue) {
    QJsonObject resultObject;
    resultObject.insert("x", mSecsSinceEpoch / 1000);
    resultObject.insert("y", priceValue);
    return resultObject;
}

QString AbstractDataBackend::createChartResponseString(QJsonArray resultArray, ChartDataCalculator chartDataCalculator) {
    QJsonObject resultObject;
    resultObject.insert("min", chartDataCalculator.getMinValue());
    resultObject.insert("max", chartDataCalculator.getMaxValue());
    resultObject.insert("fractionDigits", chartDataCalculator.getFractionDigits());
    resultObject.insert("data", resultArray);

    QJsonDocument resultDocument;
    resultDocument.setObject(resultObject);

    QString dataToString(resultDocument.toJson());
    return dataToString;
}
