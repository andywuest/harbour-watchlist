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

import "../js/constants.js" as Constants
import "../js/functions.js" as Functions

SilicaFlickable {
    id: stockNewsViewFlickable

    property string isin

    anchors.fill: parent
    contentHeight: stockNewsColumn.height
    contentWidth: parent.width

    function searchStockNewsHandler(result) {
        var jsonResult = JSON.parse(result.toString())
        newsListModel.clear()
        if (jsonResult.newsItems.length > 0) {
            noNewsLabel.visible = false;
            listView.visible = true;
            for (var i = 0; i < jsonResult.newsItems.length; i++) {
                if (jsonResult.newsItems[i]) {
                    newsListModel.append(jsonResult.newsItems[i])
                }
            }
        } else {
            noNewsLabel.visible = true;
            listView.visible = false;
        }

    }

    function triggerNewsDataDownloadOnEntering() {
        var strategy = watchlistSettings.newsDataDownloadStrategy;
        return (strategy === Constants.NEWS_DATA_DOWNLOAD_STRATEGY_ALWAYS ||
                (strategy === Constants.NEWS_DATA_DOWNLOAD_STRATEGY_ONLY_ON_WIFI && watchlist.isWiFi()));
    }

    Timer {
        id: fetchNewsTimer
        interval: 100
        running: false
        repeat: false
        onTriggered: {
            var newsBackend = Functions.getNewsBackend()
            newsBackend.searchStockNews(isin)
        }
    }

    Column {
        id: stockNewsColumn

        Behavior on opacity {
            NumberAnimation {
            }
        }

        width: parent.width
        spacing: Theme.paddingMedium

        Label {
            id: noNewsLabel
            horizontalAlignment: Text.AlignHCenter
            x: Theme.horizontalPageMargin
            width: parent.width - 2 * x

            wrapMode: Text.Wrap
            textFormat: Text.RichText
            text: qsTr("No news items found for this security.")
        }

        SilicaListView {
            id: listView

            height: stockNewsViewFlickable.height - Theme.paddingMedium
            width: parent.width
            anchors.left: parent.left
            anchors.right: parent.right

            Behavior on opacity {
                NumberAnimation {
                }
            }

            model: ListModel {
                id: newsListModel
            }

            delegate: ListItem {
                id: delegate

                contentHeight: stockQuoteItem.height + (2 * Theme.paddingMedium)
                contentWidth: parent.width

                Item {
                    id: stockQuoteItem
                    width: parent.width
                    height: newsItemColumn.height + stockQuoteSeparator.height
                    y: Theme.paddingMedium

                    Column {
                        id: newsItemColumn
                        width: parent.width - (2 * Theme.horizontalPageMargin)
                        height: headlineLabel.height + dateTimeLabel.height + Theme.paddingMedium
                        spacing: Theme.paddingSmall
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter

                        Label {
                            id: headlineLabel
                            text: headline
                            truncationMode: TruncationMode.Fade
                            font.pixelSize: Theme.fontSizeSmall
                            width: parent.width
                            height: Theme.fontSizeSmall
                        }
                        Label {
                            id: dateTimeLabel
                            text: dateTime + " | " + source
                            font.pixelSize: Theme.fontSizeTiny
                            width: parent.width
                            height: Theme.fontSizeTiny
                        }
                    }

                    Separator {
                        id: stockQuoteSeparator
                        anchors.top: newsItemColumn.bottom
                        anchors.topMargin: Theme.paddingMedium

                        width: parent.width
                        color: Theme.primaryColor
                        horizontalAlignment: Qt.AlignHCenter
                    }
                }

                onClicked: {
                    var selectedItem = listView.model.get(index)
                    pageStack.push(Qt.resolvedUrl("../pages/NewsPage.qml"), {
                                       newsItem: selectedItem
                                   });
                }
            }

            VerticalScrollDecorator {
            }
        }
    }

    Component.onCompleted: {
        if (stock) {
            isin = (stock.isin) ? stock.isin : ''

            // connect signal slot for chart update
            Functions.getNewsBackend().searchNewsResultAvailable.connect(searchStockNewsHandler)

            if (triggerNewsDataDownloadOnEntering()) {
                fetchNewsTimer.start()
            }
        }
    }

    Component.onDestruction: {
        Functions.log("disconnecting signal");
        Functions.getNewsBackend().searchNewsResultAvailable.disconnect(
                    searchStockNewsHandler)
    }
}
