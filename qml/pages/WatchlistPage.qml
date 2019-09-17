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

// QTBUG-34418
import "."

import "../js/constants.js" as Constants
import "../js/database.js" as Database
import "../js/euroinvestor.js" as Backend
import "../js/functions.js" as Functions

import "../components/thirdparty"

Page {

    id: stockQuotePage
    property real maxChange: 0.0
    property bool loaded : false

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    AppNotification {
        id: stockUpdateProblemNotification
    }

    Item {
        Notification {
            id: stockAlarmNotification
            appName: "Watchlist"
            appIcon: "/usr/share/icons/hicolor/256x256/apps/harbour-watchlist.png"
        }
    }

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {

        anchors.fill: parent
        topMargin: /*errorColumn.visible ? Theme.horizontalPageMargin :*/ 0
        contentWidth: parent.width
        contentHeight: stockQuotesColumn.visible ? stockQuotesColumn.height : stockQuotesColumn.height

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                //: WatchlistPage about menu item
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                //: WatchlistPage add stock menu item
                text: qsTr("Add stock")
                onClicked: {
                    var dialog = pageStack.push(Qt.resolvedUrl("AddStockPage.qml"))
                }
            }
            MenuItem {
                //: WatchlistPage refresh all quotes menu item
                text: qsTr("Refresh all quotes")
                onClicked: {
                    console.log("Refresh quotes ")
                    updateQuotes()
                }
                visible: stocksModel.count > 0
            }
        }

        LoadingIndicator {
            id: stocksLoadingIndicator
            visible: !loaded
            Behavior on opacity {
                NumberAnimation {
                }
            }
            opacity: loaded ? 0 : 1
            height: parent.height
            width: parent.width
        }

        // TODO ( errorColumn.visible ? errorColumn.height : parent.height )
        Column {
            id: stockQuotesColumn
            width: parent.width
            spacing: Theme.paddingMedium

            Behavior on opacity {
                NumberAnimation {
                }
            }
            opacity: visible ? 1 : 0
            visible: true

            PageHeader {
                id: stockQuotesHeader
                //: WatchlistPage page header
                title: qsTr("Stock quotes")
            }

            SilicaListView {
                id: stockQuotesListView

                height: stockQuotePage.height - stockQuotesHeader.height - Theme.paddingMedium
                width: parent.width
                anchors.left: parent.left
                anchors.right: parent.right

                clip: true

                model: ListModel {
                    id: stocksModel
                }

                delegate: ListItem {
                    contentHeight: stockQuoteItem.height + (2 * Theme.paddingMedium)
                    contentWidth: parent.width

                    onClicked: {
                        console.log("Clicked " + index)
                    }

                    menu: ContextMenu {
                        MenuItem {
                            //: WatchlistPage configure alarm menu item
                            text: qsTr("Configure alarm")
                            onClicked: {
                                var selectedStock = stockQuotesListView.model.get(index);
                                pageStack.push(Qt.resolvedUrl("StockAlarmDialog.qml"), { stock: selectedStock })
                            }
                        }
                        MenuItem {
                            //: WatchlistPage remove menu item
                            text: qsTr("Remove")
                            onClicked: deleteStockData(index)
                        }
                    }

                    Item {
                        id: stockQuoteItem
                        width: parent.width
                        height: stockQuoteRow.height + stockQuoteSeparator.height
                        y: Theme.paddingMedium

                        Row {
                            id: stockQuoteRow
                            width: parent.width - (2 * Theme.horizontalPageMargin)
                            spacing: Theme.paddingMedium
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter

                            // TODO custom - hier noch pruefen, was an margins noch machbar, sinnvoll ist
                            Column {
                                id: stockQuoteColumn
                                width: parent.width // - (2 * Theme.horizontalPageMargin)
                                // x: Theme.horizontalPageMargin
                                height: firstRow.height + changeRow.height
                                /* + secondRow.height*/ + thirdRow.height
                                anchors.verticalCenter: parent.verticalCenter

                                Row {
                                    id: firstRow
                                    width: parent.width
                                    height: Theme.fontSizeSmall + Theme.paddingMedium

                                    Text {
                                        id: stockQuoteName
                                        width: parent.width * 8 / 10
                                        height: parent.height
                                        text: name
                                        // truncationMode: TruncationMode.Elide // TODO check for very long texts
                                        color: Theme.primaryColor
                                        font.pixelSize: Theme.fontSizeSmall
                                        font.bold: true
                                        horizontalAlignment: Text.AlignLeft
                                    }

                                    Text {
                                        id: stockQuoteChange
                                        width: parent.width * 2 / 10
                                        height: parent.height
                                        text: Functions.renderPrice(price, currency);
//                                            (price
//                                               !== undefined ? Number(
//                                                                   price).toLocaleString(
//                                                                   Qt.locale(
//                                                                       "de_DE")) + " \u20AC" : "-")

                                        color: Theme.highlightColor
                                        font.pixelSize: Theme.fontSizeSmall
                                        font.bold: true
                                        horizontalAlignment: Text.AlignRight
                                    }
                                }

                                Row {
                                    id: changeRow
                                    width: parent.width
                                    height: 7

                                    Rectangle {
                                        id: changeRowRectangle
                                        width: Functions.calculateWidth(price,
                                                              changeRelative,
                                                              maxChange,
                                                              parent.width)
                                        height: parent.height
                                        color: Functions.determineChangeColor(changeRelative)

                                        /*
                                        function calculateWidth(price, change, maxChange, parentWidth) {
                                            // no price so far -> hide bar by setting with 0
                                            if (price === 0.0) {
                                                return 0;
                                            }
                                            if (maxChange === 0.0) {
                                                return parentWidth
                                            } else {
                                                var result = parentWidth * Math.abs(
                                                            change) / maxChange
                                                console.log("change length: " + result)
                                                return result
                                            }
                                        }
                                        */
                                    }
                                }

                                Row {
                                    id: secondRow
                                    width: parent.width
                                    visible: false
                                    height: Theme.fontSizeMedium + Theme.paddingMedium

                                    //                                    anchors {
                                    //                                        left: parent.left
                                    //                                        right: parent.right
                                    //                                        top: firstRow.bottom
                                    //                                    }
                                    Column {
                                        id: tweetAuthorColumn2
                                        width: parent.width * 3 / 6

                                        // height: parent.width *2 / 6
                                        //spacing: Theme.paddingSmall
                                        Text {
                                            id: title2
                                            text: ""
                                            font.pixelSize: Theme.fontSizeMedium
                                        }
                                    }

                                    Column {
                                        id: tweetContentColumn2
                                        width: parent.width * 3 / 6 //- Theme.horizontalPageMargin

                                        //spacing: Theme.paddingSmall
                                        Text {
                                            id: lastPrice2
                                            text: Functions.renderPrice(price, currency);
//                                                (price
//                                                   !== undefined ? Number(
//                                                                       price).toLocaleString(
//                                                                       Qt.locale(
//                                                                           "de_DE")) + " \u20AC   "
//                                                                   + renderChange(
//                                                                       changeAbsolute,
//                                                                       '\u20AC') : "-")
                                            color: Functions.determineChangeColor(changeAbsolute)
                                            font.pixelSize: Theme.fontSizeMedium
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                    }
                                }

                                Row {
                                    id: thirdRow
                                    width: parent.width
                                    height: Theme.fontSizeExtraSmall + Theme.paddingSmall

                                    Text {
                                        id: changeDateText
                                        width: parent.width / 2
                                        height: parent.height
                                        text: determineQuoteDate(quoteTimestamp)
                                        color: Theme.primaryColor
                                        font.pixelSize: Theme.fontSizeExtraSmall
                                        horizontalAlignment: Text.AlignLeft
                                    }

                                    Text {
                                        id: changePercentageText
                                        width: parent.width / 2
                                        height: parent.height
                                        text: Functions.renderChange(price, changeRelative, '%')
                                        color: Functions.determineChangeColor(changeRelative)
                                        font.pixelSize: Theme.fontSizeExtraSmall
                                        horizontalAlignment: Text.AlignRight
                                    }
                                }
                            }
                        }

                        Separator {
                            id: stockQuoteSeparator
                            anchors.top: stockQuoteRow.bottom
                            anchors.topMargin: Theme.paddingMedium

                            width: parent.width
                            color: Theme.primaryColor
                            horizontalAlignment: Qt.AlignHCenter
                        }
                    }

                    function deleteStockData(index) {
                        console.log(index)
                        var stockData = stockQuotesListView.model.get(index)
                        console.log("remove stock  : " + stockData.name)
                        Database.deleteStockData(stockData.id)
                        // stockQuotesListView.model.remove(index)
                        // recalculate the maxChange
                        // stockQuotePage.maxChange = calculateMaxChange()
                        reloadAllStocks()
                        //removeStockByTickerSymbol(listView.model.get(index).symbol)
                    }
                }

                VerticalScrollDecorator {
                }
            }
        }

        VerticalScrollDecorator {
        }

        Component.onCompleted: {
            Database.initApplicationTables()
            reloadAllStocks()
            loaded = true;
        }

        onVisibleChanged: {
            if (stockQuotesListView.visible) {
                reloadAllStocks()
            } else {
                console.log("visiblieitey of list view chagned ! -> not visible")
            }
        }
    }

    function reloadAllStocks() {
        var stocks = Database.loadAllStockData(1, Database.SORT_BY_CHANGE_DESC) // TODO watchlist id
        // var backend = Backend.createEuroinvestorBackend()
        // stocks = backend.sortByChangeDesc(stocks)

        stockQuotePage.maxChange = calculateMaxChange(stocks)

        var triggerUpdateQuotes = false;
        // when stockmodel is not empty and the number of stocks in the db is different -> stock has been added
        // is there a more transparent way to find out that a stock was added?
        if (stocksModel.count > 0 && stocksModel.count < stocks.length)  {
            console.log(" most like stock was added -> trigger reload");
            triggerUpdateQuotes = true;
        }

        stocksModel.clear()
        for (var i = 0; i < stocks.length; i++) {
            stocksModel.append(stocks[i])
        }

        if (triggerUpdateQuotes) {
            updateQuotes();
        }
    }

    function calculateMaxChange(stocks) {
//        var stocks = Database.loadAllStockData(1, Database.SORT_BY_CHANGE_DESC) // TODO watchlist id
        if (stocks !== undefined && stocks !== null && stocks.length > 0) {
            var backend = Backend.createEuroinvestorBackend() //
            console.log("max change is : " + maxChange)
            return backend.getMaxChange(stocks)
        }
        console.log("no stocks -> max change is 0.0 ")
        return 0.0
    }

    function createNotification(alarmNotification) {
        stockAlarmNotification.summary = qsTr("%1").arg(alarmNotification.name)
        var minimumPrice = Functions.renderPrice(alarmNotification.minimumPrice, alarmNotification.currency);
        stockAlarmNotification.body = qsTr("Just dropped below %1.").arg(minimumPrice);
        // TODO fix preview
        stockAlarmNotification.previewSummary = qsTr("Stock Notification x2")
        stockAlarmNotification.previewBody = qsTr("Stock %1 is below configured price !").arg(alarmNotification.name)
        stockAlarmNotification.replacesId = alarmNotification.id;
        stockAlarmNotification.publish();
        // TODO set the triggered flag to true
        // TODO replacesid seems not to work properly -> shows up multiple times -> replacedId 0 ??
    }

    function updateQuotes() {
        loaded = false;

        // listView.model.get(index)
        var numberOfQuotes = stocksModel.count
        var stocks = []
        for (var i = 0; i < numberOfQuotes; i++) {
            stocks.push(stocksModel.get(i))
        }

        function allStocksFinished(count, failed) {
            console.log("All updated! count : " + count + ", failed : " + failed);
            if (count === failed) {
                //: WatchlistPage error message network error
                stockUpdateProblemNotification.show(qsTr("Network error"));
            } else if (failed > 0) {
                //: WatchlistPage error message some quotes
                stockUpdateProblemNotification.show(qsTr("Some quotes not updated"));
            }
            loaded = true;
            reloadAllStocks();

            // get lower
            var alarmsHitLowerPrice = Database.loadTriggeredAlarms(1, true); // TODO set watchlistid

            if (alarmsHitLowerPrice !== undefined && alarmsHitLowerPrice.length > 0) {
                alarmsHitLowerPrice.forEach(createNotification);
            }

            console.log("lower : " + alarmsHitLowerPrice);
            // get higher
            var alarmsHitHigherPrice = Database.loadTriggeredAlarms(1, false); // TODO set watchlistid
            console.log("highter : " + alarmsHitHigherPrice);
        }

        function persistQuoteFunction(stockQuote, stock) {
            console.log("stock quote : " + stockQuote)
            console.log("stock : " + stock)
            if (stockQuote !== null && stock !== null) {
                stock.price = stockQuote.price
                stock.changeAbsolute = stockQuote.changeAbsolute
                stock.changeRelative = stockQuote.changeRelative
                var date = new Date()
                var dateString = date.toLocaleDateString(
                            Qt.locale("de_DE"),
                            "yyyy-MM-dd") + " " + date.toLocaleTimeString(
                            Qt.locale("de_DE"), "hh:mm:ss")
                stock.quoteTimestamp = "" + stockQuote.quoteTimestamp
                stock.lastChangeTimestamp = "" + stockQuote.lastChangeTimestamp
                if (stock.quoteTimestamp === null
                        || stock.quoteTimestamp === "undefined"
                        || stock.quoteTimestamp === "") {
                    stock.quoteTimestamp = dateString
                }
                if (stock.lastChangeTimestamp === null
                        || stock.lastChangeTimestamp === "undefined"
                        || stock.lastChangeTimestamp === "") {
                    stock.lastChangeTimestamp = dateString
                }
                console.log("price is " + stock.price)
                Database.persistStockData(stock)
            }
        }

        if (numberOfQuotes > 0) {
            var backend = Backend.createEuroinvestorBackend()
            backend.updateQuotes(stocks, persistQuoteFunction,
                                 allStocksFinished, Constants.HTTP_TIMEOUT_IN_SECONDS);
        }
    }

    function determineQuoteDate(dateTimeString) {
        if (dateTimeString !== null && dateTimeString !== "undefined"
                && dateTimeString !== "") {
            var date = Date.fromLocaleString(Qt.locale("de_DE"),
                                             dateTimeString,
                                             "yyyy-MM-dd hh:mm:ss")

            var currentDateString = new Date().toLocaleDateString(Qt.locale(),
                                                                  "yyyy-MM-dd")
            var quoteDateString = date.toLocaleDateString(Qt.locale(),
                                                          "yyyy-MM-dd")

            // if quote is from today - show only time - else show date
            if (currentDateString === quoteDateString) {
                return date.toLocaleTimeString(Qt.locale(), qsTr("hh:mm"))
            } else {
                return date.toLocaleDateString(Qt.locale(), qsTr("dd.MM.yyyy"))
            }
        }
        return "-"
    }

//    function determineChangeColor(change) {
//        var color = Theme.primaryColor
//        if (change < 0.0) {
//            color = Constants.NEGATIVE_COLOR
//        } else if (change > 0.0) {
//            color = Constants.POSITIVE_COLOR
//        }
//        return color
//    }

//    function renderChange(change, symbol) {
//        console.log("change : " + change)
//        console.log("change : " + Number(change))
//        var prefix = ""
//        if (change > 0.0) {
//            prefix = "+"
//        }
//        return prefix + Number(change).toLocaleString(
//                    Qt.locale("de_DE")) + " " + symbol
//    }

    function removeStockQuote(index) {
        console.log("removing stock quote : " + index)
    }
}
