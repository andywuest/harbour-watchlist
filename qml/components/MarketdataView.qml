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

import "../js/constants.js" as Constants
import "../js/database.js" as Database
import "../js/functions.js" as Functions

import "../components"
import "../components/thirdparty"

SilicaFlickable {
    id: marketdataViewFlickable

    property bool loaded : false

    anchors.fill: parent
    contentHeight: marketdataColumn.height
    contentWidth: parent.width

    function isMarketDataNotEmpty() {
        return marketDataModel.count > 0;
    }

    function getMarketDataItemCount() {
        return marketDataModel.count;
    }

    function connectSlots() {
        console.log("connect - slots");
        var backend = getMarketDataBackend();
        backend.marketDataResultAvailable.connect(marketDataResultHandler);
        backend.requestError.connect(errorResultHandler);
    }

    function disconnectSlots() {
        console.log("disconnect - slots");
        var backend = getMarketDataBackend();
        backend.marketDataResultAvailable.disconnect(marketDataResultHandler);
        backend.requestError.disconnect(errorResultHandler);
    }

    function marketDataResultHandler(result) {
      console.log("result : " + result);

      var jsonResult = JSON.parse(result.toString())
      console.log("json result from market data backend was: " +result)
      for (var i = 0; i < jsonResult.length; i++)   {
          var marketData = jsonResult[i];
          var loadedMarketData = Database.loadMarketDataBy('' + marketData.extRefId)
          if (loadedMarketData) {
              // copy id / typeId
              marketData.id = loadedMarketData.id;
              marketData.typeId = loadedMarketData.typeId;
              // persist
              Database.persistMarketdata(marketData)
          }
      }
      reloadAllMarketData()
      loaded = true;
    }

    function errorResultHandler(result) {
        marketDataUpdateProblemNotification.show(result)
        loaded = true;
    }

    function updateEmptyModelColumnVisibility() {
        marketDataEmptyModelColumnLabel.isVisible = (marketDataModel.count === 0);
    }

    function reloadAllMarketData() {
        console.log("reloading all market data");
        var marketData = Database.loadAllMarketData();

        var triggerUpdateQuotes = false;
        // when stockmodel is not empty and the number of stocks in the db is different -> stock has been added
        // is there a more transparent way to find out that a stock was added?
       if (marketDataModel.count >= 0 && marketDataModel.count < marketData.length)  {
            console.log(" most like market data was added -> trigger reload");
            triggerUpdateQuotes = true;
        }

        // reconnect the slots - we may have got a new backend
        if (marketData.length === 0) {
            disconnectSlots();
            connectSlots();
        }

        marketDataModel.clear()
        for (var i = 0; i < marketData.length; i++) {
            marketDataModel.append(marketData[i])
        }

        updateEmptyModelColumnVisibility();

        if (triggerUpdateQuotes) {
            updateMarketData();
        }
    }

    function updateMarketData() { // TODO rename
        console.log("update market data");
        loaded = false;

        var marketDataCount = marketDataModel.count
        var marketData = []
        for (var i = 0; i < marketDataCount; i++) {
            marketData.push(marketDataModel.get(i).extRefId)
        }

        if (marketDataCount > 0) {
           getMarketDataBackend().lookupMarketData(marketData.join(','));
        }
    }

    function isShowCurrency(type) {
        return (Constants.MARKET_DATA_TYPE_INDEX !== type && Constants.MARKET_DATA_TYPE_CURRENCY !== type);
    }

    AppNotification {
        id: marketDataUpdateProblemNotification
    }

    Column {
        id: marketdataColumn
        width: parent.width
        spacing: Theme.paddingMedium

        Behavior on opacity {
            NumberAnimation {
            }
        }
        opacity: visible ? 1 : 0
        visible: true

        PageHeader {
            id: marketDataHeader
            //: MarketdataView page header
            title: qsTr("Market data")
        }

        EmptyModelColumnLabel {
            id: marketDataEmptyModelColumnLabel
            theHeight: marketdataViewFlickable.height - marketDataHeader.height
            //: MarketdataView empty marketdata label
            emptyLabel: qsTr("The market data list is empty. Please add market data via the pulley menu.")
        }

        SilicaListView {
            id: marketDataListView

            height: marketdataViewFlickable.height - marketDataHeader.height - Theme.paddingMedium
//                stockQuotePage.height - marketDataHeader.height - Theme.paddingMedium
            width: parent.width
            anchors.left: parent.left
            anchors.right: parent.right

            clip: true

            model: ListModel {
                id: marketDataModel
            }

            delegate: ListItem {
                contentHeight: stockQuoteItem.height + (2 * Theme.paddingMedium)
                contentWidth: parent.width

                onClicked: {
                    var selectedStock = marketDataListView.model.get(index);
                    // pageStack.push(Qt.resolvedUrl("../pages/StockOverviewPage.qml"), { stock: selectedStock })
                }

                menu: ContextMenu {
                    MenuItem {
                        //: WatchlistPage remove menu item
                        text: qsTr("Remove")
                        onClicked: deleteMarketData(index)
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
                            height: firstRow.height // + changeRow.height
                            + thirdRow.height
                            anchors.verticalCenter: parent.verticalCenter

                            Row {
                                id: firstRow
                                width: parent.width
                                height: Theme.fontSizeSmall + Theme.paddingMedium

                                Text {
                                    id: stockQuoteName
                                    width: parent.width * 8 / 10
                                    height: parent.height
                                    text: Functions.lookupMarketDataName(id);
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
                                    text: Functions.renderPrice(last, isShowCurrency(typeId) ? currency : '', typeId);
                                    color: Theme.highlightColor
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.bold: true
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            // TODO remove changeRow
                            /*
                            Row {
                                id: changeRow
                                width: parent.width
                                height: 7

                                Rectangle {
                                    id: changeRowRectangle
                                    width: 10
                                    height: parent.height
                                    color: Functions.determineChangeColor(changeRelative)
                                }
                            }
                            */

                            Row {
                                id: thirdRow
                                width: parent.width
                                height: Theme.fontSizeExtraSmall + Theme.paddingSmall

                                Text {
                                    id: changeDateText
                                    width: parent.width / 2
                                    height: parent.height
                                    text: Functions.determineQuoteDate(quoteTimestamp);
                                    color: Theme.primaryColor
                                    font.pixelSize: Theme.fontSizeExtraSmall
                                    horizontalAlignment: Text.AlignLeft
                                }

                                Text {
                                    id: changePercentageText
                                    width: parent.width / 2
                                    height: parent.height
                                    text: Functions.renderChange(last, changeRelative, '%')
                                    color: determineChangeColor(changeRelative)
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

                function deleteMarketData(index) {
                    console.log(index)
                    var marketData = marketDataListView.model.get(index)
                    console.log("remove market data  : " + marketData.name)
                    Database.deleteMarketData(marketData.id)
                    reloadAllMarketData()
                }
            }

            VerticalScrollDecorator {
            }
        }
    }

    VerticalScrollDecorator {
    }

    Component.onCompleted: {
        connectSlots();
        reloadAllMarketData();
        loaded = true;
    }

    Component.onDestruction: {
        Functions.log("disconnecting signal");
        disconnectSlots();
    }

    LoadingIndicator {
        id: marketDataLoadingIndicator
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
