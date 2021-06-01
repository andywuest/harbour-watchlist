#ifndef ING_DIBA_NEWS_H
#define ING_DIBA_NEWS_H

#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QObject>

class IngDibaNews : public QObject {
    Q_OBJECT
public:
    explicit IngDibaNews(QNetworkAccessManager *manager, QObject *parent = nullptr);
    ~IngDibaNews();
    Q_INVOKABLE void searchStockNews(const QString &isin);

    Q_SIGNAL void searchNewsResultAvailable(const QString &reply);
    Q_SIGNAL void requestError(const QString &errorMessage);

signals:

protected:

    QString processSearchResult(QByteArray searchReply);

public slots:

private:
    QNetworkAccessManager *manager;
    QNetworkReply *executeGetRequest(const QUrl &url);
    QString filterContent(QString &content);

private slots:
    void handleRequestError(QNetworkReply::NetworkError error);
    void handleSearchStockNews();
};

#endif // ING_DIBA_NEWS_H
