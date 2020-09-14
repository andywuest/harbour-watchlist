#ifndef EUROINVESTORMARKETDATABACKEND_H
#define EUROINVESTORMARKETDATABACKEND_H

#include <QObject>
#include <QNetworkReply>
#include <QNetworkAccessManager>

const char API_MARKET_DATA[] = "https://api.euroinvestor.dk/instruments?ids=";

class EuroinvestorMarketDataBackend : public QObject {
  Q_OBJECT
public:
    explicit EuroinvestorMarketDataBackend(QNetworkAccessManager *manager, QObject *parent = 0);
    ~EuroinvestorMarketDataBackend();

    Q_INVOKABLE void lookupMarketData(const QString &marketDataIds);
    Q_INVOKABLE QString getMarketDataExtRefId(const QString &marketDataId);

    // signals for the qml part
    Q_SIGNAL void marketDataResultAvailable(const QString &reply);
    Q_SIGNAL void requestError(const QString &errorMessage);

protected:

    QNetworkAccessManager *manager;

    QNetworkReply *executeGetRequest(const QUrl &url);

private:

    QMap<QString, QString> marketDataId2ExtRefId;

    QString processMarketDataResult(QByteArray marketDataResult);

    // TODO next two methods are also in the euroinvestor backend hierarchy - needs to be consolidated
    QString convertToDatabaseDateTimeFormat(const QDateTime time);
    QDateTime convertUTCDateTimeToLocalDateTime(const QString &utcDateTimeString);

protected slots:

    // TODO also in the euroinvestor backend hierarchy - needs to be consolidated
    void handleRequestError(QNetworkReply::NetworkError error);

private slots:
    void handleLookupMarketDataFinished();

};


#endif // EUROINVESTORMARKETDATABACKEND_H
