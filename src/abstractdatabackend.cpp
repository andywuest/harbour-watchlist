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
#include "constants.h"
#include "abstractdatabackend.h"

#include <QDebug>
#include <QFile>
#include <QUrl>
#include <QUrlQuery>
#include <QUuid>
#include <QJsonObject>
#include <QJsonArray>
#include <QDateTime>
#include <QVariantMap>
#include <QJsonDocument>

AbstractDataBackend::AbstractDataBackend(QNetworkAccessManager *manager, const QString &applicationName, const QString applicationVersion, QObject *parent) : QObject(parent) {
    qDebug() << "Initializing Data Backend...";
    this->manager = manager;
    this->applicationName = applicationName;
    this->applicationVersion = applicationVersion;
}

AbstractDataBackend::~AbstractDataBackend() {
    qDebug() << "Shutting down Euroinvestor Backend...";
}

QNetworkReply *AbstractDataBackend::executeGetRequest(const QUrl &url) {
    qDebug() << "AbstractDataBackend::executeGetRequest " << url;
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, MIME_TYPE_JSON);
    request.setHeader(QNetworkRequest::UserAgentHeader, USER_AGENT);

    return manager->get(request);
}

void AbstractDataBackend::handleRequestError(QNetworkReply::NetworkError error) {
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    qWarning() << "AbstractDataBackend::handleRequestError:" << static_cast<int>(error) << reply->errorString() << reply->readAll();

    emit requestError("Return code: " + QString::number(static_cast<int>(error)) + " - " + reply->errorString());
}

QDate AbstractDataBackend::getStartDateForChart(const int chartType) {
    QDate today = QDate::currentDate();
    QDate startDate;
    switch(chartType) {
        case ChartType::INTRADAY: break;
        case ChartType::MONTH: startDate = today.addMonths(-1); break;
        case ChartType::THREE_MONTHS: startDate = today.addMonths(-3); break;
        case ChartType::YEAR: startDate = today.addYears(-1); break;
        case ChartType::THREE_YEARS: startDate = today.addYears(-3); break;
        case ChartType::FIVE_YEARS: startDate = today.addYears(-5); break;
    }
    return startDate;
}

QString AbstractDataBackend::convertToDatabaseDateTimeFormat(const QDateTime time) {
    return time.toString("yyyy-MM-dd") + " " + time.toString("hh:mm:ss");
}
