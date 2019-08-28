/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
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

