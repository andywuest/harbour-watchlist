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
    src/euroinvestorbackend.cpp \
    src/harbour-watchlist.cpp \
    src/watchlist.cpp

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
    translations/harbour-watchlist-sv.ts \
    translations/harbour-watchlist-zh_CN.ts


DISTFILES += \
    qml/components/LabelText.qml \
    qml/components/LabelValueRow.qml \
    qml/components/StockChart.qml \
    qml/components/AlarmNotification.qml \
    qml/components/thirdparty/AppNotification.qml \
    qml/components/thirdparty/AppNotificationItem.qml \
    qml/components/thirdparty/Axis.qml \
    qml/components/thirdparty/GraphData.qml \
    qml/components/thirdparty/LoadingIndicator.qml \
    qml/js/database.js \
    qml/js/constants.js \
    qml/js/euroinvestor.js \
    qml/js/functions.js \
    qml/pages/SettingsPage.qml \
    qml/pages/StockDetailsPage.qml \
    qml/pages/WatchlistPage.qml \
    qml/pages/AddStockPage.qml \
    qml/pages/AboutPage.qml \
    qml/pages/StockAlarmDialog.qml

HEADERS += \
    src/euroinvestorbackend.h \
    src/watchlist.h
