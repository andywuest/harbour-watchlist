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
#include "ingdibabackendtests.h"
#include <QtTest/QtTest>

// TODO rename
void IngDibaBackendTests::init() {
    ingDibaBackend = new IngDibaBackend(nullptr, nullptr);
    ingDibaNews = new IngDibaNews(nullptr, nullptr);
}

void IngDibaBackendTests::testIngDibaUtilsConvertTimestampToLocalTimestamp() {
    qDebug() << "dir : " << QCoreApplication::applicationFilePath();
    qDebug() << "Timezone for test : " << QTimeZone::systemTimeZone();
    QString testDate = QString("2020-10-14T20:22:24+02:00");
    QTimeZone testTimeZone = QTimeZone("Europe/Berlin");
    QDateTime convertedDateTime = IngDibaUtils::convertTimestampToLocalTimestamp(testDate, testTimeZone);
    QString dateTimeFormatted = convertedDateTime.toString("yyyy-MM-dd") + " " + convertedDateTime.toString("hh:mm:ss");
    QCOMPARE(dateTimeFormatted, QString("2020-10-14 20:22:24"));
}

void IngDibaBackendTests::testIngDibaBackendIsValidSecurityCategory() {
    QCOMPARE(ingDibaBackend->isValidSecurityCategory("Fonds"), true);
    QCOMPARE(ingDibaBackend->isValidSecurityCategory("Aktien"), true);
    QCOMPARE(ingDibaBackend->isValidSecurityCategory("etfs"), true);
    QCOMPARE(ingDibaBackend->isValidSecurityCategory("NIX"), false);
}

void IngDibaBackendTests::testIngDibaBackendProcessSearchResult() {
    // TODO use readFileData

    QString testFile = "ie00b57x3v84.json";
    QFile f("testdata/" + testFile);
    if (!f.open(QFile::ReadOnly | QFile::Text)) {
        QString msg = "Testfile " + testFile + " not found!";
        QFAIL(msg.toLocal8Bit().data());
    }

    QTextStream in(&f);
    QByteArray data = in.readAll().toUtf8();
    QString parsedResult = ingDibaBackend->processSearchResult(data);
    QJsonDocument jsonDocument = QJsonDocument::fromJson(parsedResult.toUtf8());
    QCOMPARE(jsonDocument.isArray(), true);
    QJsonArray resultArray = jsonDocument.array();
    QCOMPARE(resultArray.size(), 1);
}

void IngDibaBackendTests::testIngDibaNewsProcessSearchResult() {
    QByteArray data = readFileData("ing_news.json");
    if (data.isEmpty()) {
        QString msg = "Testfile ing_news.json not found!";
        QFAIL(msg.toLocal8Bit().data());
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

void IngDibaBackendTests::testIngDibaNewsFilterContent() {
    QString content = "<p>\n  FRANKFURT (Dow Jones)--In der deutschen  </p>\n<p>\n  Die Vereinigten Staaten .. Lage "
                      "wünschenswert. </p>\n<p>\n  Kontakt zum Autor: unternehmen.de@dowjones.com </p>\n<p>\n  DJG/sha "
                      "</p>\n<p>\n  (END) <a href=\"/DE/Showpage.aspx?pageID=45&ISIN=US2605661048&\" title=\"Übersicht "
                      "Dow Jones\">Dow Jones</a> Newswires</p>\n<p>\n  July 04, 2021 11:10 ET (15:10 GMT)</p>";
    const QString expectedContent
        = " FRANKFURT (Dow Jones)--In der deutschen Die Vereinigten Staaten .. Lage wünschenswert. Kontakt zum Autor: "
          "unternehmen.de@dowjones.com DJG/sha (END) Dow Jones Newswires July 04, 2021 11:10 ET (15:10 GMT) ";
    QCOMPARE(ingDibaNews->filterContent(content), expectedContent);
}

QByteArray IngDibaBackendTests::readFileData(const QString &fileName) {
    QFile f("testdata/" + fileName);
    if (!f.open(QFile::ReadOnly | QFile::Text)) {
        QString msg = "Testfile " + fileName + " not found!";
        return QByteArray();
    }

    QTextStream in(&f);
    return in.readAll().toUtf8();
}
