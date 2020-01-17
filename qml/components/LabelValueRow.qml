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
        text: "Bid"
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
        text: "" + "23.4 €"
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeSmall
        // font.bold: true
        horizontalAlignment: Text.AlignRight
    }
}
