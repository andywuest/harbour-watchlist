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

import "../js/constants.js" as Constants
import "../js/database.js" as Database
import "../js/functions.js" as Functions

CoverBackground {

    //    Label {
    //        id: label
    //        anchors.centerIn: parent
    //        text: qsTr("My Cover")
    //    }
    CoverActionList {
        id: coverActionPrevious
        enabled: true

        CoverAction {
            id: actionPreviousPrevious
            iconSource: "image://theme/icon-cover-previous"
            onTriggered: {
                console.log("previous clicked")
                coverActionPrevious.enabled = false
                coverActionNext.enabled = true
                reloadAllStocks()
            }
        }

        CoverAction {
            id: actionRefresh
            iconSource: "image://theme/icon-cover-refresh"
            onTriggered: console.log("refresh clicked prev")
        }
    }

    CoverActionList {
        id: coverActionNext
        enabled: false

        CoverAction {
            id: actionNext
            iconSource: "image://theme/icon-cover-next"
            onTriggered: {
                console.log("previous clicked")
                coverActionNext.enabled = false
                coverActionPrevious.enabled = true
                reloadAllStocks()
            }
        }

        CoverAction {
            id: actionRefreshNext
            iconSource: "image://theme/icon-cover-refresh"
            onTriggered: console.log("refresh clicked next")
        }
    }

    Column {
        //spacing: Theme.paddingSmall
        width: parent.width
        height: parent.height

        anchors {
            top: parent.top
            topMargin: Theme.paddingMedium
            left: parent.left
            //leftMargin: Theme.paddingMedium
            right: parent.right
            rightMargin: Theme.paddingMedium
            bottom: parent.bottom
        }

        Text {
            id: labelTitle
            width: parent.width
            text: coverActionPrevious.enabled ? qsTr("Top") : qsTr("Flop")
            color: Theme.primaryColor
            font.bold: true
            font.pixelSize: Theme.fontSizeSmall
            textFormat: Text.StyledText
            horizontalAlignment: Text.AlignHCenter
        }

        SilicaListView {
            id: coverListView

            height: parent.height - labelTitle.height - Theme.paddingSmall
            width: parent.width

            // visible: !coverPage.loading

//            Behavior on opacity {
//                NumberAnimation {
//                }
//            }


            // opacity: coverPage.loading ? 0 : 1
//            anchors {
//                top: labelTitle.bottom //parent.top
//                topMargin: Theme.paddingSmall
//                left: parent.left
//                leftMargin: Theme.paddingSmall
//                right: parent.right
//                rightMargin: Theme.paddingSmall
//                bottom: parent.bottom
//            }

            anchors.left: parent.left
            anchors.right: parent.right

            clip: true

            model: ListModel {
                id: coverModel
            }

            delegate: ListItem {

                anchors {
                    topMargin: Theme.paddingSmall
                }


                // height: resultLabelTitle.height + resultLabelContent.height + Theme.paddingSmall
                opacity: index < 4 ? 1.0 - index * 0.2 : 0.0

                Item {
                    id: stockQuoteItem
                    width: parent.width
                    // height: stockQuoteRow.height + stockQuoteSeparator.height
                    height: stockQuoteColumn.height + thirdRow.height  + Theme.paddingSmall
                    y: Theme.paddingSmall

                    Row {
                        id: stockQuoteRow
                        width: parent.width - (2 * Theme.horizontalPageMargin)
//                        spacing: Theme.paddingSmall
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter

                        // TODO custom - hier noch pruefen, was an margins noch machbar, sinnvoll ist
                        Column {
                            id: stockQuoteColumn
                            width: parent.width // - (2 * Theme.horizontalPageMargin)
                            // x: Theme.horizontalPageMargin
                            height: firstRow.height //+ changeRow.height
                            /* + secondRow.height*/ + thirdRow.height
                            anchors.verticalCenter: parent.verticalCenter

                            Row {
                                id: firstRow
                                width: parent.width
                                height: Theme.fontSizeExtraSmall + Theme.paddingSmall

                                Text {
                                    id: stockQuoteName
                                    width: parent.width // * 8 / 10
                                    height: parent.height
                                    text: name
                                    // truncationMode: TruncationMode.Elide // TODO check for very long texts
                                    color: Theme.primaryColor
                                    font.pixelSize: Theme.fontSizeExtraSmall
                                    font.bold: true
                                    horizontalAlignment: Text.AlignLeft
                                    elide: Text.ElideRight
                                }

                                //                            Text {
                                //                                id: stockQuoteChange
                                //                                width: parent.width * 2 / 10
                                //                                height: parent.height
                                //                                text: price
                                ////                                    (price
                                ////                                       !== undefined ? Number(
                                ////                                                           price).toLocaleString(
                                ////                                                           Qt.locale(
                                ////                                                               "de_DE")) + " \u20AC" : "-")

                                //                                color: Theme.highlightColor
                                //                                font.pixelSize: Theme.fontSizeExtraSmall
                                //                                font.bold: true
                                //                                horizontalAlignment: Text.AlignRight
                                //                            }
                            }


                            //                        Row {
                            //                            id: changeRow
                            //                            width: parent.width
                            //                            height: 7

                            //                            Rectangle {
                            //                                id: changeRowRectangle
                            //                                width: calculateWidth(changeRelative,
                            //                                                      maxChange,
                            //                                                      parent.width)
                            //                                height: parent.height
                            //                                color: determineChangeColor(
                            //                                           changeRelative)

                            //                                function calculateWidth(change, maxChange, parentWidth) {
                            //                                    if (maxChange === 0.0) {
                            //                                        return parentWidth
                            //                                    } else {
                            //                                        var result = parentWidth * Math.abs(
                            //                                                    change) / maxChange
                            //                                        console.log("change length: " + result)
                            //                                        return result
                            //                                    }
                            //                                }
                            //                            }
                            //                        }

                            //                        Row {
                            //                            id: secondRow
                            //                            width: parent.width
                            //                            visible: false;
                            //                            height: Theme.fontSizeMedium + Theme.paddingMedium

                            //                            //                                    anchors {
                            //                            //                                        left: parent.left
                            //                            //                                        right: parent.right
                            //                            //                                        top: firstRow.bottom
                            //                            //                                    }
                            //                            Column {
                            //                                id: tweetAuthorColumn2
                            //                                width: parent.width * 3 / 6

                            //                                // height: parent.width *2 / 6
                            //                                //spacing: Theme.paddingSmall
                            //                                Text {
                            //                                    id: title2
                            //                                    text: ""
                            //                                    font.pixelSize: Theme.fontSizeMedium
                            //                                }
                            //                            }

                            //                            Column {
                            //                                id: tweetContentColumn2
                            //                                width: parent.width * 3 / 6 //- Theme.horizontalPageMargin

                            //                                //spacing: Theme.paddingSmall
                            //                                Text {
                            //                                    id: lastPrice2
                            //                                    text: (price
                            //                                           !== undefined ? Number(
                            //                                                               price).toLocaleString(
                            //                                                               Qt.locale(
                            //                                                                   "de_DE")) + " \u20AC   "
                            //                                                           + renderChange(
                            //                                                               changeAbsolute,
                            //                                                               '\u20AC') : "-")
                            //                                    color: determineChangeColor(
                            //                                               changeAbsolute)
                            //                                    font.pixelSize: Theme.fontSizeMedium
                            //                                    horizontalAlignment: Text.AlignHCenter
                            //                                }
                            //                            }
                            //                        }
                            Row {
                                id: thirdRow
                                width: parent.width
                                height: Theme.fontSizeTiny + Theme.paddingSmall

                                Text {
                                    id: stockQuoteChange
                                    width: parent.width / 2
                                    /// 10
                                    height: parent.height
                                    text: Functions.renderPrice(price, "\u20AC");
                                        //price

//                                                                        (price
//                                                                           !== undefined ? Number(
//                                                                                               price).toLocaleString(
//                                                                                               Qt.locale(
//                                                                                                   "de_DE")) + " \u20AC" : "-")
                                    color: Theme.highlightColor
                                    font.pixelSize: Theme.fontSizeTiny
                                    font.bold: true
                                    horizontalAlignment: Text.AlignLeft
                                }

                                //                            Text {
                                //                                id: changeDateText
                                //                                width: parent.width / 2
                                //                                height: parent.height
                                //                                text: quoteTimestamp
                                //                                    // determineQuoteDate(quoteTimestamp)
                                //                                color: Theme.primaryColor
                                //                                font.pixelSize: Theme.fontSizeTiny
                                //                                horizontalAlignment: Text.AlignLeft
                                //                            }
                                Text {
                                    id: changePercentageText
                                    width: parent.width / 2
                                    height: parent.height
                                    text: Functions.renderChange(price, changeRelative, '%')
                                        // changeRelative
//                                                                        (changeRelative
//                                                                           !== undefined ? renderChange(
//                                                                                               changeRelative,
//                                                                                               '%') : "-")
                                    color: Functions.determineChangeColor(changeRelative)
                                    font.pixelSize: Theme.fontSizeTiny
                                    horizontalAlignment: Text.AlignRight
                                }
                            }
                        }
                    }

                    //                Separator {
                    //                    id: stockQuoteSeparator
                    //                    anchors.top: stockQuoteRow.bottom
                    //                    anchors.topMargin: Theme.paddingMedium

                    //                    width: parent.width
                    //                    color: Theme.primaryColor
                    //                    horizontalAlignment: Qt.AlignHCenter
                    //                }
                }

                //            Column {
                //                width: parent.width
                //                Row {
                //                    id: resultTitleRow
                //                    spacing: Theme.paddingSmall
                //                    width: parent.width
                //                    Image {
                //                        id: resultTitlePicture
                //                        source: display.image
                //                        width: Theme.fontSizeExtraSmall
                //                        height: Theme.fontSizeExtraSmall
                //                        sourceSize {
                //                            width: Theme.fontSizeExtraSmall
                //                            height: Theme.fontSizeExtraSmall
                //                        }
                //                    }
                //                    Text {
                //                        id: resultLabelTitle
                //                        width: parent.width - Theme.paddingSmall - resultTitlePicture.width
                //                        maximumLineCount: 1
                //                        color: Theme.primaryColor
                //                        font.pixelSize: Theme.fontSizeTiny
                //                        font.bold: true
                //                        text: Emoji.emojify(display.name, Theme.fontSizeTiny)
                //                        textFormat: Text.StyledText
                //                        elide: Text.ElideRight
                //                        onTruncatedChanged: {
                //                            // There is obviously a bug in QML in truncating text with images.
                //                            // We simply remove Emojis then...
                //                            if (truncated) {
                //                                text = text.replace(/\<img [^>]+\/\>/g, "")
                //                            }
                //                        }
                //                    }
                //                }
                //                Text {
                //                    id: resultLabelContent
                //                    maximumLineCount: 2
                //                    color: Theme.primaryColor
                //                    font.pixelSize: Theme.fontSizeTiny
                //                    text: Emoji.emojify(display.text, Theme.fontSizeTiny)
                //                    textFormat: Text.StyledText
                //                    width: parent.width
                //                    wrapMode: Text.Wrap
                //                    elide: Text.ElideRight
                //                    onTruncatedChanged: {
                //                        // There is obviously a bug in QML in truncating text with images.
                //                        // We simply remove Emojis then...
                //                        if (truncated) {
                //                            text = text.replace(/\<img [^>]+\/\>/g, "")
                //                        }
                //                    }
                //                }
                //            }
            }

            Component.onCompleted: {
                Database.initApplicationTables()
                reloadAllStocks()
            }

            onVisibleChanged: {
                if (coverListView.visible) {
                    reloadAllStocks()
                } else {
                    console.log("visiblieitey of list view chagned ! -> not visible")
                }
            }
        }
    }

    function reloadAllStocks() {
        coverModel.clear()
        var stocks = Database.loadAllStockData(1, Database.SORT_BY_CHANGE_ASC)
        if (coverActionPrevious.enabled) {
            stocks.reverse();
        }

        var reducedStockList = stocks;
        if (stocks.length > 5) {
            reducedStockList = stocks.slice(0, 5);
//            if (!coverActionPrevious.enabled) {
//                reducedStockList.reverse();
//            }
        }

        for (var i = 0; i < reducedStockList.length/*) || i < 2*/; i++) {
            coverModel.append(reducedStockList[i])
        }
    }
}
