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

Page {
    id: addStockPage

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: column

            width: eventPage.width
            spacing: Theme.paddingLarge

            PageHeader {
                id: pageHeader
                title: qsTr("Add Stock")
            }


            //            Label {
            //                id: eventLabel
            //                x: Theme.horizontalPageMargin
            //                width: parent.width - 2*x
            //                text: "This is the  asdf asdf asdfa sdf as dfa sdf asfa sdfasd fa sdf asd f(not yet dynamic) - " + eventPage.selectedIndex
            //                wrapMode: Text.Wrap
            ////                onSelectedIndexSignal:  console.log("signal received : " + index)

            //                    //eventLabel.text
            ////                color: Theme.secondaryHighlightColor
            ////                font.pixelSize: Theme.fontSizeExtraLarge

            //            }
            TextField {
                id: textFieldTickerSymbol
                anchors {
                    top: pageHeader.bottom
                }

                width: parent.width - (2 * Theme.horizontalPageMargin)
                label: "Yahoo Ticker Symbol"
                placeholderText: "Ticker symbol"
            }

            Button {
                id: buttonLookupSymbol
                text: "Show settings"

                anchors {
                    horizontalCenter: parent.horizontalCenter
                }

//                width: parent.width - (2 * Theme.horizontalPageMargin)

                onClicked: pageStack.push(Qt.resolvedUrl("TalkSettings.qml"), {
                                              selectedIndex: "" + selectedIndex
                                          })
            }
        }
    }
}
