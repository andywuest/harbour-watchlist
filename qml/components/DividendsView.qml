/*
 * harbour-watchlist - Sailfish OS Version
 * Copyright © 2022 Andreas Wüst (andreas.wuest.freelancer@gmail.com)
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

import "../js/constants.js" as Constants
import "../js/database.js" as Database
import "../js/functions.js" as Functions

import "../components"
import "../components/thirdparty"

SilicaFlickable {
    id: dividendsViewFlickable

    property bool loaded : false
    property int watchlistId: 1 // the default watchlistId as long as we only support one watchlist

    anchors.fill: parent
    contentHeight: watchlistColumn.height
    contentWidth: parent.width

    function connectSlots() {
        Functions.log("[DividendsView] connect - slots");
        var dataBackend = getDividendBackend();
        dataBackend.fetchDividendDatesResultAvailable.connect(dividendDatesResultHandler);
        dataBackend.requestError.connect(errorResultHandler);
    }

    function disconnectSlots() {
        Functions.log("[DividendsView] disconnect - slots");
        var dataBackend = getDividendBackend();
        dataBackend.fetchDividendDatesResultAvailable.disconnect(dividendDatesResultHandler);
        dataBackend.requestError.disconnect(errorResultHandler);
    }

    function dividendDatesResultHandler(rows) {
        Functions.log("[DividendsView] dividend data updated - number of rows : " + rows);

        watchlistSettings.dividendsDataLastUpdate = new Date();
        dividendsHeader.description = getLastUpdateString();

        reloadAllDividends();
        loaded = true;
    }

    function errorResultHandler(result) {
        dividendDatesUpdateProblemNotification.show(result)
        loaded = true;
    }

    function updateEmptyModelColumnVisibility() {
        dividendsEmptyModelColumnLabel.isVisible = (dividendsModel.count === 0);
    }

    function reloadAllDividends() {
        Functions.log("[DividendsView] reloading all dividends ");
        var sortOrder = " payDateInteger ASC";
        var dividends = Database.loadAllDividendData(watchlistId, sortOrder);

        dividendsModel.clear()
        for (var i = 0; i < dividends.length; i++) {
            dividendsModel.append(dividends[i])
        }

        updateEmptyModelColumnVisibility();
    }

    function updateDividendDates() {
        Functions.log("[DividendsView] - DividendDates");

        loaded = false;
        getDividendBackend().fetchDividendDates();
    }

    function getLastUpdateString() {
        return qsTr("Last update: %1").arg(watchlistSettings.dividendsDataLastUpdate ? Format.formatDate(watchlistSettings.dividendsDataLastUpdate, Format.DurationElapsed) : "-");
    }

    AppNotification {
        id: dividendDatesUpdateProblemNotification
    }

    Column {
        id: dividendDataColumn
        width: parent.width
        spacing: Theme.paddingMedium

        Behavior on opacity {
            NumberAnimation {
            }
        }
        opacity: visible ? 1 : 0
        visible: true

        Timer {
            id: lastUpdateUpdater
            interval: 60 * 1000
            running: true
            repeat: true
            onTriggered: {
                Functions.log("[DividendsView] - updating last update string ")
                dividendsHeader.description = getLastUpdateString();
            }
        }

        PageHeader {
            id: dividendsHeader
            //: DividendsView page header
            title: qsTr("Dividend dates")
            description: getLastUpdateString();
        }

        EmptyModelColumnLabel {
            id: dividendsEmptyModelColumnLabel
            theHeight: dividendsViewFlickable.height - dividendsHeader.height
            //: DividendsView empty marketdata label
            emptyLabel: qsTr("The dividend dates have not yet been loaded. Please load them via the pulley menu.")
        }

        SilicaListView {
            id: dividendsListView

            height: dividendsViewFlickable.height - dividendsHeader.height - Theme.paddingMedium
            width: parent.width
            anchors.left: parent.left
            anchors.right: parent.right

            clip: true

            model: ListModel {
                id: dividendsModel
            }

            delegate: ListItem {
                contentHeight: dividendsItem.height + (2 * Theme.paddingMedium)
                contentWidth: parent.width

                // no context menu

                Item {
                    id: dividendsItem
                    width: parent.width
                    height: dividendsRow.height + dividendDataSeparator.height
                    y: Theme.paddingMedium

                    Row {
                        id: dividendsRow
                        width: parent.width - (2 * Theme.horizontalPageMargin)
                        spacing: Theme.paddingMedium
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter

                        Column {
                            id: dividendColumn
                            width: parent.width
                            height: dividenNamePayDateRow.height + dividendDateRow.height

                            anchors.verticalCenter: parent.verticalCenter

                            Row {
                                id: dividenNamePayDateRow
                                width: parent.width
                                height: Theme.fontSizeSmall + Theme.paddingMedium

                                Label {
                                    id: dividendName
                                    width: parent.width * 8 / 10
                                    height: parent.height
                                    text: name
                                    truncationMode: TruncationMode.Fade
                                    color: Theme.primaryColor
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.bold: true
                                    horizontalAlignment: Text.AlignLeft
                                }

                                Text {
                                    id: dividendPaymentAmount
                                    width: parent.width * 2 / 10
                                    height: parent.height
                                    text: Functions.renderPrice(amount, currency, Constants.MARKET_DATA_TYPE_NONE);
                                    color: Theme.highlightColor
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.bold: true
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            Row {
                                id: dividendDateRow
                                width: parent.width
                                height: Theme.fontSizeExtraSmall + Theme.paddingSmall

                                Text {
                                    width: parent.width / 2
                                    height: parent.height
                                    text: ""
                                    color: Theme.primaryColor
                                    font.pixelSize: Theme.fontSizeExtraSmall
                                    horizontalAlignment: Text.AlignLeft
                                }

                                Text {
                                    width: parent.width / 2
                                    height: parent.height
                                    text: payDate
                                    color: Theme.primaryColor
                                    font.pixelSize: Theme.fontSizeExtraSmall
                                    horizontalAlignment: Text.AlignRight
                                }
                            }
                        }
                    }

                    Separator {
                        id: dividendDataSeparator
                        anchors.top: dividendsRow.bottom
                        anchors.topMargin: Theme.paddingMedium

                        width: parent.width
                        color: Theme.primaryColor
                        horizontalAlignment: Qt.AlignHCenter
                    }
                }
            }

            VerticalScrollDecorator {
            }
        }
    }

    VerticalScrollDecorator {
    }

    Component.onCompleted: {
        connectSlots();
        reloadAllDividends();
        loaded = true;
    }

    LoadingIndicator {
        id: dividendDataLoadingIndicator
        visible: !loaded
        Behavior on opacity {
            NumberAnimation {
            }
        }
        opacity: loaded ? 0 : 1
        height: parent.height
        width: parent.width
    }

}
