import QtQuick 2.2
import Sailfish.Silica 1.0

Page {
    id: page

    allowedOrientations: Orientation.All

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width:parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                //: AboutComponent - Header
                title: qsTr("About")
            }

            Image {
                id: logo
                source: "/usr/share/icons/hicolor/172x172/apps/harbour-watchlist.png" // TODO SVG
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

                //: AboutComponent - Name
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
                //: AboutComponent text - about text
                description: qsTr("This is app is a simple stock watchlist for Sailfish OS. Watchlist is open source and licensed under the GPL v3.")
            }

            SectionHeader {
                //: AboutComponent - Translations
                text: qsTr("Translations")
            }

            AboutDescription {
                //: AboutComponent - translations
                description: qsTr("Viacheslav Dikonov (ru)") + "\n" +
                             "Åke Engelbrektson (sv)\n" +
                             "@KhanPuking (zh_CN)\n" +
                             "pherjung (fr)"
            }

            SectionHeader{
                id: sectionHeaderSources
                //: AboutComponentn - sources
                text: qsTr("Sources")
            }

            AboutIconLabel {
                iconSource: "../../../qml/pages/icons/github.svg"
                label: "https://github.com/andywuest/harbour-watchlist"
                targetUrl: "https://github.com/andywuest/harbour-watchlist"
            }

            SectionHeader{
                //: AboutComponent - Donations
                text: qsTr("Donations")
            }

            AboutDescription {
                //: AboutComponent - donations info
                description: qsTr("If you like my work why not buy me a beer?")
            }

            AboutIconLabel {
                iconSource: "../../../qml/pages/icons/paypal.svg"
                label: qsTr("Donate with PayPal")
                targetUrl: "https://www.paypal.com/paypalme/andywuest/TODO"
            }

            Item {
                width: 1
                height: Theme.paddingSmall
            }
        }
    }
}
