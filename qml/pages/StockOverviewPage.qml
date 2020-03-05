import QtQuick 2.0
import QtGraphicalEffects 1.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import Nemo.Notifications 1.0

import "../components"

Page {
    id: overviewPage // TODO rename to stockOverviewPage

    property var stock
    property var theStock
    allowedOrientations: Orientation.All

    property int activeTabId: 0

    function openTab(tabId) {

        activeTabId = tabId

        switch (tabId) {
        case 0:
            detailsButtonPortrait.isActive = true
            chartsButtonPortrait.isActive = false
            newsButtonPortrait.isActive = false
            break
        case 1:
            detailsButtonPortrait.isActive = false
            chartsButtonPortrait.isActive = true
            newsButtonPortrait.isActive = false
            break
        case 2:
            detailsButtonPortrait.isActive = false
            chartsButtonPortrait.isActive = false
            newsButtonPortrait.isActive = true
            break
        default:
            console.log("Some strange navigation happened!")
        }
    }

    function getNavigationRowSize() {
        return Theme.iconSizeMedium + Theme.fontSizeMedium + Theme.paddingMedium
    }

    function handleDetailsClicked() {
        if (overviewPage.activeTabId === 0) {
            stockDetailsView.scrollToTop()
        } else {
            viewsSlideshow.opacity = 0
            slideshowVisibleTimer.goToTab(0)
            openTab(0)
        }
    }

    function handleChartsClicked() {
        if (overviewPage.activeTabId === 1) {
            stockChartsView.scrollToTop()
        } else {
            viewsSlideshow.opacity = 0
            slideshowVisibleTimer.goToTab(1)
            openTab(1)
        }
    }

    function handleNewsClicked() {
        if (overviewPage.activeTabId === 2) {
            stockDetailsView.scrollToTop()
        } else {
            viewsSlideshow.opacity = 0
            slideshowVisibleTimer.goToTab(2)
            openTab(2)
        }
    }

    SilicaFlickable {
        id: overviewContainer
        anchors.fill: parent
        visible: true
        contentHeight: parent.height
        contentWidth: parent.width

        PullDownMenu {
            MenuItem {
                text: qsTr("About Watchlist")
                onClicked: pageStack.push(aboutPage)
            }
        }

        Column {
            id: overviewColumn
            // opacity: 0
            visible: true
            Behavior on opacity {
                NumberAnimation {
                }
            }
            width: parent.width
            height: parent.height

            Column {
                id: theheader
                width: parent.width
                height: somePageHeader.height

                PageHeader {
                    id: somePageHeader
                    title: "SOME STOCK"
                }
            }

            Row {
                id: overviewRow
                width: parent.width
                height: parent.height - (overviewPage.isLandscape ? 0 : getNavigationRowSize(
                                                                        )) - theheader.height
                spacing: Theme.paddingSmall

                VisualItemModel {
                    id: viewsModel

                    Item {
                        id: detailsColumn
                        width: viewsSlideshow.width
                        height: viewsSlideshow.height

                        property bool loaded: true
                        property bool reloading: false

//                        Column {
//                            width: parent.width
//                            height: homeProgressLabel.height
//                                    + homeProgressIndicator.height + Theme.paddingSmall
//                            visible: !homeView.loaded
//                            opacity: homeView.loaded ? 0 : 1
//                            id: homeProgressColumn
//                            spacing: Theme.paddingSmall
//                            Behavior on opacity {
//                                NumberAnimation {
//                                }
//                            }
//                            anchors.verticalCenter: parent.verticalCenter

//                            InfoLabel {
//                                id: homeProgressLabel
//                                text: qsTr("Loading timeline...")
//                            }

//                            BusyIndicator {
//                                id: homeProgressIndicator
//                                anchors.horizontalCenter: parent.horizontalCenter
//                                running: !homeView.loaded
//                                size: BusyIndicatorSize.Large
//                            }
//                        }

                        StockDetailsView {
                            id: stockDetailsView
                            width: parent.width
                            height: parent.height
                            stock: theStock
                        }

                        //                        SilicaListView {
                        //                            id: homeListView
                        //                            opacity: homeView.loaded ? 1 : 0
                        //                            Behavior on opacity { NumberAnimation {} }
                        //                            visible: homeView.loaded
                        //                            width: parent.width
                        //                            height: parent.height
                        //                            contentHeight: 500 //homeTimelineTweet.height
                        //                            clip: true

                        //                            Label {
                        //                                id: xx
                        //                                text: "home view";

                        //                            }

                        //                            VerticalScrollDecorator {}
                        //                        }
                    }

                    Item {
                        id: chartsColumn
                        width: viewsSlideshow.width
                        height: viewsSlideshow.height

                        //property bool updateInProgress: false

                        StockChartsView {
                            id: stockChartsView
                            width: parent.width
                            height: parent.height
                            screenHeight: overviewPage.height
                            // stock: stock
                        }

//                        SilicaListView {
//                            anchors {
//                                fill: parent
//                            }
//                            id: mentionsListView

//                            clip: true

//                            Label {
//                                id: viewsoncd
//                                text: "second view"
//                            }

//                            // model: mentionsModel
//                            delegate: Component {
//                                Loader {
//                                    width: mentionsListView.width
//                                    property variant mentionsData: display
//                                    property bool isRetweet: display.retweeted_status ? ((display.retweeted_status.user.id_str === overviewPage.myUser.id_str) ? true : false) : false

//                                    sourceComponent: if (display.followed_at) {
//                                                         mentionsData.description = qsTr(
//                                                                     "follows you now!")
//                                                         return componentMentionsUser
//                                                     } else {
//                                                         return componentMentionsTweet
//                                                     }
//                                }
//                            }

//                            VerticalScrollDecorator {
//                            }
//                        }

//                        Column {
//                            anchors {
//                                fill: parent
//                            }

//                            id: mentionsUpdateInProgressColumn
//                            Behavior on opacity {
//                                NumberAnimation {
//                                }
//                            }
//                            opacity: notificationsColumn.updateInProgress ? 1 : 0
//                            visible: notificationsColumn.updateInProgress ? true : false
//                        }
                    }

                    Item {
                        id: newsColumn
                        width: viewsSlideshow.width
                        height: viewsSlideshow.height


                        //                        Loader {
                        //                            id: profileLoader
                        //                            active: false
                        //                            width: parent.width
                        //                            height: parent.height
                        //                            sourceComponent: profileComponent
                        //                        }
                        SilicaListView {
                            anchors {
                                fill: parent
                            }
                            id: profileListView

                            model: ListModel {
                                ListElement {
                                    fruit: "jackfruit"
                                }
                                ListElement {
                                    fruit: "orange"
                                }
                                ListElement {
                                    fruit: "lemon"
                                }
                                ListElement {
                                    fruit: "lychee"
                                }
                                ListElement {
                                    fruit: "apricots"
                                }
                                ListElement {
                                    fruit: "apricots"
                                }
                                ListElement {
                                    fruit: "apricots"
                                }
                                ListElement {
                                    fruit: "apricots"
                                }
                                ListElement {
                                    fruit: "apricots"
                                }
                                ListElement {
                                    fruit: "apricots"
                                }
                                ListElement {
                                    fruit: "apricots"
                                }
                                ListElement {
                                    fruit: "apricots"
                                }
                                ListElement {
                                    fruit: "apricots"
                                }
                                ListElement {
                                    fruit: "apricots"
                                }
                                ListElement {
                                    fruit: "apricots"
                                }
                                ListElement {
                                    fruit: "apricots"
                                }
                                ListElement {
                                    fruit: "apricots"
                                }
                                ListElement {
                                    fruit: "apricots"
                                }
                                ListElement {
                                    fruit: "apricots"
                                }
                                ListElement {
                                    fruit: "apricots"
                                }
                            }
                            delegate: Item {
                                width: ListView.view.width
                                height: Theme.itemSizeSmall

                                Label {
                                    text: fruit
                                }
                            }

                            VerticalScrollDecorator {
                            }
                        }
                    }
                }

                Timer {
                    id: slideshowVisibleTimer
                    property int tabId: 0
                    interval: 50
                    repeat: false
                    onTriggered: {
                        viewsSlideshow.positionViewAtIndex(
                                    tabId, PathView.SnapPosition)
                        viewsSlideshow.opacity = 1
                    }
                    function goToTab(newTabId) {
                        tabId = newTabId
                        start()
                    }
                }

                SlideshowView {
                    id: viewsSlideshow
                    width: parent.width - (overviewPage.isLandscape ? getNavigationRowSize(
                                                                          ) + (2 * Theme.horizontalPageMargin) : 0)
                    height: parent.height
                    itemWidth: width
                    clip: true
                    // interactive: accountModel.getUseSwipeNavigation()
                    model: viewsModel
                    onCurrentIndexChanged: {
                        openTab(currentIndex)
                    }
                    Behavior on opacity {
                        NumberAnimation {
                        }
                    }
                    onOpacityChanged: {
                        if (opacity === 0) {
                            slideshowVisibleTimer.start()
                        }
                    }
                }
            }

            Column {
                id: navigationRow
                width: parent.width
                height: overviewPage.isPortrait ? getNavigationRowSize() : 0
                visible: true // overviewPage.isPortrait
                Column {
                    id: navigationRowSeparatorColumn
                    width: parent.width
                    height: Theme.paddingMedium
                    Separator {
                        id: navigationRowSeparator
                        width: parent.width
                        color: Theme.primaryColor
                        horizontalAlignment: Qt.AlignHCenter
                    }
                }

                Row {
                    y: Theme.paddingSmall
                    width: parent.width
                    Item {
                        id: detailsButtonColumn
                        width: parent.width / 3
                        height: parent.height - Theme.paddingMedium
                        NavigationRowButton {
                            id: detailsButtonPortrait
                            anchors.top: parent.top
                            buttonText: qsTr("Details")
                            iconSource: "image://theme/icon-m-home"

                            function runOnClick() {
                                handleDetailsClicked()
                            }
                        }
                    }
                    Item {
                        id: chartsButtonColumn
                        width: parent.width / 3
                        height: parent.height - navigationRowSeparator.height
                        NavigationRowButton {
                            id: chartsButtonPortrait
                            anchors.top: parent.top
                            buttonText: qsTr("Charts")
                            iconSource: "image://theme/icon-m-note"

                            function runOnClick() {
                                handleChartsClicked()
                            }
                        }
                    }
                    Item {
                        id: newsButtonColumn
                        width: parent.width / 3
                        height: parent.height - navigationRowSeparator.height
                        NavigationRowButton {
                            id: newsButtonPortrait
                            anchors.top: parent.top
                            buttonText: qsTr("News")
                            iconSource: "image://theme/icon-m-next"

                            function runOnClick() {
                                handleNewsClicked()
                            }
                        }
                    }
                }
            }
        }

        Component.onCompleted: {
            openTab(0)
            theStock = stock
        }
    }
}
