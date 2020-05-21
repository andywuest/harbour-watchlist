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
import QtQuick 2.2
import QtQuick.LocalStorage 2.0
import Sailfish.Silica 1.0

// QTBUG-34418
import "."

import "../js/constants.js" as Constants
import "../js/database.js" as Database
import "../js/functions.js" as Functions

import "../components"
import "../components/thirdparty"

SilicaFlickable {
    id: watchlistViewFlickable

    property real maxChange: 0.0
    property bool loaded : false
    property int watchlistId: 1 // the default watchlistId as long as we only support one watchlist

    anchors.fill: parent
    contentHeight: watchlistColumn.height
    contentWidth: parent.width

    function isWatchlistNotEmpty() {
        return stocksModel.count > 0;
    }

    function getWatchlistItemCount() {
        return stocksModel.count;
    }

    function connectSlots() {
        console.log("connect - slots");
        var dataBackend = Functions.getDataBackend(watchlistSettings.dataBackend);
        dataBackend.quoteResultAvailable.connect(quoteResultHandler);
        dataBackend.requestError.connect(errorResultHandler);
    }

    function disconnectSlots() {
        console.log("disconnect - slots");
        var dataBackend = Functions.getDataBackend(watchlistSettings.dataBackend);
        dataBackend.quoteResultAvailable.disconnect(quoteResultHandler);
        dataBackend.requestError.disconnect(errorResultHandler);
    }

    function quoteResultHandler(result) {
      var jsonResult = JSON.parse(result.toString())
      console.log("json result from data backend was: " +result)
      for (var i = 0; i < jsonResult.length; i++)   {
          var stockQuote = jsonResult[i];
          var stock = Database.loadStockBy(watchlistId, '' + stockQuote.extRefId)
          if (stock) {
              // copy id
              stockQuote.id = stock.id;
              // persist
              Database.persistStockData(stockQuote, watchlistId)
          }
      }
      reloadAllStocks()
      loaded = true;

      Database.loadTriggeredAlarms(watchlistId, true).forEach(stockAlarmNotification.createMinimumAlarm);
      Database.loadTriggeredAlarms(watchlistId, false).forEach(stockAlarmNotification.createMaximumAlarm);
    }

    function errorResultHandler(result) {
        stockUpdateProblemNotification.show(result)
        loaded = true;
    }

    function reloadAllStocks() {
        console.log("reloading all stocks");
        var sortOrder = (watchlistSettings.sortingOrder === Constants.SORTING_ORDER_BY_CHANGE ? Database.SORT_BY_CHANGE_DESC : Database.SORT_BY_NAME_ASC);
        var stocks = Database.loadAllStockData(watchlistId, sortOrder);

        // stockQuotePage.
        maxChange = Functions.calculateMaxChange(stocks)

        var triggerUpdateQuotes = false;
        // when stockmodel is not empty and the number of stocks in the db is different -> stock has been added
        // is there a more transparent way to find out that a stock was added?
       if (stocksModel.count >= 0 && stocksModel.count < stocks.length)  {
            console.log(" most like stock was added -> trigger reload");
            triggerUpdateQuotes = true;
        }

        // reconnect the slots - we may have got a new backend
        if (stocks.length === 0) {
            disconnectSlots();
            connectSlots();
        }

        stocksModel.clear()
        for (var i = 0; i < stocks.length; i++) {
            stocksModel.append(stocks[i])
        }

        if (triggerUpdateQuotes) {
            updateQuotes();
        }
    }

    function updateQuotes() {
        console.log("updateQuotes");
        loaded = false;

        // listView.model.get(index)
        var numberOfQuotes = stocksModel.count
        var stocks = []
        for (var i = 0; i < numberOfQuotes; i++) {
            stocks.push(stocksModel.get(i).extRefId)
        }

        if (numberOfQuotes > 0) {
            Functions.getDataBackend(watchlistSettings.dataBackend).searchQuote(stocks.join(','));
        }
    }

    AppNotification {
        id: stockUpdateProblemNotification
    }

    AlarmNotification {
        id: stockAlarmNotification
    }

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

            height: watchlistViewFlickable.height - stockQuotesHeader.height - Theme.paddingMedium
//                stockQuotePage.height - stockQuotesHeader.height - Theme.paddingMedium
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
                    var selectedStock = stockQuotesListView.model.get(index);
                    pageStack.push(Qt.resolvedUrl("../pages/StockOverviewPage.qml"), { stock: selectedStock })
                }

                menu: ContextMenu {
                    MenuItem {
                        //: WatchlistPage configure alarm menu item
                        text: qsTr("Configure alarm")
                        onClicked: {
                            var selectedStock = stockQuotesListView.model.get(index);
                            pageStack.push(Qt.resolvedUrl("../pages/StockAlarmDialog.qml"), { stock: selectedStock })
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
                                    text: Functions.determineQuoteDate(quoteTimestamp)
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
                    reloadAllStocks()
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
        connectSlots();
        reloadAllStocks();
        loaded = true;
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

}
