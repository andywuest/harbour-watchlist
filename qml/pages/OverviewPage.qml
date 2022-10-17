/*
 * harbour-watchlist - Sailfish OS Version
 * Copyright © 2017 Andreas Wüst (andreas.wuest.freelancer@gmail.com)
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
import QtQuick 2.2
import QtQuick.LocalStorage 2.0
import Sailfish.Silica 1.0
import Nemo.Notifications 1.0

import "../components"

import "../js/database.js" as Database
import "../js/functions.js" as Functions

Page {
    id: overviewPage

    readonly property int dividendsUpdateDays: 3 // allow update only every x days
    property int watchlistId: 1
    allowedOrientations: Orientation.Portrait // so far only Portait mode

    property int activeTabId: 0

    function openTab(tabId) {
        activeTabId = tabId

        switch (tabId) {
        case 0:
            marketdataButtonPortrait.isActive = true
            watchlistButtonPortrait.isActive = false
            dividendsButtonPortrait.isActive = false
            break
        case 1:
            marketdataButtonPortrait.isActive = false
            watchlistButtonPortrait.isActive = true
            dividendsButtonPortrait.isActive = false
            break
        case 2:
            marketdataButtonPortrait.isActive = false
            watchlistButtonPortrait.isActive = false
            dividendsButtonPortrait.isActive = true
            break
        default:
            Functions.log("[OverviewPage] Some strange navigation happened!")
        }
    }

    function getNavigationRowSize() {
        return Theme.iconSizeMedium + Theme.fontSizeMedium + Theme.paddingMedium
    }

    function handleMarketdataClicked() {
        if (overviewPage.activeTabId === 0) {
            marketdataView.scrollToTop()
        } else {
            viewsSlideshow.opacity = 0
            slideshowVisibleTimer.goToTab(0)
            openTab(0)
        }
    }

    function handleWatchlistClicked() {
        if (overviewPage.activeTabId === 1) {
            watchlistView.scrollToTop()
        } else {
            viewsSlideshow.opacity = 0
            slideshowVisibleTimer.goToTab(1)
            openTab(1)
        }
    }

    function handleDividendsClicked() {
        if (overviewPage.activeTabId === 2) {
            watchlistView.scrollToTop()
        } else {
            viewsSlideshow.opacity = 0
            slideshowVisibleTimer.goToTab(2)
            openTab(2)
        }
    }

    function isDividendUpdateLongEnoughInThePast() {
        // allow updates every x days
        var refDatePassed = new Date(new Date().setDate(new Date().getDate() - dividendsUpdateDays))
        Functions.log("[OverviewPage] dividend last update : " + watchlistSettings.dividendsDataLastUpdate)
        Functions.log("[OverviewPage] dividend calculated ref date : " + refDatePassed);
        Functions.log("[OverviewPage] now : " + new Date())
        if (watchlistSettings.dividendsDataLastUpdate && Functions.isValidDate(watchlistSettings.dividendsDataLastUpdate)) {
            return (watchlistSettings.dividendsDataLastUpdate < refDatePassed);
        }
        return true;
    }

    function reloadOverviewSecurities() {
        Functions.log("[OverviewPage] reload Overview Securities !");
        watchlistView.reloadAllStocks(); // reload to get the new extRefId
        watchlistView.updateQuotes(); // also update the displayed names and prices
        watchlistView.disconnectSlots(); // reconnect slots for new backend
        watchlistView.connectSlots();
    }

    onStatusChanged: {
        if (status === PageStatus.Active) {
            // TODO this comparison sucks, because it does not properly detect when a stock is changed
            // TODO also we are selecting twice the securities of the watchlist
            // TODO we need a better way to indicate security changes
            var watchlistItemCount = Database.loadAllStockData(watchlistId, Database.SORT_BY_CHANGE_ASC).length;
            if (watchlistItemCount !== watchlistView.getWatchlistItemCount()) {
                watchlistView.reloadAllStocks();
            }
            var marketDataItemCount = Database.loadAllMarketData().length;
            if (marketDataItemCount !== marketdataView.getMarketDataItemCount()) {
                marketdataView.reloadAllMarketData();
            }

            console.log("overview page active");
        }
    }

    SilicaFlickable {
        id: overviewContainer
        anchors.fill: parent
        visible: true
        contentHeight: parent.height
        contentWidth: parent.width

        PullDownMenu {
            MenuItem {
                //: OverviewPage about menu item
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                //: OverviewPage settings menu item
                text: qsTr("Settings")
                onClicked: {
                    var settingsPage = pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
                    settingsPage.reloadOverviewSecurities.connect(reloadOverviewSecurities)
                }
            }
            MenuItem {
                //: OverviewPage settings menu item
                text: qsTr("Add market data")
                visible: activeTabId == 0
                onClicked: {
                    var dialog = pageStack.push(Qt.resolvedUrl("AddMarketDataPage.qml"))
                }
            }
            MenuItem {
                //: OverviewPage refresh market data menu item
                text: qsTr("Refresh market data")
                visible: activeTabId == 0 && marketdataView.isMarketDataNotEmpty()
                onClicked: {
                    console.log("Refresh market data")
                    marketdataView.updateMarketData()
                }
            }
            MenuItem {
                //: OverviewPage add stock menu item
                text: qsTr("Add stock")
                visible: activeTabId == 1
                onClicked: {
                    var dialog = pageStack.push(Qt.resolvedUrl("AddStockPage.qml"))
                }
            }
            MenuItem {
                //: OverviewPage refresh all quotes menu item
                text: qsTr("Refresh all quotes")
                visible: activeTabId == 1 && watchlistView.isWatchlistNotEmpty()
                onClicked: {
                    console.log("Refresh quotes ")
                    watchlistView.updateQuotes()
                }
            }
            MenuItem {
                //: OverviewPage refresh all quotes menu item
                text: qsTr("Refresh dividend dates")
                visible: activeTabId == 2 && isDividendUpdateLongEnoughInThePast()
                onClicked: dividendsView.updateDividendDates()
            }
        }

        Column {
            id: overviewColumn
            visible: true
            width: parent.width
            height: parent.height

            Behavior on opacity {
                NumberAnimation {
                }
            }

            Row {
                id: overviewRow
                width: parent.width
                height: parent.height - getNavigationRowSize() // - overviewColumnHeader.height
                spacing: Theme.paddingSmall

                VisualItemModel {
                    id: viewsModel

                    Item {
                        id: marketdataColumn
                        width: viewsSlideshow.width
                        height: viewsSlideshow.height

                        MarketdataView {
                            id: marketdataView
                            width: parent.width
                            height: parent.height
                        }
                    }

                    Item {
                        id: watchlistColumn
                        width: viewsSlideshow.width
                        height: viewsSlideshow.height

                        WatchlistView {
                            id: watchlistView
                            width: parent.width
                            height: parent.height
                        }
                    }

                    Item {
                        id: dividendsColumn
                        width: viewsSlideshow.width
                        height: viewsSlideshow.height

                        DividendsView {
                            id: dividendsView
                            width: parent.width
                            height: parent.height
                        }
                    }
                }

                Timer {
                    id: slideshowVisibleTimer
                    property int tabId: 0
                    interval: 50
                    repeat: false
                    onTriggered: {
                        viewsSlideshow.positionViewAtIndex(
                                    tabId, PathView.SnapPosition)
                        viewsSlideshow.opacity = 1
                    }
                    function goToTab(newTabId) {
                        tabId = newTabId
                        start()
                    }
                }

                SlideshowView {
                    id: viewsSlideshow
                    width: parent.width
                    height: parent.height
                    itemWidth: width
                    clip: true
                    model: viewsModel
                    onCurrentIndexChanged: {
                        openTab(currentIndex)
                    }
                    Behavior on opacity {
                        NumberAnimation {
                        }
                    }
                    onOpacityChanged: {
                        if (opacity === 0) {
                            slideshowVisibleTimer.start()
                        }
                    }
                }
            }

            Column {
                id: navigationRow
                width: parent.width
                height: overviewPage.isPortrait ? getNavigationRowSize() : 0
                visible: true // overviewPage.isPortrait
                Column {
                    id: navigationRowSeparatorColumn
                    width: parent.width
                    height: Theme.paddingMedium
                    Separator {
                        id: navigationRowSeparator
                        width: parent.width
                        color: Theme.primaryColor
                        horizontalAlignment: Qt.AlignHCenter
                    }
                }

                Row {
                    y: Theme.paddingSmall
                    width: parent.width
                    Item {
                        id: marketdataButtonColumn
                        width: parent.width / 3
                        height: parent.height - Theme.paddingMedium
                        NavigationRowButton {
                            id: marketdataButtonPortrait
                            anchors.top: parent.top
                            buttonText: qsTr("Market data")
                            iconSource: "image://theme/icon-m-home"

                            function runOnClick() {
                                handleMarketdataClicked()
                            }
                        }
                    }
                    Item {
                        id: watchlistButtonColumn
                        width: parent.width / 3
                        height: parent.height - navigationRowSeparator.height
                        NavigationRowButton {
                            id: watchlistButtonPortrait
                            anchors.top: parent.top
                            buttonText: qsTr("Watchlist")
                            iconSource: "image://theme/icon-m-note"

                            function runOnClick() {
                                handleWatchlistClicked()
                            }
                        }
                    }
                    Item {
                        id: dividendsButtonColumn
                        width: parent.width / 3
                        height: parent.height - navigationRowSeparator.height
                        NavigationRowButton {
                            id: dividendsButtonPortrait
                            anchors.top: parent.top
                            buttonText: qsTr("Dividends")
                            iconSource: "image://theme/icon-m-events"

                            function runOnClick() {
                                handleDividendsClicked()
                            }
                        }
                    }
                }
            }
        }

        Component.onCompleted: {
            Database.initApplicationTables();
            openTab(0)
        }

    }
}
