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
import "../components"
import "../components/thirdparty"

import "../js/constants.js" as Constants
import "../js/database.js" as Database
import "../js/functions.js" as Functions

Page {
    id: stockDetailsPage
    property var stock

    allowedOrientations: Orientation.All

    SilicaFlickable {
        id: stockDetailsPageFlickable
        anchors.fill: parent
        contentHeight: stockDetailsColumn.height

        Column {
            id: stockDetailsColumn

            PageHeader {
                id: titlePageHeader
                title: ''
            }

            height: childrenRect.height
            anchors {
                left: parent.left
                right: parent.right
            }

            //            Row {
            //                id: stockQuoteRow
            //                width: parent.width - (2 * Theme.horizontalPageMargin)
            //                spacing: Theme.paddingMedium
            //                anchors.verticalCenter: parent.verticalCenter
            //                anchors.horizontalCenter: parent.horizontalCenter

            //                // TODO custom - hier noch pruefen, was an margins noch machbar, sinnvoll ist
            //                Column {
            //                    id: stockQuoteColumn
            //                    width: parent.width // - (2 * Theme.horizontalPageMargin)
            //                    // x: Theme.horizontalPageMargin
            //                    height: firstRow.height + changeRow.height
            //                    /* + secondRow.height*/ + thirdRow.height
            //                    anchors.verticalCenter: parent.verticalCenter


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
                //: StockDetailsPage page ask
                label: qsTr("Ask")
                value: stock ? Functions.renderPrice(stock.ask, stock.currency) : ''
            }

            LabelValueRow {
                //: StockDetailsPage page ask
                label: qsTr("Bid")
                value: stock ? Functions.renderPrice(stock.bid, stock.currency) : ''
            }

            LabelValueRow {
                //: StockDetailsPage page ask
                label: qsTr("High")
                value: stock ? Functions.renderPrice(stock.high, stock.currency) : ''
            }

            LabelValueRow {
                visible: (stock && stock.low)
                //: StockDetailsPage page ask
                label: qsTr("Low")
                value: stock ? Functions.renderPrice(stock.low, stock.currency) : ''
            }







//            SilicaListView {
//                id: slv
//                spacing: Theme.paddingSmall
//                width: parent.width
//                height: 400

//                model: ListModel {
//                    ListElement {
//                        fruit: "jackfruit2"
//                    }
//                    ListElement {
//                        fruit: "orange"
//                    }
//                    ListElement {
//                        fruit: "lemon"
//                    }
//                    ListElement {
//                        fruit: "lychee"
//                    }
//                    ListElement {
//                        fruit: "apricots"
//                    }
//                }
//                delegate: Item {
//                    width: ListView.view.width
//                    height: Theme.itemSizeExtraSmall

//                    Row {
//                        id: firstRow1
//                        width: parent.width - (2 * Theme.paddingLarge) - Theme.paddingSmall
//                        height: Theme.fontSizeSmall + Theme.paddingSmall
//                        //spacing: Theme.paddingMedium
//                        //y: Theme.paddingLarge
//                        x: Theme.paddingLarge

//                        //                        padding: Theme.paddingMedium
//                        Text {
//                            id: stockQuoteName24
//                            width: parent.width * 8 / 10
//                            height: parent.height
//                            text: "Ask"
//                            // truncationMode: TruncationMode.Elide // TODO check for very long texts
//                            color: Theme.primaryColor
//                            font.pixelSize: Theme.fontSizeSmall
//                            font.bold: true
//                            horizontalAlignment: Text.AlignLeft
//                        }

//                        Text {
//                            id: stockQuoteChange23
//                            width: parent.width * 2 / 10
//                            height: parent.height
//                            text: "" + fruit
//                            color: Theme.highlightColor
//                            font.pixelSize: Theme.fontSizeSmall
//                            font.bold: true
//                            horizontalAlignment: Text.AlignRight
//                        }
//                    }
//                }
//            }

        }

        Component.onCompleted: {
            titlePageHeader.title = stock.name ? stock.name : '';
            currencyLabelValueRow.value = stock.currency ? stock.currency : '';
            isinLabelValueRow.value = stock.isin ? stock.isin : '';
            symbolLabelValueRow.value = stock.symbol1 ? stock.symbol1 : ''; // TODO warum symbol1
            stockMarketNameLabelValueRow.value = stock.stockMarketName ? stock.stockMarketName : '';
            console.log("completed")
        }

    }

    VerticalScrollDecorator {
        flickable: stockDetailsPageFlickable
    }
}
