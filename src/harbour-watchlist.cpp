/*
 * harbour-watchlist - Sailfish OS Version
 * Copyright © 2019 Andreas Wüst (andreas.wuest.freelancer@gmail.com)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <sailfishapp.h>
#include <QGuiApplication>
#include <QQmlContext>
#include <QQuickView>
#include <QScopedPointer>
#include <QtQml>

#include "watchlist.h"

int main(int argc, char *argv[]) {
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> view(SailfishApp::createView());

    QQmlContext *context = view.data()->rootContext();
    Watchlist watchlist;
    context->setContextProperty("watchlist", &watchlist);

    EuroinvestorBackend *euroinvestorBackend = watchlist.getEuroinvestorBackend();
    context->setContextProperty("euroinvestorBackend", euroinvestorBackend);

    MoscowExchangeBackend *moscowExchangeBackend = watchlist.getMoscowExchangeBackend();
    context->setContextProperty("moscowExchangeBackend", moscowExchangeBackend);

    IngDibaBackend *ingDibaBackend = watchlist.getIngDibaBackend();
    context->setContextProperty("ingDibaBackend", ingDibaBackend);

    EuroinvestorMarketDataBackend *euroinvestorMarketDataBackend = watchlist.getEuroinvestorMarketDataBackend();
    context->setContextProperty("euroinvestorMarketDataBackend", euroinvestorMarketDataBackend);

    // TODO remove me - does not work anymore
    OnvistaNews *onvistaNews = watchlist.getOnvistaNews();
    context->setContextProperty("onvistaNews", onvistaNews);

    context->setContextProperty("applicationVersion", QString(VERSION_NUMBER));

    view->setSource(SailfishApp::pathTo("qml/harbour-watchlist.qml"));
    view->show();
    return app->exec();
}
