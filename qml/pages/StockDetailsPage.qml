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
    property string extRefId

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
                //: StockDetailsPage page intraday chart
                text: qsTr("Charts")
            }

            StockChart {
                id: intradayStockChart
                graphTitle: qsTr("Intraday")
                onClicked: {
                    console.log("chart clicked !")
                    euroinvestorBackend.fetchPricesForChart(extRefId, Constants.CHART_TYPE_INTRDAY);
                }
            }

            StockChart {
                id: lastMonthStockChart
                graphTitle: qsTr("30 days")
                onClicked: {
                    console.log("chart clicked !")
                    euroinvestorBackend.fetchPricesForChart(extRefId, Constants.CHART_TYPE_MONTH);
                }
            }

            StockChart {
                id: lastYearStockChart
                graphTitle: qsTr("Year")
                onClicked: {
                    console.log("chart clicked !")
                    euroinvestorBackend.fetchPricesForChart(extRefId, Constants.CHART_TYPE_YEAR);
                }
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


//            Button {
//                id: showChartsButton
//                onClicked: pageStack.push(Qt.resolvedUrl("StockChartsPage.qml"))
//            }



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

        function fetchPricesForChartHandler(result, type) {
            console.log("intraday result was : " + result + " / " + type)
            var response = JSON.parse(result);

            if (type === Constants.CHART_TYPE_INTRDAY) {
                updateStockChart(response, intradayStockChart);
            } else if (type === Constants.CHART_TYPE_MONTH) {
                updateStockChart(response, lastMonthStockChart);
            } else if (type === Constants.CHART_TYPE_YEAR) {
                updateStockChart(response, lastYearStockChart);
            }
        }

        function updateStockChart(response, chart) {
            chart.minY = (response.min / 1.0);
            chart.maxY = (response.max / 1.0);
            chart.setPoints(response.data);
            chart.fractionDigits = response.fractionDigits;
        }

        Component.onCompleted: {
            extRefId = stock.extRefId ? stock.extRefId : ''
            titlePageHeader.title = stock.name ? stock.name : '';
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


            var currencyUnit = stock.currency ? Functions.resolveCurrencySymbol(stock.currency) : '-';
            intradayStockChart.axisYUnit = currencyUnit;
            lastMonthStockChart.axisYUnit = currencyUnit;
            lastYearStockChart.axisYUnit = currencyUnit;

            // connect signal slot for chart update
            euroinvestorBackend.fetchPricesForChartAvailable.connect(fetchPricesForChartHandler)
            if (watchlistSettings.downloadIntradayChartDataImmediately === true) {
                euroinvestorBackend.fetchPricesForChart(extRefId, Constants.CHART_TYPE_INTRDAY)
                euroinvestorBackend.fetchPricesForChart(extRefId, Constants.CHART_TYPE_MONTH);
                euroinvestorBackend.fetchPricesForChart(extRefId, Constants.CHART_TYPE_YEAR);
            }
            console.log("completed")
        }

        Component.onDestruction: {
            console.log("disconnecting signal")
            euroinvestorBackend.fetchPricesForChartAvailable.disconnect(fetchPricesForChartHandler)
            //euroinvestorBackend.fetchClosePricesAvailable.disconnect(fetchClosePricesHandler)
        }

    }

    VerticalScrollDecorator {
        flickable: stockDetailsPageFlickable
    }
}
