#include <QtTest/QtTest>
#include "ingdibabackendtests.h"

void IngDibaBackendTests::init()
{
  ingDibaBackend = new IngDibaBackend(nullptr, nullptr);
}

void IngDibaBackendTests::testIngConvertTimestampToLocalTimestamp() {
   qDebug() << "dir : " << QCoreApplication::applicationFilePath();
   qDebug() << "Timezone for test : " << QTimeZone::systemTimeZone();
   QString testDate = QString("2020-10-14T20:22:24+02:00");
   QTimeZone testTimeZone = QTimeZone("Europe/Berlin");
   QDateTime convertedDateTime = ingDibaBackend->convertTimestampToLocalTimestamp(testDate, testTimeZone);
   QString dateTimeFormatted = convertedDateTime.toString("yyyy-MM-dd") + " " + convertedDateTime.toString("hh:mm:ss");
   QCOMPARE(dateTimeFormatted, QString("2020-10-14 20:22:24"));
}

void IngDibaBackendTests::testIsValidSecurityCategory() {
    QCOMPARE(ingDibaBackend->isValidSecurityCategory("Fonds"), true);
    QCOMPARE(ingDibaBackend->isValidSecurityCategory("Aktien"), true);
    QCOMPARE(ingDibaBackend->isValidSecurityCategory("etfs"), true);
    QCOMPARE(ingDibaBackend->isValidSecurityCategory("NIX"), false);
}

void IngDibaBackendTests::testProcessSearchResult() {
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
