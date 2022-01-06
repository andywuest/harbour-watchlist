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

// QTBUG-34418
// import "."

import "../js/database.js" as Database
import "../js/functions.js" as Functions
import "../js/constants.js" as Constants

import "../components/thirdparty"

Page {
    id: addMarketdataPage

    allowedOrientations: Orientation.All

    AppNotification {
        id: marketdataAddedNotification
    }

    SilicaFlickable {

        anchors.fill: parent
        contentHeight: parent.height
        contentWidth: parent.width

        Column {
            id: marketDataColumn

            width: parent.width

            PageHeader {
                id: addMarketDataHeader
                //: AddMarketdataPage Market data header
                title: qsTr("Market data")
            }

            SilicaListView {
                id: searchListView

                height: addMarketdataPage.height - addMarketDataHeader.height
                width: parent.width
                anchors.left: parent.left
                anchors.right: parent.right

                Behavior on opacity {
                    NumberAnimation {
                    }
                }

                clip: true

                section {
                    property: "typeName"
                    criteria: ViewSection.FullString
                    delegate: SectionHeader {
                        text: section
                    }
                }

                model: ListModel {
                    id: searchResultListModel
                }

                delegate: ListItem {
                    id: delegate

//                    menu: ContextMenu {
//                        MenuItem {
//                            visible: true
//                            //: AddMarketdataPage add menu item
//                            text: qsTr("Add")
//                            onClicked: {
//                                var selectedItem = searchResultListModel.get(
//                                            index)
//                                var result = Database.persistMarketdata(
//                                            selectedItem)
//                                marketdataAddedNotification.show(result)
//                                searchResultListModel.remove(index);
//                            }
//                        }
//                    }

                    Column {
                        id: resultColumn
                        width: parent.width - (2 * Theme.horizontalPageMargin)
                        height: marketDataLabel.height
                        spacing: Theme.paddingMedium
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter

                        Label {
                            id: marketDataLabel
                            font.pixelSize: Theme.fontSizeMedium
                            text: name
                        }
                    }

                    onClicked: {
                        var selectedItem = searchResultListModel.get(
                                    index)
                        var result = Database.persistMarketdata(
                                    selectedItem)
                        marketdataAddedNotification.show(result)
                        searchResultListModel.remove(index);
                    }
                }

                VerticalScrollDecorator {
                }
            }

        }

        Component.onCompleted: {
            var marketDataList = Constants.MARKET_DATA_LIST;
            var backend = getMarketDataBackend();

            // add all supported and not yet assigned market datas to list
            for (var i = 0; i < marketDataList.length; i++) {
                var extRefId = backend.getMarketDataExtRefId(marketDataList[i].id);
                var loadedMarketData = Database.loadMarketDataBy(extRefId);
                if (extRefId && !(loadedMarketData)) {
                    marketDataList[i].extRefId = extRefId;
                    searchResultListModel.append(marketDataList[i])
                }
            }
        }
    }
}
