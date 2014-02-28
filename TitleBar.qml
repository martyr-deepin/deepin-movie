import QtQuick 2.1
import QtGraphicalEffects 1.0

DragArea {
    id: titlebar

    height: program_constants.titlebarHeight
    hoverEnabled: true

    property alias tabPages: tabs.children
    
    signal showed ()
    signal hided ()

    function showWithAnimation () {
        showingTitlebarAnimation.start()
    }
    
    function hideWithAnimation () {
        hidingTitlebarAnimation.start()
    }

    Item {
        id: titlebarBackground
        anchors.fill: parent

        LinearGradient {
            id: topPanelBackround
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 60
            start: Qt.point(0, 0)
            end: Qt.point(0, height)
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#FF000000"}
                GradientStop { position: 1.0; color: "#00000000"}
            }
        }

        TopRoundItem {
            target: topPanelBackround
            radius: frame.radius
        }

        Image {
            id: appIcon
            source: "image/logo.png"
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 8
        }

        Item {
            id: tabs

            Item {
                property string name: "视频播放"
                property variant page: playPage
                property int index: 0
            }

            Item {
                property string name: "在线视频"
                property variant page: undefined
                property int index: 1
            }

            Item {
                property string name: "视频搜索"
                property variant page: undefined
                property int index: 2
            }
        }

        Image {
            id: tabEffect
            source: "image/tab_select_effect.png"
            x: tabX
            visible: showTitlebar ? 1 : 0
            Behavior on x {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutQuint
                }
            }
        }

        Row {
            id: tabRow
            spacing: 44
            anchors.left: parent.left
            anchors.leftMargin: appIcon.width + spacing
            height: parent.height
            visible: showTitlebar ? 1 : 0

            Repeater {
                model: tabPages.length
                delegate: TabButton {
                    text: tabPages[index].name
                    tabIndex: index
                    visible: showTitlebar ? 1 : 0

                    onPressed: {
                        tabEffect.x = x + (width - tabEffect.width) / 2 + tabRow.spacing * 2

                        if (index == 0) {
                            pageManager.hide_page()
                            playPage.visible = true
                        } else {
                            selectWebPage = index == 1 ? "movie_store" : "movie_search"

                            pageManager.show_page(selectWebPage, pageFrame.x, pageFrame.y, pageFrame.width, pageFrame.height)
                            playPage.visible = false
                        }

                        if (tabIndex > 0) {
                            if (windowView.width < videoInitWidth) {
                                windowView.width = videoInitWidth
                            }

                            if (windowView.height < videoInitHeight) {
                                windowView.height = videoInitHeight
                            }
                        }
                    }
                }
            }
        }

        Row {
            anchors {right: parent.right}
            id: windowButtonArea

            ImageButton {
                id: minButton
                imageName: "image/window_min"
                onClicked: {
                    windowView.doMinimized()
                }
                visible: showTitlebar ? 1 : 0
            }

            ImageButton {
                id: maxButton
                imageName: "image/window_max"
                onClicked: {toggleMaxWindow()}
                visible: showTitlebar ? 1 : 0
            }

            ImageButton {
                id: closeButton
                imageName: "image/window_close"
                onClicked: {windowView.close()}
                visible: showTitlebar ? 1 : 0
            }
        }
    }

    PropertyAnimation {
        id: showingTitlebarAnimation
        
        target: titlebar
        property: "height"
        to: program_constants.titlebarHeight
        duration: 1000
        easing.type: Easing.OutQuint
        
        onStopped: {
            titlebar.showed()
        }
    }
    
    PropertyAnimation {
        id: hidingTitlebarAnimation
        
        target: titlebar
        property: "height"
        to: 0
        duration: 1000
        easing.type: Easing.OutQuint
        
        onStopped: {
            titlebar.hided()
        }
    }    
}