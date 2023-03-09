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
#include "constants.h"

void migrateLocalStorage()
{
    // The new location of the LocalStorage database
    QDir newDbDir(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation)
                  + QString("/%1/%2/QML/OfflineStorage/Databases/").arg(ORGANISATION, APP_NAME));

    if (newDbDir.exists()) {
        return;
    }

    newDbDir.mkpath(newDbDir.path());

    QString dbname = QString(QCryptographicHash::hash((APP_NAME), QCryptographicHash::Md5).toHex());

    qDebug() << "dbname: " + dbname;

    QString pathOld = QString("/%1/%1/QML/OfflineStorage/Databases/").arg(APP_NAME);
    QString pathNew = QString("/%1/%2/QML/OfflineStorage/Databases/").arg(ORGANISATION, APP_NAME);

    qDebug() << "pathOld : " << pathOld;
    qDebug() << "pathNew : " << pathNew;

    // The old LocalStorage database
    QFile oldDb(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) +  pathOld + dbname + ".sqlite");
    QFile oldIni(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + pathOld + dbname + ".ini");

    oldDb.copy(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) +  pathNew + dbname + ".sqlite");
    oldIni.copy(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + pathNew + dbname + ".ini");
    // proof of concept you can just move.
    //oldDb.rename(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) +  pathNew + dbname + ".sqlite");
    //oldIni.rename(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + pathNew + dbname + ".ini");
}

int main(int argc, char *argv[]) {
    // first check if we've got the new paths in place
    // this has to be done here, before we assign name below
    migrateLocalStorage();

    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));

    app->setOrganizationDomain(ORGANISATION);
    app->setOrganizationName(ORGANISATION); // needed for Sailjail
    app->setApplicationName(APP_NAME);

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

    context->setContextProperty("ingDibaNews", watchlist.getIngDibaNews());

    context->setContextProperty("divvyDiaryBackend", watchlist.getDivvyDiaryBackend());

    context->setContextProperty("applicationVersion", QString(VERSION_NUMBER));

    view->setSource(SailfishApp::pathTo("qml/harbour-watchlist.qml"));
    view->show();
    return app->exec();
}
