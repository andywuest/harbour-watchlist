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

import "../components/thirdparty"

import "../js/database.js" as Database

Page {
    id: page

    allowedOrientations: Orientation.All

    SilicaFlickable {
        id: aboutPageFlickable
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {
            MenuItem {
                //: AboutPage pully - reset database
                text: qsTr("Reset Database")
                onClicked: {
                    var remorse = Remorse.popupAction(root, "", function () {
                        Database.resetApplication()
                        Database.initApplicationTables()
                    }, 4000);
                }
            }
        }

        Column {
            id: column
            width:parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                //: AboutPage - Header
                title: qsTr("About")
            }

            Image {
                id: logo
                source: "/usr/share/icons/hicolor/172x172/apps/harbour-watchlist.png"
                smooth: true
                height: width
                width: parent.width / 2
                sourceSize.width: 512
                sourceSize.height: 512
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 0.7
            }

            Label {
                width: parent.width
                x : Theme.horizontalPageMargin
                font.pixelSize: Theme.fontSizeExtraLarge
                color: Theme.secondaryHighlightColor

                //: AboutPage - Name
                text: qsTr("Watchlist")
            }

            Label {
                width: parent.width
                x : Theme.horizontalPageMargin
                text: applicationVersion
            }

            Item {
                height: Theme.paddingMedium
                width: 1
            }

            AboutDescription {
                //: AboutPage text - about text
                description: qsTr("This is app is a simple stock watchlist for Sailfish OS. Watchlist is open source and licensed under the GPL v3.")
            }

            SectionHeader {
                //: AboutPage - Translations
                text: qsTr("Translations")
            }

            AboutDescription {
                //: AboutPage - translations
                description: qsTr("Viacheslav Dikonov (ru)") + "\n" +
                             "Åke Engelbrektson (sv)\n" +
                             "@KhanPuking (zh_CN)\n" +
                             "pherjung (fr)"
            }

            SectionHeader{
                id: sectionHeaderSources
                //: AboutPage - sources
                text: qsTr("Sources")
            }

            AboutIconLabel {
                iconSource: "icons/github.svg"
                label: "https://github.com/andywuest/harbour-watchlist"
                targetUrl: "https://github.com/andywuest/harbour-watchlist"
            }

            SectionHeader{
                //: AboutPage - Donations
                text: qsTr("Donations")
            }

            AboutDescription {
                //: AboutPage - donations info
                description: qsTr("If you like my work why not buy me a beer?")
            }

            AboutIconLabel {
                iconSource: "icons/paypal.svg"
                label: qsTr("Donate with PayPal")
                targetUrl: "https://www.paypal.com/paypalme/andywuest"
            }

            Item {
                width: 1
                height: Theme.paddingSmall
            }
        }
    }

    VerticalScrollDecorator {
        flickable: aboutPageFlickable
    }
}
