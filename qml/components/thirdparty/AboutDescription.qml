import QtQuick 2.0
import Sailfish.Silica 1.0

Label {
    id: label
    property alias description: label.text

    x : Theme.horizontalPageMargin
    width: parent.width - 2*x
    wrapMode: Text.WordWrap
    font.pixelSize: Theme.fontSizeSmall
    text: ""
}
