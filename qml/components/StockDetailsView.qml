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

    Column {
        id: stockDetailsColumn

        // height: childrenRect.height
        anchors {
            left: parent.left
            right: parent.right
        }

        SectionHeader {
            //: StockDetailsView page general data
            text: qsTr("General data")
        }

        LabelValueRow {
            id: currencyLabelValueRow
            //: StockDetailsView page currency
            label: qsTr("Currency")
            value: ''
        }

        LabelValueRow {
            id: isinLabelValueRow
            //: StockDetailsView page isin
            label: qsTr("ISIN")
            value: ''
        }

        LabelValueRow {
            id: symbolLabelValueRow
            //: StockDetailsView page symbol
            label: qsTr("Symbol")
            value: ''
        }

        LabelValueRow {
            id: stockMarketNameLabelValueRow
            //: StockDetailsView page stock market
            label: qsTr("Stock Market")
            value: ''
        }

        SectionHeader {
            //: StockDetailsView page trading data
            text: qsTr("Trading data")
        }

        LabelValueRow {
            id: priceLabelValueRow
            //: StockDetailsView page price
            label: qsTr("Price")
            value: ''
        }

        LabelValueRow {
            id: changeAbsoluteLabelValueRow
            //: StockDetailsView page change absolute
            label: qsTr("Change abs.")
            value: ''
        }

        LabelValueRow {
            id: changeRelativeLabelValueRow
            //: StockDetailsView page change relative
            label: qsTr("Change rel.")
            value: ''
        }

        LabelValueRow {
            id: timestampLabelValueRow
            //: StockDetailsView page timestamp
            label: qsTr("Timestamp")
            value: ''
        }

        LabelValueRow {
            id: askLabelValueRow
            //: StockDetailsView page ask
            label: qsTr("Ask")
            value: ''
        }

        LabelValueRow {
            id: bidLabelValueRow
            //: StockDetailsView page bid
            label: qsTr("Bid")
            value: ''
        }

        LabelValueRow {
            id: highLabelValueRow
            //: StockDetailsView page high
            label: qsTr("High")
            value: ''
        }

        LabelValueRow {
            id: lowLabelValueRow
            //: StockDetailsView page low
            label: qsTr("Low")
            value: ''
        }

        LabelValueRow {
            id: volumeLabelValueRow
            //: StockDetailsView page volume
            label: qsTr("Volume")
            value: ''
        }

        SectionHeader {
            id: additionalInformationSectionHeader
            //: StockDetailsView page additional information section header
            text: qsTr("Additional information")
            visible: notesRow.visible || referencePriceLabelValueRow.visible || piecesLabelValueRow.visible
        }

        LabelValueRow {
            id: referencePriceLabelValueRow
            //: StockDetailsView page reference price
            label: qsTr("Reference price")
            value: ''
            visible: false;
        }

        LabelValueRow {
            id: performanceRelativeLabelValueRow
            //: StockDetailsView page performance
            label: qsTr("Performance")
            value: ''
            visible: false;
        }

        LabelValueRow {
            id: piecesLabelValueRow
            //: StockDetailsView page pieces
            label: qsTr("Pieces")
            value: ''
            visible: false;
        }

        // TODO check if displayed and with which label
        LabelValueRow {
            id: positionValuePurchaseLabelValueRow
            //: StockDetailsView page position value purchase
            label: qsTr("Position value purchase")
            value: ''
            visible: false;
        }

        // TODO check if displayed and with which label
        LabelValueRow {
            id: positionValueCurrentLabelValueRow
            //: StockDetailsView page position value
            label: qsTr("Position value current")
            value: ''
            visible: false;
        }

        LabelOnlyRow {
            id: notesRow
            label: ''
            visible: false;
        }

    }

    Component.onCompleted: {
        if (stock) {
            currencyLabelValueRow.value = stock.currency ? stock.currency : '';
            var currencySymbol = stock.currencySymbol;
            isinLabelValueRow.value = stock.isin ? stock.isin : '';
            symbolLabelValueRow.value = stock.symbol1 ? stock.symbol1 : ''; // TODO warum symbol1
            stockMarketNameLabelValueRow.value = stock.stockMarketName ? stock.stockMarketName : '';
            askLabelValueRow.value = Functions.renderPrice(stock.ask, currencySymbol);
            bidLabelValueRow.value = Functions.renderPrice(stock.bid, currencySymbol);
            highLabelValueRow.value = Functions.renderPrice(stock.high, currencySymbol);
            lowLabelValueRow.value = Functions.renderPrice(stock.low, currencySymbol);
            changeAbsoluteLabelValueRow.value = stock.changeAbsolute ? Functions.renderChange(stock.price, stock.changeAbsolute, currencySymbol) : '';
            changeRelativeLabelValueRow.value = stock.changeRelative ? Functions.renderChange(stock.price, stock.changeRelative, '%') : '';
            priceLabelValueRow.value = Functions.renderPrice(stock.price, currencySymbol);
            volumeLabelValueRow.value = stock.volume ? stock.volume : '';
            timestampLabelValueRow.value = stock.quoteTimestamp ? Functions.renderDateTimeString(stock.quoteTimestamp) : '';
            var notes = stock.notes;
            if (notes && notes !== '') {
                notesRow.label = notes;
                notesRow.visible = true;
            }
            var referencePrice = stock.referencePrice;
            if (referencePrice && referencePrice !== 0.0) {
                referencePriceLabelValueRow.value = Functions.renderPrice(referencePrice, currencySymbol);
                performanceRelativeLabelValueRow.value = Functions.renderChange(stock.price, stock.performanceRelative, '%')
                referencePriceLabelValueRow.visible = true;
                performanceRelativeLabelValueRow.visible = true;
            }
            var pieces = stock.pieces;
            if (pieces && pieces !== 0) {
                piecesLabelValueRow.value = '' + pieces;
                piecesLabelValueRow.visible = true;
            }
            var positionValuePurchase = stock.positionValuePurchase;
            if (positionValuePurchase && positionValuePurchase !== 0.0) {
                positionValuePurchaseLabelValueRow.value = Functions.renderPrice(positionValuePurchase, currencySymbol);
                positionValuePurchaseLabelValueRow.visible = true;
            }
            var positionValueCurrent = stock.positionValueCurrent;
            if (positionValueCurrent && positionValueCurrent !== 0.0) {
                positionValueCurrentLabelValueRow.value = Functions.renderPrice(positionValueCurrent, currencySymbol);
                positionValueCurrentLabelValueRow.visible = true;
            }

        }
    }

    VerticalScrollDecorator {
        flickable: stockDetailsViewFlickable
    }

}
