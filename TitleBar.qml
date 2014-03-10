import QtQuick 2.1
import QtGraphicalEffects 1.0

Item {
    id: titlebar
    height: program_constants.titlebarHeight

    property alias tabPages: tabs.children
    property string currentPage

    signal minButtonClicked ()
    signal maxButtonClicked ()
    signal closeButtonClicked ()

    function show() {
        visible = true
    }

    function hide() {
        visible = false
    }

    Item {
        id: tabs

        Item {
            property string name: "视频播放"
            property variant page: undefined
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

    Item {
        id: titlebarBackground
        anchors.fill: parent

        LinearGradient {
            id: topPanelBackround
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: parent.height
            start: Qt.point(0, 0)
            end: Qt.point(0, height)
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#FF000000"}
                GradientStop { position: 1.0; color: "#00000000"}
            }
        }

        TopRoundItem {
            target: topPanelBackround
            radius: program_constants.windowRadius
        }

        Image {
            id: appIcon
            source: "image/logo.png"
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 8
        }

        Image {
            id: tabEffect
            source: "image/tab_select_effect.png"
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

            Repeater {
                model: tabPages.length
                delegate: TabButton {
                    text: tabPages[index].name
                    tabIndex: index

                    onPressed: {
                        tabEffect.x = x + (width - tabEffect.width) / 2 + tabRow.spacing * 2

                        if (index == 0) {
                            pageManager.hide_page()
                            player.visible = true
                        } else {
                            currentPage = index == 1 ? "movie_store" : "movie_search"

                            pageManager.show_page(currentPage, online.x, online.y, online.width, online.height)
                            player.visible = false
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
                onClicked: { titlebar.minButtonClicked() }
            }

            ImageButton {
                id: maxButton
                imageName: "image/window_max"
                onClicked: { titlebar.maxButtonClicked() }
            }

            ImageButton {
                id: closeButton
                imageName: "image/window_close"
                onClicked: { titlebar.closeButtonClicked() }
            }
        }
    }
}