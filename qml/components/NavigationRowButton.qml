/*
    Copyright (C) 2017-20 Sebastian J. Wolf

    This file is part of Piepmatz.

    Piepmatz is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Piepmatz is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Piepmatz. If not, see <http://www.gnu.org/licenses/>.
*/
import QtQuick 2.0
import QtGraphicalEffects 1.0
import Sailfish.Silica 1.0

Column {
    id: notificationRowButton

    property string buttonText
    property string iconSource
    property bool isActive: false

    width: parent.width

    // can be overwritten by the extending qml components
    function runOnClick() {
    }

    IconButton {
        id: notificationRowImage
        icon.source: notificationRowButton.isActive ? iconSource + "?" + Theme.highlightColor : iconSource + "?" + Theme.primaryColor
        height: Theme.iconSizeMedium
        width: Theme.iconSizeMedium
        anchors {
            horizontalCenter: parent.horizontalCenter
        }
        onClicked: runOnClick();
    }

    Label {
        id: notificationRowButtonText
        text: buttonText
        font.pixelSize: Theme.fontSizeTiny * 7 / 8
        color: notificationRowButton.isActive ? Theme.highlightColor : Theme.primaryColor
        truncationMode: TruncationMode.Fade
        anchors {
            horizontalCenter: parent.horizontalCenter
        }
        MouseArea {
            anchors.fill: parent
            onClicked: runOnClick();
        }
    }

}
