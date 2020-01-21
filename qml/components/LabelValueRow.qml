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
import QtQuick 2.0
import Sailfish.Silica 1.0

Row {
    property alias label: labelText.text
    property alias value: valueText.text

    id: labelValueRow
    width: parent.width - (2 * Theme.paddingLarge) - Theme.paddingMedium
    height: Theme.fontSizeSmall + Theme.paddingLarge
    spacing: Theme.paddingMedium
    y: Theme.paddingLarge
    x: Theme.paddingLarge

    Text {
        id: labelText
        width: parent.width * 8 / 10
        height: parent.height
        text: ""
        // truncationMode: TruncationMode.Elide // TODO check for very long texts
        color: Theme.primaryColor
        font.pixelSize: Theme.fontSizeSmall
        // font.bold: true
        horizontalAlignment: Text.AlignLeft
    }

    Text {
        id: valueText
        width: parent.width * 2 / 10
        height: parent.height
        text: ""
        color: Theme.secondaryColor
        font.pixelSize: Theme.fontSizeSmall
        // font.bold: true
        horizontalAlignment: Text.AlignRight
    }
}
