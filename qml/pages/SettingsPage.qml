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

            ComboBox {
                id: chartDataDownloadComboBox
                label: qsTr("Download chart data")
                currentIndex: watchlistSettings.chartDataDownloadStrategy
                description: qsTr("Defines strategy to download the chart data")
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("Always")
                    }
                    MenuItem {
                        text: qsTr("Only on WiFi")
                    }
                    MenuItem {
                        text: qsTr("Only manually")
                    }
                    onActivated: {
                        watchlistSettings.chartDataDownloadStrategy = index
                    }
                }
            }

            ComboBox {
                id: sortingOrderComboBox
                label: qsTr("Sorting order")
                currentIndex: watchlistSettings.sortingOrder
                description: qsTr("Defines sorting order of watchlist entries")
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("By change")
                    }
                    MenuItem {
                        text: qsTr("By name")
                    }
                    onActivated: {
                        watchlistSettings.sortingOrder = index
                    }
                }
            }
        }

        onVisibleChanged: {
            watchlistSettings.sync()
            console.log("chartDataDownloadStrategy : "
                        + watchlistSettings.chartDataDownloadStrategy)
            console.log("sortingOrder : " + watchlistSettings.sortingOrder)
            console.log("writing changes !")
        }
    }
}
