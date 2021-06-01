#include "ingdibabackendtests.h"
#include <QtTest/QtTest>

void IngDibaBackendTests::init() {
    ingDibaBackend = new IngDibaBackend(nullptr, nullptr);
    ingDibaNews = new IngDibaNews(nullptr, nullptr);
}

void IngDibaBackendTests::testIngDibaBackendConvertTimestampToLocalTimestamp() {
    qDebug() << "dir : " << QCoreApplication::applicationFilePath();
    qDebug() << "Timezone for test : " << QTimeZone::systemTimeZone();
    QString testDate = QString("2020-10-14T20:22:24+02:00");
    QTimeZone testTimeZone = QTimeZone("Europe/Berlin");
    QDateTime convertedDateTime = ingDibaBackend->convertTimestampToLocalTimestamp(testDate, testTimeZone);
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
    QString parsedResult = ingDibaNews->processSearchResult(data);
    QJsonDocument jsonDocument = QJsonDocument::fromJson(parsedResult.toUtf8());
    QCOMPARE(jsonDocument.isArray(), true);
    QJsonArray resultArray = jsonDocument.array();
    QCOMPARE(resultArray.size(), 8);

    QJsonObject newsEntry = resultArray.get(0);
    QCOMPARE(newsEntry["source"], "DJN.576664");
    QCOMPARE(newsEntry["headline"], "Merkel-Vertraute reisen nach Washington zu Gesprächen über Nord Stream 2");
    QCOMPARE(newsEntry["dateTime"], "01.06.2021, 01:00");

    // TODO QCOMPARE first news data entry
}

QByteArray IngDibaBackendTests::readFileData(QString fileName) {
    QFile f("testdata/" + fileName);
    if (!f.open(QFile::ReadOnly | QFile::Text)) {
        QString msg = "Testfile " + testFile + " not found!";
        QFAIL(msg.toLocal8Bit().data());
    }

    QTextStream in(&f);
    return in.readAll().toUtf8();
}