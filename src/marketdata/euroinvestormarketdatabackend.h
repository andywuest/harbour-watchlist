#ifndef EUROINVESTORMARKETDATABACKEND_H
#define EUROINVESTORMARKETDATABACKEND_H

#include <QObject>
#include <QNetworkReply>
#include <QNetworkAccessManager>

const char TODO_MIME_TYPE_JSON[] = "application/json";
const char TODO_USER_AGENT[] = "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:73.0) Gecko/20100101 Firefox/73.0";
const char API_MARKET_DATA[] = "https://api.euroinvestor.dk/instruments?ids=";

class EuroinvestorMarketDataBackend : public QObject {
  Q_OBJECT
public:
    explicit EuroinvestorMarketDataBackend(QNetworkAccessManager *manager, const QString &applicationName, const QString applicationVersion, QObject *parent = 0);
    ~EuroinvestorMarketDataBackend();

    Q_INVOKABLE void lookupMarketData(const QString &marketDataIds);
    Q_INVOKABLE QString getMarketDataExtRefId(const QString &marketDataId);

    // signals for the qml part
    Q_SIGNAL void marketDataResultAvailable(const QString &reply);
    Q_SIGNAL void requestError(const QString &errorMessage);

protected:

    QString applicationName;
    QString applicationVersion;
    QNetworkAccessManager *manager;

    QNetworkReply *executeGetRequest(const QUrl &url);

private:

    QMap<QString, QString> marketDataId2ExtRefId;

    QString processMarketDataResult(QByteArray marketDataResult);

protected slots:

    void handleRequestError(QNetworkReply::NetworkError error);

private slots:
    void handleLookupMarketDataFinished();

};


#endif // EUROINVESTORMARKETDATABACKEND_H
