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
    id: page

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaListView {
        id: listView


        model: ListModel {
                   id: stocksModel
        }


        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("Show Page 2")
                onClicked: pageStack.push(Qt.resolvedUrl("SecondPage.qml"))
            }
        }

        // Tell SilicaFlickable the height of its content.
        // contentHeight: column.height

        VerticalScrollDecorator {}

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.

        Column {
            id: column

            width: parent.width - ( 2 * Theme.horizontalPageMargin )
                    spacing: Theme.paddingSmall
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        verticalCenter: parent.verticalCenter
                    }


                    Row {
                        id: tweetRow
                        width: parent.width
                            spacing: Theme.paddingMedium


                            Column {
                                            id: tweetAuthorColumn
                                            width: parent.width / 6
                                            height: parent.width / 6
                                            spacing: Theme.paddingSmall

                                            Text {
                                                                    id: tweetRetweetedText
                                                                    font.pixelSize: Theme.fontSizeTiny
                                                                    color: Theme.secondaryColor
                                                                    text: qsTr("xxxx test")
                                                                    visible: true
                                            }

                            }





                            Column {
                                            id: tweetContentColumn
                                            width: parent.width * 5 / 6 - Theme.horizontalPageMargin

                                            spacing: Theme.paddingSmall

                                            Text {
                                                                    id: tweetRetweetedText2
                                                                    font.pixelSize: Theme.fontSizeTiny
                                                                    color: Theme.secondaryColor
                                                                    text: qsTr("ganz viel")
                                                                    visible: true
                                            }

                            }


                    }


//             width: page.width
//             spacing: Theme.paddingLarge
//            PageHeader {
//                title: qsTr("UI Template")
//            }


            Label {
                x: Theme.horizontalPageMargin
                text: qsTr("Hello Sailors")
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeExtraLarge
            }
        }
        Component.onCompleted: {
            getQuotes();
            }

    }

    function determineChangeColor(change) {
        var color = Theme.primaryColor
        if (change < 0.0) {
            color = '#FF0000';
        } else if (change > 0.0) {
            color = '#00FF00';
        }
        return color;
    }

    function renderChange(change) {
        var prefix = "";
        if (change > 0.0) {
            prefix = "+";
        }
        return prefix + Number(change).toLocaleString(Qt.locale("de_DE"));
    }


    function getQuotes() {

        // do not replace the %26 - will render the request invalid
        // var url = "https://query.yahooapis.com/v1/public/yql?q=select * from csv where url='http://download.finance.yahoo.com/d/quotes.csv?s=SIE.DE,OSR.DE%26f=nsl1d1t1c1ohgv%26e=.csv' and columns='name,symbol,price,date,time,change,col1,high,low,col2'&format=json&env=store://datatables.org/alltableswithkeys"

        var url = "https://query.yahooapis.com/v1/public/yql?q=select * from csv where url='http://download.finance.yahoo.com/d/quotes.csv?s=%1%26f=nsl1d1t1c1ohgv%26e=.csv' and columns='name,symbol,price,date,time,change,col1,high,low,col2'&format=json&env=store://datatables.org/alltableswithkeys";
        url = url.arg("SIE.DE,OSR.DE,FPE3.DE,OSB")

        var request = new XMLHttpRequest();
                    request.open('GET', url)
                    request.onreadystatechange = function() {
                        if (request.readyState === XMLHttpRequest.DONE) {
                            if (request.status && request.status === 200) {
                                console.log("response", request.responseText)
                                var result = JSON.parse(request.responseText)

                                console.log("count : " + result.query.count);
                                console.log("rows : " + result.query.results.row);

                                for (var i = 0; i < result.query.count; i++) {
                                  stocksModel.append(result.query.results.row[i]);
                                }


                                //

                                // console.log("results : " + result);
                                //main.friends = result.response
                            } else {
                                console.log("HTTP:", request.status, request.statusText)
                            }
                        }
                    }
                    request.setRequestHeader('Content-Type', 'application/json;charset=utf-8')
                    // request.send('fields=photo_medium&uid=%1'.arg("blubb"))
        request.send();

    }



}

