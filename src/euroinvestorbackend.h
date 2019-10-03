#ifndef EUROINVESTORBACKEND_H
#define EUROINVESTORBACKEND_H

#include <QObject>
#include <QNetworkReply>
#include <QNetworkAccessManager>
#include <QVariantMap>
#include <QJsonDocument>

const char MIME_TYPE_JSON[] = "application/json";
const char API_SEARCH[] = "https://search.euroinvestor.dk/instruments?q=";
const char API_QUOTE[] = "https://api.euroinvestor.dk/instruments?ids=";

class EuroinvestorBackend : public QObject
{
    Q_OBJECT
public:
    explicit EuroinvestorBackend(QNetworkAccessManager *manager, const QString &applicationName, const QString applicationVersion, QObject *parent = 0);
    ~EuroinvestorBackend();
    Q_INVOKABLE void searchName(const QString &searchString);
    Q_INVOKABLE void searchQuote(const QString &searchString);

    Q_SIGNAL void searchResultAvailable(const QString & reply);

signals:

public slots:

private:

    QString applicationName;
    QString applicationVersion;
    QString wagnisId;
    QVariantMap ipInfo;
    QVariantMap validatedRegistration;
    int remainingSeconds = 0;
    QNetworkAccessManager *manager;

private slots:
 void handleSearchError(QNetworkReply::NetworkError error);
 void handleSearchNameFinished();
 void handleSearchQuoteFinished();
};

#endif // EUROINVESTORBACKEND_H
