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
                //: SettingsPage settings title
                title: qsTr("Settings")
            }

            ComboBox {
                id: chartDataDownloadComboBox
                //: SettingsPage download chart data
                label: qsTr("Download chart data")
                currentIndex: watchlistSettings.chartDataDownloadStrategy
                //: SettingsPage download strategy explanation
                description: qsTr("Defines strategy to download the chart data")
                menu: ContextMenu {
                    MenuItem {
                        //: SettingsPage download strategy always
                        text: qsTr("Always")
                    }
                    MenuItem {
                        //: SettingsPage download strategy only on wifi
                        text: qsTr("Only on WiFi")
                    }
                    MenuItem {
                        //: SettingsPage download strategy only manually
                        text: qsTr("Only manually")
                    }
                    onActivated: {
                        watchlistSettings.chartDataDownloadStrategy = index
                    }
                }
            }

            ComboBox {
                id: sortingOrderComboBox
                //: SettingsPage sorting order watchlist page
                label: qsTr("Sorting order")
                currentIndex: watchlistSettings.sortingOrder
                //: SettingsPage sorting order description
                description: qsTr("Defines sorting order of watchlist entries")
                menu: ContextMenu {
                    MenuItem {
                        //: SettingsPage sorting order by change
                        text: qsTr("By change")
                    }
                    MenuItem {
                        //: SettingsPage sorting order by name
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
//            console.log("chartDataDownloadStrategy : "
//                        + watchlistSettings.chartDataDownloadStrategy)
//            console.log("sortingOrder : " + watchlistSettings.sortingOrder)
//            console.log("writing changes !")
        }
    }
}
