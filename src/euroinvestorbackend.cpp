#include "euroinvestorbackend.h"

#include <QDebug>
#include <QFile>
#include <QUrl>
#include <QUrlQuery>
#include <QUuid>
#include <QCryptographicHash>
#include <QStandardPaths>
#include <QJsonObject>
#include <QJsonArray>
#include <QDateTime>
#include <QtDBus/QDBusConnection>
#include <QtDBus/QDBusInterface>

EuroinvestorBackend::EuroinvestorBackend(QNetworkAccessManager *manager, const QString &applicationName, const QString applicationVersion, QObject *parent) : QObject(parent) {
    qDebug() << "Initializing Euroinvestor Backend...";
        this->manager = manager;
        this->applicationName = applicationName;
        this->applicationVersion = applicationVersion;
}

EuroinvestorBackend::~EuroinvestorBackend() {
    qDebug() << "Shutting down Euroinvestor Backend...";
}

void EuroinvestorBackend::searchName(const QString &searchString) {
    qDebug() << "EuroinvestorBackend::searchName";
        QUrl url = QUrl(API_SEARCH + searchString);
        QNetworkRequest request(url);
        request.setHeader(QNetworkRequest::ContentTypeHeader, MIME_TYPE_JSON);

        QNetworkReply *reply = manager->get(request);

        connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(handleSearchError(QNetworkReply::NetworkError)));
        connect(reply, SIGNAL(finished()), this, SLOT(handleSearchNameFinished()));
}

void EuroinvestorBackend::searchQuote(const QString &searchString) {
    qDebug() << "EuroinvestorBackend::searchQuote";
        QUrl url = QUrl(API_QUOTE + searchString);
        QNetworkRequest request(url);
        request.setHeader(QNetworkRequest::ContentTypeHeader, MIME_TYPE_JSON);

        QNetworkReply *reply = manager->get(request);

        connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(handleSearchError(QNetworkReply::NetworkError)));
        connect(reply, SIGNAL(finished()), this, SLOT(handleSearchQuoteFinished()));
}


void EuroinvestorBackend::handleSearchError(QNetworkReply::NetworkError error)
{
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    qWarning() << "EuroinvestorBackend::handleSearchError:" << (int)error << reply->errorString() << reply->readAll();

//    if (error == QNetworkReply::ContentConflictError) { // Conflict = Registration already there!
//        qDebug() << "[Wagnis] Installation already registered!";
//        this->getApplicationRegistration();
//    } else {
//        emit registrationError(QString::number((int)error) + "Return code: " + " - " + reply->errorString());
//    }
}

void EuroinvestorBackend::handleSearchNameFinished()
{
    qDebug() << "EuroinvestorBackend::handleSearchNameFinished";
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    reply->deleteLater();
    if (reply->error() != QNetworkReply::NoError) {
        return;
    }

    QByteArray registrationReply = reply->readAll();
    qDebug() << "Wagnis::validateRegistrationData";
    QJsonDocument jsonDocument = QJsonDocument::fromJson(registrationReply);
    if (jsonDocument.isArray()) {
        QJsonArray responseArray = jsonDocument.array();
        qDebug() << "array size : " << responseArray.size();

        QStringList idList;

        foreach (const QJsonValue & value, responseArray) {
            QJsonObject rootObject = value.toObject();
            QJsonObject sourceObject = rootObject["_source"].toObject();
            idList.append(QString::number(sourceObject.value("id").toInt()));
        }

        QString quoteQueryIds = idList.join(",");

        qDebug() << "EuroinvestorBackend::handleSearchNameFinished - quoteQueryIds : " << quoteQueryIds;

        searchQuote(quoteQueryIds);

    } else {
        qDebug() << "not a json object !";
    }
}

void EuroinvestorBackend::handleSearchQuoteFinished()
{
    qDebug() << "EuroinvestorBackend::handleSearchQuoteFinished";
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    reply->deleteLater();
    if (reply->error() != QNetworkReply::NoError) {
        return;
    }

    QByteArray registrationReply = reply->readAll();
    qDebug() << "EuroinvestorBackend::validateRegistrationData";
    QJsonDocument jsonDocument = QJsonDocument::fromJson(registrationReply);
    if (jsonDocument.isArray()) {
        QJsonArray responseArray = jsonDocument.array();
        qDebug() << "array size : " << responseArray.size();

        QJsonDocument resultDocument;
        QJsonArray resultArray;

        foreach (const QJsonValue & value, responseArray) {
            QJsonObject rootObject = value.toObject();
            QJsonObject exchangeObject = rootObject["exchange"].toObject();

            QJsonObject resultObject;
            resultObject.insert("extRefId", rootObject.value("id"));
            resultObject.insert("name", rootObject.value("name"));
            resultObject.insert("currency", rootObject.value("currency"));
            resultObject.insert("price", rootObject.value("last"));
            resultObject.insert("symbol1", rootObject.value("symbol"));
            resultObject.insert("isin", rootObject.value("isin"));
            resultObject.insert("stockMarketName", exchangeObject.value("name"));

            // TODO map the rest

            resultArray.push_back(resultObject);
        }

        resultDocument.setArray(resultArray);
        QString dataToString(resultDocument.toJson());
        emit searchResultAvailable(dataToString);

    } else {
        qDebug() << "not a json object !";
    }
}
