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
import QtQuick 2.2
import QtQuick.LocalStorage 2.0
import Sailfish.Silica 1.0

SilicaFlickable {
    id: stockNewsViewFlickable

    contentHeight: stockNewsColumn.height

    Column {
        id: stockNewsColumn

        x: Theme.horizontalPageMargin
        width: parent.width - 2 * x
        spacing: Theme.paddingSmall

        anchors {
            left: parent.left
            right: parent.right
        }

        Label {
            horizontalAlignment: Text.AlignHCenter
            x: Theme.horizontalPageMargin
            width: parent.width - 2 * x

            wrapMode: Text.Wrap
            text: "This is not yet implemented - if you know a good source for stock news (json format!) - please drop me a line"
        }
    }

}
