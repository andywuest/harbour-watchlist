#include "watchlist.h"

Watchlist::Watchlist(QObject *parent) : QObject(parent), settings("harbour-watchlist", "settings")
{
  this->networkAccessManager = new QNetworkAccessManager(this);
   euroinvestorBackend = new EuroinvestorBackend(this->networkAccessManager, "harbour-zaster", "0.2", this);
}

Watchlist::~Watchlist() {
}

EuroinvestorBackend *Watchlist::getEuroinvestorBackend() {
    return this->euroinvestorBackend;
}
