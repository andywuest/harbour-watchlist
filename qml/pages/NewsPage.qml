/*
 * harbour-watchlist - Sailfish OS Version
 * Copyright © 2020 Andreas Wüst (andreas.wuest.freelancer@gmail.com)
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

import "../js/functions.js" as Functions

Page {
    id: newsPage
    property var newsItem

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors {
            fill: parent
            bottomMargin: Theme.paddingMedium
        }

        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: column
            x: Theme.horizontalPageMargin
            width: parent.width - 2 * x
            spacing: Theme.paddingSmall

            PageHeader {
                //: NewsPage news page header
                title: qsTr("News")
            }

            Label {
                id: headlineLabel
                text: newsItem.headline
                width: parent.width
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeLarge
            }

            Label {
                id: dateTimeSourceLabel
                text: newsItem.dateTime + " | " + newsItem.source
                textFormat: Text.RichText
                width: parent.width
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeTiny
            }

            Label {
                id: contentLabel
                text: newsItem.content
                width: parent.width
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeExtraSmall
            }
        }
    }

}
