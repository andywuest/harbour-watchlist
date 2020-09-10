# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-watchlist

CONFIG += sailfishapp

SOURCES += \
    src/securitydata/euroinvestorbackend.cpp \
    src/securitydata/moscowexchangebackend.cpp \
    src/securitydata/ingdibabackend.cpp \
    src/securitydata/abstractdatabackend.cpp \
    src/securitydata/chartdatacalculator.cpp \
    src/marketdata/euroinvestormarketdatabackend.cpp \
    src/harbour-watchlist.cpp \
    src/watchlist.cpp \
    src/onvistanews.cpp

HEADERS += \
    src/constants.h \
    src/securitydata/euroinvestorbackend.h \
    src/securitydata/moscowexchangebackend.h \
    src/securitydata/ingdibabackend.h \
    src/securitydata/abstractdatabackend.h \
    src/securitydata/chartdatacalculator.h \
    src/marketdata/euroinvestormarketdatabackend.h \
    src/watchlist.h \
    src/onvistanews.h

DEFINES += VERSION_NUMBER=\\\"$$(VERSION_NUMBER)\\\"

OTHER_FILES += rpm/harbour-watchlist.changes.in \
    rpm/harbour-watchlist.spec \
    rpm/harbour-watchlist.yaml \
    translations/*.ts \
    harbour-watchlist.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-watchlist-de.ts \
    translations/harbour-watchlist-ru.ts \
    translations/harbour-watchlist-sv.ts \
    translations/harbour-watchlist-zh_CN.ts


DISTFILES += \
    qml/components/AlarmNotification.qml \
    qml/components/EmptyModelColumnLabel.qml \
    qml/components/LabelValueRow.qml \
    qml/components/MarketdataView.qml \
    qml/components/StockChart.qml \
    qml/components/NavigationRowButton.qml \
    qml/components/StockChart.qml \
    qml/components/StockChartsView.qml \
    qml/components/StockDetailsView.qml \
    qml/components/StockNewsView.qml \
    qml/components/WatchlistView.qml \
    qml/components/thirdparty/AppNotification.qml \
    qml/components/thirdparty/AppNotificationItem.qml \
    qml/components/thirdparty/Axis.qml \
    qml/components/thirdparty/GraphData.qml \
    qml/components/thirdparty/LabelText.qml \
    qml/components/thirdparty/LoadingIndicator.qml \
    qml/js/database.js \
    qml/js/constants.js \
    qml/js/functions.js \
    qml/pages/AboutPage.qml \
    qml/pages/AddMarketDataPage.qml \
    qml/pages/AddStockPage.qml \
    qml/pages/OverviewPage.qml \
    qml/pages/SettingsPage.qml \
    qml/pages/StockAlarmDialog.qml \
    qml/pages/StockDetailsPage.qml \
    qml/pages/StockOverviewPage.qml \
    qml/pages/WatchlistPage.qml \
    qml/pages/NewsPage.qml

