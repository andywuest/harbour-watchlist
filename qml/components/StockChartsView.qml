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
    id: stockChartsViewFlickable

    property var stock
    property string extRefId
    property int screenHeight : 0
    property var chartDataMap : ({})
    property bool isActive : false

    contentHeight: stockChartsColumn.height

    function getDataBackend() {
        return Functions.getDataBackend(watchlistSettings.dataBackend);
    }

    function fetchPricesForChartHandler(result, type) {
        chartDataMap[type] = JSON.parse(result);
    }

    function updateStockChart(response, chart) {
        if (response && response.data) {
            chart.minY = (response.min / 1.0);
            chart.maxY = (response.max / 1.0);
            chart.setPoints(response.data);
            chart.fractionDigits = response.fractionDigits;
        }
    }

    function triggerChartDataDownloadOnEntering() {
        var strategy = watchlistSettings.chartDataDownloadStrategy;
        return (strategy === Constants.CHART_DATA_DOWNLOAD_STRATEGY_ALWAYS ||
                (strategy === Constants.CHART_DATA_DOWNLOAD_STRATEGY_ONLY_ON_WIFI && watchlist.isWiFi()));
    }

    function repaintCharts() {
        if (isActive) {
            updateStockChart(chartDataMap[Constants.CHART_TYPE_INTRDAY], intradayStockChart)
            updateStockChart(chartDataMap[Constants.CHART_TYPE_MONTH], lastMonthStockChart)
            updateStockChart(chartDataMap[Constants.CHART_TYPE_3_MONTHS], lastThreeMonthStockChart)
            updateStockChart(chartDataMap[Constants.CHART_TYPE_YEAR], lastYearStockChart)
            updateStockChart(chartDataMap[Constants.CHART_TYPE_3_YEARS], lastThreeYearsStockChart)
        }
    }

    Timer {
        id: fetchPricesForChartTimer
        interval: 100
        running: false
        repeat: false
        onTriggered: {
            var dataBackend = getDataBackend();
            dataBackend.fetchPricesForChart(extRefId, Constants.CHART_TYPE_INTRDAY)
            dataBackend.fetchPricesForChart(extRefId, Constants.CHART_TYPE_MONTH);
            dataBackend.fetchPricesForChart(extRefId, Constants.CHART_TYPE_3_MONTHS);
            dataBackend.fetchPricesForChart(extRefId, Constants.CHART_TYPE_YEAR);
            dataBackend.fetchPricesForChart(extRefId, Constants.CHART_TYPE_3_YEARS);
        }
    }

    Column {
        id: stockChartsColumn

        // height: childrenRect.height
        anchors {
            left: parent.left
            right: parent.right
        }

        SectionHeader {
            //: StockChartsView chart section header
            text: qsTr("Charts")
        }

        StockChart {
            id: intradayStockChart
            visible: getDataBackend().isChartTypeSupported(Constants.CHART_TYPE_INTRDAY);
            graphTitle: qsTr("Intraday")
            chartType: Constants.CHART_TYPE_INTRDAY
            graphHeight: screenHeight * 0.15625
            onClicked: {
                Functions.log("chart intraday clicked !")
                getDataBackend().fetchPricesForChart(extRefId, Constants.CHART_TYPE_INTRDAY);
            }
        }

        StockChart {
            id: lastMonthStockChart
            visible: getDataBackend().isChartTypeSupported(Constants.CHART_TYPE_MONTH);
            graphTitle: qsTr("30 days")
            chartType: Constants.CHART_TYPE_MONTH
            graphHeight: screenHeight * 0.15625
            onClicked: {
                Functions.log("chart month clicked !")
                getDataBackend().fetchPricesForChart(extRefId, Constants.CHART_TYPE_MONTH);
            }
        }

        StockChart {
            id: lastThreeMonthStockChart
            visible: getDataBackend().isChartTypeSupported(Constants.CHART_TYPE_3_MONTHS);
            graphTitle: qsTr("3 months")
            chartType: Constants.CHART_TYPE_3_MONTHS
            graphHeight: screenHeight * 0.15625
            onClicked: {
                Functions.log("chart 3 month clicked !")
                getDataBackend().fetchPricesForChart(extRefId, Constants.CHART_TYPE_3_MONTHS);
            }
        }

        StockChart {
            id: lastYearStockChart
            visible: getDataBackend().isChartTypeSupported(Constants.CHART_TYPE_YEAR);
            graphTitle: qsTr("1 Year")
            chartType: Constants.CHART_TYPE_YEAR
            graphHeight: screenHeight * 0.15625
            onClicked: {
                Functions.log("chart year clicked !")
                getDataBackend().fetchPricesForChart(extRefId, Constants.CHART_TYPE_YEAR);
            }
        }

        StockChart {
            id: lastThreeYearsStockChart
            visible: getDataBackend().isChartTypeSupported(Constants.CHART_TYPE_3_YEARS);
            graphTitle: qsTr("3 Years")
            chartType: Constants.CHART_TYPE_3_YEARS
            graphHeight: screenHeight * 0.15625
            onClicked: {
                Functions.log("chart year clicked !")
                getDataBackend().fetchPricesForChart(extRefId, Constants.CHART_TYPE_3_YEARS);
            }
        }
    }

    Component.onCompleted: {
        if (stock) {
            extRefId = (stock.extRefId) ? stock.extRefId : ''

            var currencyUnit = stock.currencySymbol ? stock.currencySymbol : '-';
            intradayStockChart.axisYUnit = currencyUnit;
            lastMonthStockChart.axisYUnit = currencyUnit;
            lastThreeMonthStockChart.axisYUnit = currencyUnit;
            lastYearStockChart.axisYUnit = currencyUnit;
            lastThreeYearsStockChart.axisYUnit = currencyUnit;

            var infoLines = {};
            infoLines.referencePrice = {};
            infoLines.referencePrice.color = "#FF0000";
            infoLines.referencePrice.value = stock.referencePrice;
            infoLines.alarmMinimumPrice = {};
            infoLines.alarmMinimumPrice.color = "#FFFF00";
            infoLines.alarmMinimumPrice.value = -1;
            infoLines.alarmMaximumPrice = {};
            infoLines.alarmMaximumPrice.color = "#FFFACD";
            infoLines.alarmMaximumPrice.value = -1;

            var alarm = Database.loadAlarm(stock.id);
            if (alarm !== undefined && alarm !== null && alarm.id !== undefined) {
                if (alarm.minimumPrice !== null && alarm.minimumPrice !== "") {
                    infoLines.alarmMinimumPrice.value = Number(alarm.minimumPrice);
                }
                if (alarm.maximumPrice !== null && alarm.maximumPrice !== "") {
                    infoLines.alarmMaximumPrice.value = Number(alarm.maximumPrice);
                }
            }

            intradayStockChart.infoLines = infoLines;
            lastMonthStockChart.infoLines = infoLines;
            lastThreeMonthStockChart.infoLines = infoLines;
            lastYearStockChart.infoLines = infoLines;
            lastThreeYearsStockChart.infoLines = infoLines;

            // connect signal slot for chart update
            getDataBackend().fetchPricesForChartAvailable.connect(fetchPricesForChartHandler)
            if (triggerChartDataDownloadOnEntering()) {
                fetchPricesForChartTimer.start();
            }
        }

        Functions.log("completed")
    }

    Component.onDestruction: {
        Functions.log("disconnecting signal")
        getDataBackend().fetchPricesForChartAvailable.disconnect(fetchPricesForChartHandler)
    }

    onIsActiveChanged: {
        repaintCharts();
    }

    VerticalScrollDecorator {
        flickable: stockChartsViewFlickable
    }

    onVisibleChanged: {
        repaintCharts();
    }

}
