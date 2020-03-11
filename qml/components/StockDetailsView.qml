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
import "../components"
import "../components/thirdparty"

import "../js/constants.js" as Constants
import "../js/database.js" as Database
import "../js/functions.js" as Functions

SilicaFlickable {
    id: stockDetailsViewFlickable

    contentHeight: stockDetailsColumn.height

    property var stock
//    property string extRefId

    Column {
        id: stockDetailsColumn

        // height: childrenRect.height
        anchors {
            left: parent.left
            right: parent.right
        }

        SectionHeader {
            //: StockDetailsPage page general data
            text: qsTr("General data")
        }

        LabelValueRow {
            id: currencyLabelValueRow
            //: StockDetailsPage page currency
            label: qsTr("Currency")
            value: ''
        }

        LabelValueRow {
            id: isinLabelValueRow
            //: StockDetailsPage page isin
            label: qsTr("Isin")
            value: ''
        }

        LabelValueRow {
            id: symbolLabelValueRow
            //: StockDetailsPage page symbol
            label: qsTr("Symbol")
            value: ''
        }

        LabelValueRow {
            id: stockMarketNameLabelValueRow
            //: StockDetailsPage page stock market
            label: qsTr("Stock Market")
            value: ''
        }

        SectionHeader {
            //: StockDetailsPage page trading data
            text: qsTr("Trading data")
        }

        LabelValueRow {
            id: priceLabelValueRow
            //: StockDetailsPage page price
            label: qsTr("Price")
            value: ''
        }

        LabelValueRow {
            id: changeAbsoluteLabelValueRow
            //: StockDetailsPage page change absolute
            label: qsTr("Change abs.")
            value: ''
        }

        LabelValueRow {
            id: changeRelativeLabelValueRow
            //: StockDetailsPage page change relative
            label: qsTr("Change rel.")
            value: ''
        }

        LabelValueRow {
            id: timestampLabelValueRow
            //: StockDetailsPage page timestamp
            label: qsTr("Timestamp")
            value: ''
        }

        LabelValueRow {
            id: askLabelValueRow
            //: StockDetailsPage page ask
            label: qsTr("Ask")
            value: ''
        }

        LabelValueRow {
            id: bidLabelValueRow
            //: StockDetailsPage page bid
            label: qsTr("Bid")
            value: ''
        }

        LabelValueRow {
            id: highLabelValueRow
            //: StockDetailsPage page high
            label: qsTr("High")
            value: ''
        }

        LabelValueRow {
            id: lowLabelValueRow
            //: StockDetailsPage page low
            label: qsTr("Low")
            value: ''
        }

        LabelValueRow {
            id: volumeLabelValueRow
            //: StockDetailsPage page volume
            label: qsTr("Volume")
            value: ''
        }
    }

    Component.onCompleted: {
        if (stock) {
//            extRefId = (stock.extRefId) ? stock.extRefId : ''
            currencyLabelValueRow.value = stock.currency ? stock.currency : '';
            isinLabelValueRow.value = stock.isin ? stock.isin : '';
            symbolLabelValueRow.value = stock.symbol1 ? stock.symbol1 : ''; // TODO warum symbol1
            stockMarketNameLabelValueRow.value = stock.stockMarketName ? stock.stockMarketName : '';
            askLabelValueRow.value = stock.ask ? Functions.renderPrice(stock.ask, stock.currency) : '';
            bidLabelValueRow.value = stock.bid ? Functions.renderPrice(stock.bid, stock.currency) : '';
            highLabelValueRow.value = stock.high ? Functions.renderPrice(stock.high, stock.currency) : '';
            lowLabelValueRow.value = stock.low ? Functions.renderPrice(stock.low, stock.currency) : '';
            changeAbsoluteLabelValueRow.value = stock.changeAbsolute ? Functions.renderChange(stock.price, stock.changeAbsolute, Functions.resolveCurrencySymbol(stock.currency)) : '';
            changeRelativeLabelValueRow.value = stock.changeRelative ? Functions.renderChange(stock.price, stock.changeRelative, '%') : '';
            priceLabelValueRow.value = stock.price ? Functions.renderPrice(stock.price, stock.currency) : '';
            volumeLabelValueRow.value = stock.volume ? stock.volume : '';
            timestampLabelValueRow.value = stock.quoteTimestamp ? Functions.renderDateTimeString(stock.quoteTimestamp) : '';
        }
    }

    VerticalScrollDecorator {
        flickable: stockDetailsViewFlickable
    }

}
