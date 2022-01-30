/*
 * harbour-watchlist - Sailfish OS Version
 * Copyright © 2022 Andreas Wüst (andreas.wuest.freelancer@gmail.com)
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
    id: dividendsViewFlickable

//    property real maxChange: 0.0
    property bool loaded : false
    property int watchlistId: 1 // the default watchlistId as long as we only support one watchlist

    anchors.fill: parent
    contentHeight: watchlistColumn.height
    contentWidth: parent.width

//    function isWatchlistNotEmpty() {
//        return dividendsModel.count > 0;
//    }

//    function getWatchlistItemCount() {
//        return dividendsModel.count;
//    }

    function connectSlots() {
        Functions.log("[DividendsView] connect - slots");
        var dataBackend = getDividendBackend();
        dataBackend.fetchDividendDatesResultAvailable.connect(dividendDatesResultHandler);
        dataBackend.requestError.connect(errorResultHandler);
    }

    function disconnectSlots() {
        Functions.log("[DividendsView] disconnect - slots");
        var dataBackend = getDividendBackend();
        dataBackend.fetchDividendDatesResultAvailable.disconnect(dividendDatesResultHandler);
        dataBackend.requestError.disconnect(errorResultHandler);
    }

    function dividendDatesResultHandler(result) {
      var jsonResult = JSON.parse(result.toString())
      Functions.log("[DividendsView] dividend result: " +result)

      Database.deleteAllTableEntries("dividends");

      // TODO instead write to DB
        for (var i = 0; i < jsonResult.dividends.length; i++) {
            Functions.log("[DividendsView] adding " + jsonResult.dividends[i].isin);
            Database.persistDividends(jsonResult.dividends[i]);
        }

//        var marketData = jsonResult[i];
//        var loadedMarketData = Database.loadMarketDataBy('' + marketData.extRefId)
//        if (loadedMarketData) {
//            // copy id / typeId
//            marketData.id = loadedMarketData.id;
//            marketData.typeId = loadedMarketData.typeId;
//            // persist
//            Database.persistMarketdata(marketData)
//        }




//      for (var i = 0; i < jsonResult.length; i++)   {
//          var stockQuote = jsonResult[i];
//          var stock = Database.loadStockBy(watchlistId, '' + stockQuote.extRefId)
//          if (stock) {
//              // copy id
//              stockQuote.id = stock.id;
//              // persist
//              Database.persistStockData(stockQuote, watchlistId)
//          }
//      }

        reloadAllDividends();
        loaded = true;

//      Database.loadTriggeredAlarms(watchlistId, true).forEach(stockAlarmNotification.createMinimumAlarm);
//      Database.loadTriggeredAlarms(watchlistId, false).forEach(stockAlarmNotification.createMaximumAlarm);
    }

    function errorResultHandler(result) {
        dividendDatesUpdateProblemNotification.show(result)
        loaded = true;
    }

    function updateEmptyModelColumnVisibility() {
        dividendsEmptyModelColumnLabel.isVisible = (dividendsModel.count === 0);
    }

    function reloadAllDividends() {
        Functions.log("[DividendsView] reloading all dividends ");
//        var sortOrder = (watchlistSettings.sortingOrder === Constants.SORTING_ORDER_BY_CHANGE ? Database.SORT_BY_CHANGE_DESC : Database.SORT_BY_NAME_ASC);
        var sortOrder = " exDateInteger ASC";
        var dividends = Database.loadAllDividendData(watchlistId, sortOrder);

//        // stockQuotePage.
//        maxChange = Functions.calculateMaxChange(stocks)

//        var triggerUpdateQuotes = false;
//        // when stockmodel is not empty and the number of stocks in the db is different -> stock has been added
//        // is there a more transparent way to find out that a stock was added?
//       if (dividendsModel.count >= 0 && dividendsModel.count < stocks.length)  {
//            console.log(" most like stock was added -> trigger reload");
//            triggerUpdateQuotes = true;
//        }

//        // reconnect the slots - we may have got a new backend
//        if (stocks.length === 0) {
//            disconnectSlots();
//            connectSlots();
//        }

        dividendsModel.clear()
        for (var i = 0; i < dividends.length; i++) {
            dividendsModel.append(dividends[i])
        }

        updateEmptyModelColumnVisibility();

//        if (triggerUpdateQuotes) {
//            updateQuotes();
//        }
    }

    function updateDividendDates() {
        Functions.log("[DividendsView] - DividendDates");


//        var numberOfQuotes = dividendsModel.count

//        var stocks = []
//        for (var i = 0; i < numberOfQuotes; i++) {
//            stocks.push(dividendsModel.get(i).extRefId)
//        }

//        if (numberOfQuotes > 0) {
//            loaded = false;
//            getSecurityDataBackend(watchlistSettings.dataBackend).searchQuote(stocks.join(','));
//        }
        loaded = false;
        getDividendBackend().fetchDividendDates();
    }

//    // TODO consolidate methods updateReferencePriceInModel and updateNotesInModel
//    function updateReferencePriceInModel(securityId, referencePrice) {
//        Functions.log("[DividendsView] Received updateReferencePriceInModel " + securityId + ", " + referencePrice);
//        var numberOfQuotes = dividendsModel.count
//        for (var i = 0; i < numberOfQuotes; i++) {
//            if (dividendsModel.get(i).id === securityId) {
//                dividendsModel.get(i).referencePrice = referencePrice;
//                Functions.log("[DividendsView] Updated reference price in model!");
//            }
//        }
//    }

//    function updateNotesInModel(securityId, notes) {
//        Functions.log("[DividendsView] Received updateNotesInModel " + securityId + ", " + notes);
//        var numberOfQuotes = dividendsModel.count
//        for (var i = 0; i < numberOfQuotes; i++) {
//            if (dividendsModel.get(i).id === securityId) {
//                stocksModel.get(i).notes = notes;
//                Functions.log("[DividendsView] Updated notes in model!");
//            }
//        }
//    }

    AppNotification {
        id: dividendDatesUpdateProblemNotification
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
            id: dividendsHeader
            //: DividendsView page header
            title: qsTr("Dividend dates")
        }

        EmptyModelColumnLabel {
            id: dividendsEmptyModelColumnLabel
            theHeight: dividendsViewFlickable.height - dividendsHeader.height
            //: DividendsView empty marketdata label
            emptyLabel: qsTr("The dividend dates have not yet been loaded. Please load them via the pulley menu.")
        }

        SilicaListView {
            id: dividendsListView

            height: dividendsViewFlickable.height - dividendsHeader.height - Theme.paddingMedium
            width: parent.width
            anchors.left: parent.left
            anchors.right: parent.right

            clip: true

            model: ListModel {
                id: dividendsModel
            }

            delegate: ListItem {
                contentHeight: dividendsItem.height + (2 * Theme.paddingMedium)
                contentWidth: parent.width

//                onClicked: {
//                    var selectedStock = dividendsListView.model.get(index);
//                    pageStack.push(Qt.resolvedUrl("../pages/StockOverviewPage.qml"), { stock: selectedStock })
//                }

//                menu: ContextMenu {
//                    MenuItem {
//                        //: DividendsView configure alarm menu item
//                        text: qsTr("Configure alarm")
//                        onClicked: {
//                            var selectedStock = dividendsListView.model.get(index);
//                            pageStack.push(Qt.resolvedUrl("../pages/StockAlarmDialog.qml"), { stock: selectedStock })
//                        }
//                    }
//                    MenuItem {
//                        //: DividendsView remove menu item
//                        text: qsTr("Remove")
//                        onClicked: deleteStockData(index)
//                    }
//                    MenuItem {
//                        //: DividendsView show stock notes dialog
//                        text: qsTr("Stock notes")
//                        onClicked: {
//                            var selectedStock = dividendsListView.model.get(index);
//                            var notesPage = pageStack.push(Qt.resolvedUrl("../pages/StockNotesDialog.qml"), { selectedSecurity: selectedStock })
//                            notesPage.updateNotesInModel.connect(updateNotesInModel)
//                        }
//                    }
//                    MenuItem {
//                        //: DividendsView show refenrence price dialog
//                        text: qsTr("Configure reference price")
//                        onClicked: {
//                            var selectedStock = dividendsListView.model.get(index);
//                            var referencePricePage = pageStack.push(Qt.resolvedUrl("../pages/ReferencePriceDialog.qml"), { selectedSecurity: selectedStock })
//                            referencePricePage.updateReferencePriceInModel.connect(updateReferencePriceInModel);
//                        }
//                    }
//                }

                Item {
                    id: dividendsItem
                    width: parent.width
                    height: dividendsRow.height + stockQuoteSeparator.height
                    y: Theme.paddingMedium

                    Row {
                        id: dividendsRow
                        width: parent.width - (2 * Theme.horizontalPageMargin)
                        spacing: Theme.paddingMedium
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter

                        // TODO custom - hier noch pruefen, was an margins noch machbar, sinnvoll ist
                        Column {
                            id: dividendColumn
                            width: parent.width // - (2 * Theme.horizontalPageMargin)
                            // x: Theme.horizontalPageMargin
                            height: firstRow.height // + changeRow.height
                            /* + secondRow.height*/ + dividendDateRow.height
//                                    + (watchlistSettings.showPerformanceRow ? performanceRow.height : 0)

                            anchors.verticalCenter: parent.verticalCenter

                            Row {
                                id: firstRow
                                width: parent.width
                                height: Theme.fontSizeSmall + Theme.paddingMedium

                                Label {
                                    id: stockQuoteName
                                    width: parent.width * 8 / 10
                                    height: parent.height
                                    text: name
                                    truncationMode: TruncationMode.Fade// TODO check for very long texts
                                    // elide: Text.ElideRight
                                    color: Theme.primaryColor
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.bold: true
                                    horizontalAlignment: Text.AlignLeft
                                }

                                Text {
                                    id: stockQuoteChange
                                    width: parent.width * 2 / 10
                                    height: parent.height
                                    text: Functions.renderPrice(amount, currency, Constants.MARKET_DATA_TYPE_DIVIDENDS);
                                    color: Theme.highlightColor
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.bold: true
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

//                            Row {
//                                id: changeRow
//                                width: parent.width
//                                height: 7

//                                Rectangle {
//                                    id: changeRowRectangle
//                                    width: Functions.calculateWidth(price,
//                                                          changeRelative,
//                                                          maxChange,
//                                                          parent.width)
//                                    height: parent.height
//                                    color: determineChangeColor(changeRelative)
//                                }
//                            }

                            Row {
                                id: dividendDateRow
                                width: parent.width
                                height: Theme.fontSizeExtraSmall + Theme.paddingSmall

                                Text {
                                    width: parent.width / 2
                                    height: parent.height
                                    text: "" //  Functions.determineQuoteDate(quoteTimestamp)
                                    color: Theme.primaryColor
                                    font.pixelSize: Theme.fontSizeExtraSmall
                                    horizontalAlignment: Text.AlignLeft
                                }

                                Text {
                                    width: parent.width / 2
                                    height: parent.height
                                    text: payDate // Functions.renderChange(price, changeRelative, '%')
                                    color: Theme.primaryColor
                                    font.pixelSize: Theme.fontSizeExtraSmall
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

//                            Row {
//                                id: performanceRow
//                                width: parent.width
//                                visible: watchlistSettings.showPerformanceRow
//                                height: Theme.fontSizeExtraSmall + Theme.paddingSmall

//                                Text {
//                                    width: parent.width / 2
//                                    height: parent.height
//                                    //: DividendsView Performance label
//                                    text: qsTr("Performance")
//                                    color: Theme.primaryColor
//                                    font.pixelSize: Theme.fontSizeExtraSmall
//                                    horizontalAlignment: Text.AlignLeft
//                                }

//                                Text {
//                                    width: parent.width / 2
//                                    height: parent.height
//                                    text: Functions.renderChange(referencePrice, performanceRelative, '%')
//                                    color: determineChangeColor(performanceRelative)
//                                    font.pixelSize: Theme.fontSizeExtraSmall
//                                    horizontalAlignment: Text.AlignRight
//                                }
//                            }


                        }
                    }

                    Separator {
                        id: stockQuoteSeparator
                        anchors.top: dividendsRow.bottom
                        anchors.topMargin: Theme.paddingMedium

                        width: parent.width
                        color: Theme.primaryColor
                        horizontalAlignment: Qt.AlignHCenter
                    }
                }

//                function deleteStockData(index) {
//                    var stockData = dividendsListView.model.get(index)
//                    Functions.log("[DividendsView] remove stock with index " + index
//                                  + " - " + stockData.name);
//                    Database.deleteStockData(stockData.id)
//                    reloadAllDividends()
//                }
            }

            VerticalScrollDecorator {
            }
        }
    }

    VerticalScrollDecorator {
    }

    Component.onCompleted: {
        connectSlots();
        reloadAllDividends();
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
