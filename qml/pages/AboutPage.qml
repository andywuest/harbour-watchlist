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

import "../js/constants.js" as Constants
import "../js/database.js" as Database

Page {
    id: aboutPage
    property bool showInfos: false

    SilicaFlickable {
        id: aboutPageFlickable
        anchors.fill: parent
        contentHeight: aboutColumn.height

        PullDownMenu {
            MenuItem {
                text: qsTr("Reset Database")
                onClicked: {
                    Database.resetApplication()
                    Database.initApplicationTables()
                    // reload the model to make sure we have the latest state
                    //flickable.reloadModelFromDatabase(listView.model);
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
                text: Constants.VERSION
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
                onClicked: {
                    aboutPage.showInfos = !aboutPage.showInfos;
                }
            }

            LabelText {
                anchors {
                    left: parent.left
                    margins: Theme.paddingLarge
                }
                //: AboutPage translators label
                label: qsTr("Translators")
                text: "dikonov (ru)\n" +
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
                      "dikonov (small patch)"
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
                onClicked: {
                    // openInDefaultApp("https://github.com/steffen-foerster/sailfish-barcode");
                    Qt.openUrlExternally(labelUrl.text)
                    // Qt.openUrlExternally(labelUrl.text)
                }
            }

            LabelText {
                visible: aboutPage.showInfos
                anchors {
                    left: parent.left
                    margins: Theme.paddingLarge
                }
                //: AboutPage translators label
                label: "Debug Infos"
                text: "WiFi : " + (watchlist.isWiFi() ? "on" : "off") +
                      "\nScreen size : " + aboutPage.width + "x" + aboutPage.height;
                separator: true
            }
        }
    }

    VerticalScrollDecorator {
        flickable: aboutPageFlickable
    }
}
