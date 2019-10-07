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
import "."

import "../js/database.js" as Database
import "../js/functions.js" as Functions

import "../components/thirdparty"

Page {

    id: stockSearchPage

    allowedOrientations: Orientation.All

    AppNotification {
        id: stockAddedNotification
    }

    SilicaFlickable {

        anchors.fill: parent
        contentHeight: parent.height
        contentWidth: parent.width

        //        anchors.fill: parent
        Column {
            id: searchColumn

            Behavior on opacity {
                NumberAnimation {
                }
            }

            width: parent.width

            Timer {
                id: searchTimer
                interval: 800
                running: false
                repeat: false
                onTriggered: {
                    searchResultListModel.clear()
                    euroinvestorBackend.searchName(searchField.text);
                }
            }

            PageHeader {
                id: searchHeader
                //: AddStockPage search result header
                title: qsTr("Search Results")
            }

            SearchField {
                id: searchField
                width: parent.width
                //: AddStockPage search result input field
                placeholderText: qsTr("Find your Stock...")
                focus: true

                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false

                onTextChanged: {
                    var searchFieldLength = Functions.calculateVisibleStringLength(
                                searchField.text)
                    if (searchFieldLength > 1) {
                        // only start search if we have at least 2 characters
                        searchTimer.stop()
                        searchTimer.start()
                    } else {
                        noResultsColumn.visible = false
                        searchResultListModel.clear()
                    }
                }
            }

            Column {
                height: stockSearchPage.height - searchHeader.height - searchField.height
                width: parent.width

                id: noResultsColumn
                Behavior on opacity {
                    NumberAnimation {
                    }
                }
                opacity: visible ? 1 : 0
                visible: false

                Label {
                    id: noResultsLabel
                    anchors.horizontalCenter: parent.horizontalCenter
                    //: AddStockPage no results label
                    text: qsTr("No results found")
                    color: Theme.secondaryColor
                }
            }

            SilicaListView {
                id: searchListView

                height: stockSearchPage.height - searchHeader.height - searchField.height
                width: parent.width
                anchors.left: parent.left
                anchors.right: parent.right
                opacity: (searchListView.count === 0
                          && Functions.calculateVisibleStringLength(
                              searchField.text) > 1) ? 0 : 1
                visible: (searchListView.count === 0
                          && Functions.calculateVisibleStringLength(
                              searchField.text) > 1) ? false : true

                Behavior on opacity {
                    NumberAnimation {
                    }
                }

                clip: true

                model: ListModel {
                    id: searchResultListModel
                }

                delegate: ListItem {
                    id: delegate

                    menu: ContextMenu {
                        MenuItem {
                            visible: true
                            //: AddStockPage add menu item
                            text: qsTr("Add")
                            onClicked: {
                                var selectedItem = searchResultListModel.get(
                                            index)
                                var result = Database.persistStockData(
                                            selectedItem,
                                            Database.getCurrentWatchlistId())
                                stockAddedNotification.show(result)
                            }
                        }
                    }

                    Column {
                        id: resultColumn
                        width: parent.width - (2 * Theme.horizontalPageMargin)
                        height: stockNameText.height
                                + stockNameAdditionalInfoRow.height
                                + Theme.paddingMedium
                        spacing: Theme.paddingMedium
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter

                        Text {
                            id: stockNameText
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.primaryColor
                            text: name
                            textFormat: Text.StyledText
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            width: parent.width
                            height: Theme.fontSizeMedium
                        }
                        Row {
                            id: stockNameAdditionalInfoRow
                            height: Theme.fontSizeMedium
                            width: parent.width

                            Text {
                                id: stockSource
                                width: parent.width * 2 / 3
                                font.pixelSize: Theme.fontSizeExtraSmall
                                color: Theme.secondaryColor
                                text: stockMarketName
                                    // stockMarketName
                                //qsTr("Bank ID: %1").arg(modelData.blz)
                                textFormat: Text.StyledText
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }
                            Text {
                                id: stockIsin
                                width: parent.width / 3
                                font.pixelSize: Theme.fontSizeExtraSmall
                                color: Theme.secondaryColor
                                text: isin
                                textFormat: Text.StyledText
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }
                        }
                    }

                    onClicked: {
                        var selectedItem = searchResultListModel.get(index)
                        console.log("Clicked " + index)
                        console.log("name : " + selectedItem.name)
                    }
                }

                VerticalScrollDecorator {
                }
            }

        }

        function searchResultHandler(result) {
          var jsonResult = JSON.parse(result.toString())
          console.log("json result from euroinvestor was: " +result)

          for (var i = 0; i < jsonResult.length; i++)   {
              if (jsonResult[i]) {
                searchResultListModel.append(jsonResult[i]);
              }
          }

          if (searchListView.count === 0 && searchField.text !== "") {
              noResultsColumn.visible = true
          } else {
              noResultsColumn.visible = false
          }
        }

        function errorResultHandler(result) {
            stockAddedNotification.show(result)
        }

        Component.onCompleted: {
            euroinvestorBackend.searchResultAvailable.connect(searchResultHandler);
            euroinvestorBackend.searchError.connect(errorResultHandler);
        }

    }
}
