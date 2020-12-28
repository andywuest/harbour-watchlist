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
import QtQuick 2.0
import Sailfish.Silica 1.0

Row {
    property alias label: labelText.text

    id: labelValueRow
    width: parent.width - (2 * Theme.paddingLarge) - Theme.paddingMedium
    height: Theme.fontSizeSmall + Theme.paddingLarge + labelText.height
    spacing: Theme.paddingMedium
    y: Theme.paddingLarge
    x: Theme.paddingLarge

    Text {
        id: labelText
        width: parent.width
        text: ""
        wrapMode: Text.WordWrap
        color: Theme.primaryColor
        font.pixelSize: Theme.fontSizeSmall
        horizontalAlignment: Text.AlignLeft
    }

}
