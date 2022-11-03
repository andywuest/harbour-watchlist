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
import QtQml.Models 2.2
import Sailfish.Silica 1.0
import Nemo.Notifications 1.0

import "../components"

import "../js/constants.js" as Constants
import "../js/database.js" as Database
import "../js/functions.js" as Functions

Page {
    id: overviewPage

    readonly property int dividendsUpdateDays: 3 // allow update only every x days
    allowedOrientations: Orientation.Portrait // so far only Portait mode

    property int activeTabId: 0
    property bool secondWatchlistVisible: watchlistSettings.showSecondWatchlist
    property int numberOfTabs: 3 + (secondWatchlistVisible ? 1 : 0)

    function openTab(tabId) {
        activeTabId = tabId
        Functions.log("[OverviewPage] opening tab :" + tabId);

        switch (tabId) {
        case 0:
            marketdataButtonPortrait.isActive = true
            watchlistButtonPortrait.isActive = false
            secondWatchlistButtonPortrait.isActive = false
            dividendsButtonPortrait.isActive = false
            break
        case 1:
            marketdataButtonPortrait.isActive = false
            watchlistButtonPortrait.isActive = true
            secondWatchlistButtonPortrait.isActive = false
            dividendsButtonPortrait.isActive = false
            break
        case 2:
            if (secondWatchlistVisible) {
                marketdataButtonPortrait.isActive = false
                watchlistButtonPortrait.isActive = false
                secondWatchlistButtonPortrait.isActive = true
                dividendsButtonPortrait.isActive = false
            } else {
                marketdataButtonPortrait.isActive = false
                watchlistButtonPortrait.isActive = false
                secondWatchlistButtonPortrait.isActive = false
                dividendsButtonPortrait.isActive = true
            }
            break
        case 3:
            marketdataButtonPortrait.isActive = false
            watchlistButtonPortrait.isActive = false
            secondWatchlistButtonPortrait.isActive = false
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

    function handleSecondWatchlistClicked() {
        var secondWatchListTabIndex = 2;
        if (overviewPage.activeTabId === secondWatchListTabIndex) {
            watchlistView.scrollToTop()
        } else {
            viewsSlideshow.opacity = 0
            slideshowVisibleTimer.goToTab(secondWatchListTabIndex)
            openTab(secondWatchListTabIndex)
        }
    }

    function handleDividendsClicked() {
        var dividendTabIndex = (secondWatchlistVisible ? 3 : 2);
        if (overviewPage.activeTabId === dividendTabIndex) {
            dividendsView.scrollToTop()
        } else {
            viewsSlideshow.opacity = 0
            slideshowVisibleTimer.goToTab(dividendTabIndex)
            openTab(dividendTabIndex)
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

    function securityAdded(updateWatchlistId) {
        Functions.log("[OverviewPage] security has been added to watchlist " + updateWatchlistId);
        if (updateWatchlistId === Constants.WATCHLIST_1) {
            watchlistView.reloadAllStocks();
        }
        if (secondWatchlistVisible && updateWatchlistId === Constants.WATCHLIST_2) {
            secondWatchlistView.reloadAllStocks();
        }
    }

    function repopulateTabs() {
        Functions.log("[OverviewPage] updating the tabs model views");
        viewsModel.clear();
        viewsModel.append(marketdataColumn)
        viewsModel.append(watchlistColumn)
        if (secondWatchlistVisible) {
            viewsModel.append(secondWatchlistColumn)
        }
        viewsModel.append(dividendsColumn)
    }

    onStatusChanged: {
        if (status === PageStatus.Active) {
            var marketDataItemCount = Database.loadAllMarketData().length;
            if (marketDataItemCount !== marketdataView.getMarketDataItemCount()) {
                marketdataView.reloadAllMarketData();
            }

            console.log("overview page active");
        }
    }

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
            watchlistId: Constants.WATCHLIST_1
        }
    }

    Item {
        id: secondWatchlistColumn
        width: viewsSlideshow.width
        height: viewsSlideshow.height
        visible: secondWatchlistVisible

        WatchlistView {
            id: secondWatchlistView
            width: parent.width
            height: parent.height
            watchlistId: Constants.WATCHLIST_2
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
                visible: (activeTabId == 1 || (secondWatchlistVisible && activeTabId == 2))
                onClicked: {
                    var selectedWatchlistId = (activeTabId == 1 ? Constants.WATCHLIST_1 : Constants.WATCHLIST_2);
                    var dialog = pageStack.push(Qt.resolvedUrl("AddStockPage.qml"), { watchlistId: selectedWatchlistId })
                }
            }
            MenuItem {
                //: OverviewPage refresh all quotes menu item
                text: qsTr("Refresh all quotes")
                visible: activeTabId == 1 && watchlistView.isWatchlistNotEmpty()
                onClicked: {
                    Functions.log("Refresh quotes Watchlist 1")
                    watchlistView.updateQuotes()
                }
            }
            MenuItem {
                //: OverviewPage refresh all quotes menu item
                text: qsTr("Refresh all quotes")
                visible: secondWatchlistVisible && activeTabId == 2 && secondWatchlistView.isWatchlistNotEmpty()
                onClicked: {
                    Functions.log("Refresh quotes Watchlist 2")
                    secondWatchlistView.updateQuotes()
                }
            }
            MenuItem {
                //: OverviewPage refresh all quotes menu item
                text: qsTr("Refresh dividend dates")
                visible: activeTabId === (secondWatchlistVisible ? 3 : 2) && isDividendUpdateLongEnoughInThePast()
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

                ObjectModel {
                    id: viewsModel
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
                        width: parent.width / numberOfTabs
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
                        width: parent.width / numberOfTabs
                        height: parent.height - navigationRowSeparator.height
                        NavigationRowButton {
                            id: watchlistButtonPortrait
                            anchors.top: parent.top
                            buttonText: secondWatchlistVisible ? watchlistSettings.firstWatchlistName : qsTr("Watchlist")
                            iconSource: "image://theme/icon-m-note"

                            function runOnClick() {
                                handleWatchlistClicked()
                            }
                        }
                    }
                    Item {
                        id: secondWatchlistButtonColumn
                        width: parent.width / numberOfTabs
                        height: parent.height - navigationRowSeparator.height
                        visible: secondWatchlistVisible
                        NavigationRowButton {
                            id: secondWatchlistButtonPortrait
                            anchors.top: parent.top
                            buttonText: watchlistSettings.secondWatchlistName
                            iconSource: "image://theme/icon-m-note"

                            function runOnClick() {
                                handleSecondWatchlistClicked()
                            }
                        }
                    }
                    Item {
                        id: dividendsButtonColumn
                        width: parent.width / numberOfTabs
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
            app.securityAdded.connect(securityAdded);
            repopulateTabs();
            openTab(0)
        }

    }

    onNumberOfTabsChanged: {
        Functions.log("[OverviewPage] Number of tabs changed to " + numberOfTabs);
        repopulateTabs();
        openTab(0);
        viewsSlideshow.positionViewAtIndex(0, PathView.SnapPosition);
    }

}
