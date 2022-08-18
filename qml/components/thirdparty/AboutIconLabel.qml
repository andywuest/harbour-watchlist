import QtQuick 2.2
import Sailfish.Silica 1.0

BackgroundItem {
    property alias iconSource: icon.source
    property alias label: label.text
    property string targetUrl

    width: parent.width
    height: Theme.itemSizeMedium
    Row {
        x: Theme.horizontalPageMargin
        width: parent.width - 2 * x
        height: parent.height
        spacing: Theme.paddingMedium

        Image {
            id: icon
            width: parent.height
            height: width
            fillMode: Image.PreserveAspectFit
            anchors.verticalCenter: parent.verticalCenter
        }

        Label {
            id: label
            width: parent.width - parent.height - parent.spacing
            anchors.verticalCenter: parent.verticalCenter
            wrapMode: Text.WrapAnywhere
            font.pixelSize: Theme.fontSizeSmall
            color: parent.parent.pressed ? Theme.highlightColor : Theme.primaryColor
        }
    }
    onClicked: Qt.openUrlExternally(targetUrl)
}
