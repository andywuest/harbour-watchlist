#ifndef ONVISTANEWS_H
#define ONVISTANEWS_H

#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QObject>

const char API_NEWS_SEARCH[]
    = "https://m.onvista.de/news/boxes/newslist/snapshot.json?assetId=%1&offset=0&blocksize=%2";
const char NEWS_USER_AGENT[] = "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:73.0) Gecko/20100101 Firefox/73.0";

class OnvistaNews : public QObject {
    Q_OBJECT
public:
    explicit OnvistaNews(QNetworkAccessManager *manager, QObject *parent = nullptr);
    ~OnvistaNews();
    Q_INVOKABLE void searchStockNews(const QString &isin);

    Q_SIGNAL void searchNewsResultAvailable(const QString &reply);
    Q_SIGNAL void requestError(const QString &errorMessage);

signals:

protected:
public slots:

private:
    QNetworkAccessManager *manager;
    QNetworkReply *executeGetRequest(const QUrl &url);
    QString filterContent(QString &content);

private slots:
    void handleRequestError(QNetworkReply::NetworkError error);
    void handleSearchStockNews();
};

#endif // ONVISTANEWS_H
