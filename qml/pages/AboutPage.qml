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

import "../components/thirdparty"

import "../js/database.js" as Database

Page {
    id: aboutPage
//    property bool showInfos: false

    SilicaFlickable {
        id: aboutPageFlickable
        anchors.fill: parent
        contentHeight: aboutColumn.height

        PullDownMenu {
            MenuItem {
                //: AboutPage pully - reset database
                text: qsTr("Reset Database")
                onClicked: {
                    Database.resetApplication()
                    Database.initApplicationTables()
                }
            }
        }

        Column {
            PageHeader {
                //: AboutPage title - header
                title: qsTr("About Watchlist")
            }

            id: aboutColumn
            anchors {
                left: parent.left
                right: parent.right
            }
            height: childrenRect.height

            LabelText {
                anchors {
                    left: parent.left
                    margins: Theme.paddingLarge
                }
                //: AboutPage title - about text title
                label: qsTr("About Watchlist")
                //: AboutPage text - about text
                text: qsTr("This is app is a simple stock watchlist for Sailfish OS. Watchlist is open source and licensed under the GPL v3.")
                separator: true
            }

            LabelText {
                anchors {
                    left: parent.left
                    margins: Theme.paddingLarge
                }
                //: AboutPage version label
                label: qsTr("Version")
                text: applicationVersion
                separator: true
            }

            BackgroundItem {
                id: clickableUrlAuthor
                contentHeight: labelAuthor.height
                height: contentHeight
                width: aboutPageFlickable.width
                anchors {
                    left: parent.left
                }

                LabelText {
                    id: labelAuthor
                    anchors {
                        left: parent.left
                        margins: Theme.paddingLarge
                    }
                    //: AboutPage author label
                    label: qsTr("Author")
                    text: "Andreas Wüst"
                    separator: true
                    color: clickableUrlAuthor.highlighted ? Theme.highlightColor : Theme.primaryColor
                }
//                onClicked: {
//                    aboutPage.showInfos = !aboutPage.showInfos;
//                }
            }

            LabelText {
                anchors {
                    left: parent.left
                    margins: Theme.paddingLarge
                }
                //: AboutPage translators label
                label: qsTr("Translators")
                text: qsTr("Viacheslav Dikonov (ru)") + "\n" +
                      "Åke Engelbrektson (sv)\n" +
                      "@KhanPuking (zh_CN)"
                separator: true
            }

            LabelText {
                anchors {
                    left: parent.left
                    margins: Theme.paddingLarge
                }
                //: AboutPage contributors label
                label: qsTr("Contributors")
                text: "Okxa (icon)\n" +
                      "dikonov (small patch)\n" +
                      "Dmitry Gerasimov (UI Cover patches)"
                separator: true
            }

            BackgroundItem {
                id: clickableUrlSourceCode
                contentHeight: labelUrl.height
                height: contentHeight
                width: aboutPageFlickable.width
                anchors {
                    left: parent.left
                }

                LabelText {
                    id: labelUrl
                    anchors {
                        left: parent.left
                        margins: Theme.paddingLarge
                    }
                    //: AboutPage about source label
                    label: qsTr("Source code")
                    text: "https://github.com/andywuest/harbour-watchlist"
                    color: clickableUrlSourceCode.highlighted ? Theme.highlightColor : Theme.primaryColor
                }
                onClicked: Qt.openUrlExternally(labelUrl.text)
            }

//            LabelText {
//                visible: aboutPage.showInfos
//                anchors {
//                    left: parent.left
//                    margins: Theme.paddingLarge
//                }
//                //: AboutPage translators label
//                label: qsTr("Debug Infos")
//                text: "WiFi : " + (watchlist.isWiFi() ? "on" : "off") +
//                      "\n" + qsTr("Screen size : ") + aboutPage.width + "x" + aboutPage.height;
//                separator: true
//            }
        }
    }

    VerticalScrollDecorator {
        flickable: aboutPageFlickable
    }
}
