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
#include "watchlisttests.h"
#include <QtTest/QtTest>

void WatchlistTests::init() {
    ingDibaBackend = new IngDibaBackend(nullptr, nullptr);
    ingDibaNews = new IngDibaNews(nullptr, nullptr);
    dividendDataUpdateWorker = new DividendDataUpdateWorker(nullptr);
}

void WatchlistTests::testIngDibaUtilsConvertTimestampToLocalTimestamp() {
    qDebug() << "dir : " << QCoreApplication::applicationFilePath();
    qDebug() << "Timezone for test : " << QTimeZone::systemTimeZone();
    QString testDate = QString("2020-10-14T20:22:24+02:00");
    QTimeZone testTimeZone = QTimeZone("Europe/Berlin");
    QDateTime convertedDateTime = IngDibaUtils::convertTimestampToLocalTimestamp(testDate, testTimeZone);
    QString dateTimeFormatted = convertedDateTime.toString("yyyy-MM-dd") + " " + convertedDateTime.toString("hh:mm:ss");
    QCOMPARE(dateTimeFormatted, QString("2020-10-14 20:22:24"));
}

void WatchlistTests::testIngDibaBackendIsValidSecurityCategory() {
    QCOMPARE(ingDibaBackend->isValidSecurityCategory("Fonds"), true);
    QCOMPARE(ingDibaBackend->isValidSecurityCategory("Aktien"), true);
    QCOMPARE(ingDibaBackend->isValidSecurityCategory("etfs"), true);
    QCOMPARE(ingDibaBackend->isValidSecurityCategory("NIX"), false);
}

void WatchlistTests::testIngDibaBackendProcessSearchResult() {
    QByteArray data = readFileData("ie00b57x3v84.json");
    if (data.isEmpty()) {
        QFAIL("Testfile ie00b57x3v84.json not found!");
    }

    QString parsedResult = ingDibaBackend->processSearchResult(data);
    QJsonDocument jsonDocument = QJsonDocument::fromJson(parsedResult.toUtf8());
    QCOMPARE(jsonDocument.isArray(), true);
    QJsonArray resultArray = jsonDocument.array();
    QCOMPARE(resultArray.size(), 1);
}

void WatchlistTests::testIngDibaNewsProcessSearchResult() {
    QByteArray data = readFileData("ing_news.json");
    if (data.isEmpty()) {
        QFAIL("Testfile ing_news.json not found!");
    }

    QString parsedResult = ingDibaNews->processSearchResult(data);
    QJsonDocument jsonDocument = QJsonDocument::fromJson(parsedResult.toUtf8());
    QCOMPARE(jsonDocument.isObject(), true);

    QJsonArray resultArray = jsonDocument["newsItems"].toArray();
    QCOMPARE(resultArray.size(), 8);

    QJsonObject newsEntry = resultArray.at(0).toObject();
    QCOMPARE(newsEntry["source"], "DJN.576664");
    QCOMPARE(newsEntry["headline"], "Merkel-Vertraute reisen nach Washington zu Gesprächen über Nord Stream 2");
    QCOMPARE(newsEntry["dateTime"], "Di. Juni 1 01:00:00 2021"); // TODO richtiger conversion fehlt noch

    // TODO QCOMPARE first news data entry
}

void WatchlistTests::testIngDibaNewsFilterContent() {
    QString content = "<p>\n  FRANKFURT (Dow Jones)--In der deutschen  </p>\n<p>\n  Die Vereinigten Staaten .. Lage "
                      "wünschenswert. </p>\n<p>\n  Kontakt zum Autor: unternehmen.de@dowjones.com </p>\n<p>\n  DJG/sha "
                      "</p>\n<p>\n  (END) <a href=\"/DE/Showpage.aspx?pageID=45&ISIN=US2605661048&\" title=\"Übersicht "
                      "Dow Jones\">Dow Jones</a> Newswires</p>\n<p>\n  July 04, 2021 11:10 ET (15:10 GMT)</p>";
    const QString expectedContent
        = " FRANKFURT (Dow Jones)--In der deutschen Die Vereinigten Staaten .. Lage wünschenswert. Kontakt zum Autor: "
          "unternehmen.de@dowjones.com DJG/sha (END) Dow Jones Newswires July 04, 2021 11:10 ET (15:10 GMT) ";
    QCOMPARE(ingDibaNews->filterContent(content), expectedContent);
}

void WatchlistTests::testDividendDataUpdateWorkerCalculateConvertedAmount() {
    // given
    QMap<QString, QVariant> exchangeRateMap;
    exchangeRateMap.insert("USD", 0.8);
    exchangeRateMap.insert("CHF", 1.2);
    dividendDataUpdateWorker->setParameters(QJsonDocument(), exchangeRateMap);

    // when - then
    QCOMPARE(dividendDataUpdateWorker->calculateConvertedAmount(1.6, QString("EUR")), 1.6);
    QCOMPARE(dividendDataUpdateWorker->calculateConvertedAmount(1.4, QString("EUR")), 1.4);
    QCOMPARE(dividendDataUpdateWorker->calculateConvertedAmount(2.0, QString("USD")), 2.5);
    QCOMPARE(dividendDataUpdateWorker->calculateConvertedAmount(6, QString("CHF")), 5);
    QCOMPARE(dividendDataUpdateWorker->calculateConvertedAmount(1.4, QString("GBP")), 0.0);
}

QByteArray WatchlistTests::readFileData(const QString &fileName) {
    QFile f("testdata/" + fileName);
    if (!f.open(QFile::ReadOnly | QFile::Text)) {
        QString msg = "Testfile " + fileName + " not found!";
        return QByteArray();
    }

    QTextStream in(&f);
    return in.readAll().toUtf8();
}
