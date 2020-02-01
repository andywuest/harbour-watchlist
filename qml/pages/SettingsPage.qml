import QtQuick 2.1
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0

// QTBUG-34418
import "."

import "../components"

import "../js/constants.js" as Constants

Page {
    id: settingsPage

    SilicaFlickable {
        id: settingsFlickable
        anchors.fill: parent

        // Tell SilicaFlickable the height of its content.
        contentHeight: settingsColumn.height

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: settingsColumn
            width: settingsPage.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("Settings")
            }

            TextSwitch {
                id: downloadIntradayChartDataImmediatelyTextSwitch
                text: qsTr ("Download Intraday data")
                description: qsTr ("Downloads the data for the intraday chart automatically. Otherwise you have to trigger the download "
                                   + "manually by clicking on the chart.") + " WiFi " + (watchlist.isWiFi() ? "ON" : "OFF") + ".";
                Component.onCompleted: checked = watchlistSettings.downloadIntradayChartDataImmediately
                onCheckedChanged: {
                    watchlistSettings.downloadIntradayChartDataImmediately = checked;
                    console.log("state downloadIntradayChartDataImmediately changed");
                }
            }
        }

        onVisibleChanged: {
            watchlistSettings.sync();
            console.log("downloadIntradayChartDataImmediately : " + watchlistSettings.downloadIntradayChartDataImmediately);
            console.log("writing changes !");
        }
   }
}
