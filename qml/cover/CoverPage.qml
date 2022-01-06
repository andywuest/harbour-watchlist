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
import QtQuick 2.6
import QtQuick.LocalStorage 2.0
import Sailfish.Silica 1.0

import "../components"

import "../js/constants.js" as Constants
import "../js/database.js" as Database
import "../js/functions.js" as Functions

CoverBackground {
    id: coverPage
    property int watchlistId: 1 // TODO the default watchlistId as long as we only support one watchlist
    property bool loading : false;

    function reloadAllStocks() {
        coverModel.clear()
        var stocks = Database.loadAllStockData(watchlistId,
                                               Database.SORT_BY_CHANGE_ASC)
        if (coverActionPrevious.enabled) {
            stocks.reverse()
        }

        var reducedStockList = stocks
        if (stocks.length > 5) {
            reducedStockList = stocks.slice(0, 5)
        }

        for (var i = 0; i < reducedStockList.length; i++) {
            coverModel.append(reducedStockList[i])
        }
    }

    // same as in watchlistPage
    function updateQuotes() {
        loading = true;

        // listView.model.get(index)
        var stocks = Database.loadAllStockData(watchlistId,
                                               Database.SORT_BY_CHANGE_ASC)
        var stockExtRefIds = []
        for (var i = 0; i < stocks.length; i++) {
            stockExtRefIds.push(stocks[i].extRefId)
        }

        if (stocks.length > 0) {
            var dataBackend = getSecurityDataBackend(watchlistSettings.dataBackend);
            dataBackend.searchQuote(stockExtRefIds.join(','))
        } else {
            loading = false;
        }
    }

    function quoteResultHandler(result) {
        var jsonResult = JSON.parse(result.toString())
        console.log("json result from backend was: " + result)
        for (var i = 0; i < jsonResult.length; i++) {
            var stockQuote = jsonResult[i]
            var stock = Database.loadStockBy(watchlistId, '' + stockQuote.extRefId)
            if (stock) {
                // copy id
                stockQuote.id = stock.id
                // persist
                Database.persistStockData(stockQuote, watchlistId)
            }
        }
        reloadAllStocks()
        loading = false;

        Database.loadTriggeredAlarms(watchlistId, true).forEach(stockAlarmNotification.createMinimumAlarm);
        Database.loadTriggeredAlarms(watchlistId, false).forEach(stockAlarmNotification.createMaximumAlarm);
    }

    function errorResultHandler(result) {
        loading = false
    }

    AlarmNotification {
        id: stockAlarmNotification
    }

    Column {
        id: loadingColumn
        width: parent.width - 2 * Theme.horizontalPageMargin
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.paddingMedium
        visible: coverPage.loading
        Behavior on opacity {
            NumberAnimation {
            }
        }
        opacity: coverPage.loading ? 1 : 0
        InfoLabel {
            id: loadingLabel
            text: qsTr("Loading...")
            font.pixelSize: Theme.fontSizeMedium
        }
    }

    CoverActionList {
        id: coverActionPrevious
        enabled: true

        CoverAction {
            id: actionPreviousPrevious
            iconSource: "image://theme/icon-cover-previous"
            onTriggered: {
                console.log("previous clicked")
                coverActionPrevious.enabled = false
                coverActionNext.enabled = true
                reloadAllStocks()
            }
        }

        CoverAction {
            id: actionRefresh
            iconSource: "image://theme/icon-cover-refresh"
            onTriggered: {
                console.log("refresh clicked prev")
                updateQuotes()
            }
        }
    }

    CoverActionList {
        id: coverActionNext
        enabled: false

        CoverAction {
            id: actionNext
            iconSource: "image://theme/icon-cover-next"
            onTriggered: {
                console.log("previous clicked")
                coverActionNext.enabled = false
                coverActionPrevious.enabled = true
                reloadAllStocks()
            }
        }

        CoverAction {
            id: actionRefreshNext
            iconSource: "image://theme/icon-cover-refresh"
            onTriggered: {
                console.log("refresh clicked prev")
                updateQuotes()
            }
        }
    }

    SilicaListView {
        id: coverListView

        visible: !coverPage.loading
        Behavior on opacity { NumberAnimation {} }
        opacity: coverPage.loading ? 0 : 1

        anchors.fill: parent

        model: ListModel {
            id: coverModel
        }

        header: Text {
            id: labelTitle
            width: parent.width
            topPadding: Theme.paddingLarge
            bottomPadding: Theme.paddingMedium
            text: coverActionPrevious.enabled ? qsTr("Top") : qsTr("Flop")
            color: Theme.primaryColor
            font.bold: true
            font.pixelSize: Theme.fontSizeSmall
            textFormat: Text.StyledText
            horizontalAlignment: Text.AlignHCenter
        }

        delegate: ListItem {

            // height: resultLabelTitle.height + resultLabelContent.height + Theme.paddingSmall
            contentHeight: stockQuoteColumn.height + Theme.paddingSmall

            // TODO custom - hier noch pruefen, was an margins noch machbar, sinnvoll ist
            Column {
                id: stockQuoteColumn
                x: Theme.paddingLarge
                width: parent.width - 2 * Theme.paddingLarge
                anchors.verticalCenter: parent.verticalCenter

                Row {
                    id: firstRow
                    width: parent.width
                    height: Theme.fontSizeExtraSmall + Theme.paddingSmall

                    Label {
                        id: stockQuoteName
                        width: parent.width // * 8 / 10
                        height: parent.height
                        text: name
                        // truncationMode: TruncationMode.Elide // TODO check for very long texts
                        color: Theme.primaryColor
                        font.pixelSize: Theme.fontSizeExtraSmall
                        font.bold: true
                        horizontalAlignment: Text.AlignLeft
                        truncationMode: TruncationMode.Fade
                    }
                }

                Row {
                    id: thirdRow
                    width: parent.width
                    height: Theme.fontSizeTiny + Theme.paddingSmall

                    Text {
                        id: stockQuoteChange
                        width: parent.width / 2
                        height: parent.height
                        text: Functions.renderPrice(price, currencySymbol)
                        color: Theme.highlightColor
                        font.pixelSize: Theme.fontSizeTiny
                        font.bold: true
                        horizontalAlignment: Text.AlignLeft
                    }

                    Text {
                        id: changePercentageText
                        width: parent.width / 2
                        height: parent.height
                        text: Functions.renderChange(price, changeRelative, '%')
                        color: Functions.determineChangeColor(changeRelative)
                        font.pixelSize: Theme.fontSizeTiny
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }

        Component.onCompleted: {
            // Database.initApplicationTables()
            var dataBackend = getSecurityDataBackend(watchlistSettings.dataBackend);
            dataBackend.quoteResultAvailable.connect(quoteResultHandler)
            dataBackend.requestError.connect(errorResultHandler)
            reloadAllStocks()
        }

        onVisibleChanged: {
            reloadAllStocks()
        }
    }

    OpacityRampEffect {
        sourceItem: coverListView
        direction: OpacityRamp.TopToBottom
        offset: 0.6
        slope: 3.75
    }

}
