#ifndef WATCHLIST_H
#define WATCHLIST_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QSettings>

#include "euroinvestorbackend.h"

class Watchlist : public QObject
{
    Q_OBJECT
public:
    explicit Watchlist(QObject *parent = nullptr);
    ~Watchlist();
    EuroinvestorBackend *getEuroinvestorBackend();

signals:

public slots:

private:private:
    QNetworkAccessManager *networkAccessManager;
    EuroinvestorBackend *euroinvestorBackend;
    QSettings settings;

};

#endif // WATCHLIST_H
