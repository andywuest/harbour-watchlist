import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: addStockPage

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: column

            width: eventPage.width
            spacing: Theme.paddingLarge

            PageHeader {
                id: pageHeader
                title: qsTr("Add Stock")
            }


            //            Label {
            //                id: eventLabel
            //                x: Theme.horizontalPageMargin
            //                width: parent.width - 2*x
            //                text: "This is the  asdf asdf asdfa sdf as dfa sdf asfa sdfasd fa sdf asd f(not yet dynamic) - " + eventPage.selectedIndex
            //                wrapMode: Text.Wrap
            ////                onSelectedIndexSignal:  console.log("signal received : " + index)

            //                    //eventLabel.text
            ////                color: Theme.secondaryHighlightColor
            ////                font.pixelSize: Theme.fontSizeExtraLarge

            //            }
            TextField {
                id: textFieldTickerSymbol
                anchors {
                    top: pageHeader.bottom
                }

                width: parent.width - (2 * Theme.horizontalPageMargin)
                label: "Yahoo Ticker Symbol"
                placeholderText: "Ticker symbol"
            }

            Button {
                id: buttonLookupSymbol
                text: "Show settings"

                anchors {
                    horizontalCenter: parent.horizontalCenter
                }

//                width: parent.width - (2 * Theme.horizontalPageMargin)

                onClicked: pageStack.push(Qt.resolvedUrl("TalkSettings.qml"), {
                                              selectedIndex: "" + selectedIndex
                                          })
            }
        }
    }
}
