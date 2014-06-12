import QtQuick 2.1
import QtGraphicalEffects 1.0
import Deepin.Widgets 1.0

DragableArea {
    id: titlebar
    state: "normal"
    height: program_constants.titlebarHeight

    property bool windowNormalState: true
    property alias title: title_text.text

    signal menuButtonClicked ()
    signal minButtonClicked ()
    signal maxButtonClicked ()
    signal closeButtonClicked ()

    signal quickNormalSize()
    signal quickOneHalfSize()
    signal quickFullscreen()
    signal quickToggleTop()

    states: [
        State {
            name: "normal"
            PropertyChanges {
                target: appIcon
                visible: true
            }
            PropertyChanges {
                target: btn
                visible: true
            }
            PropertyChanges {
                target: title_text
                visibleSwitch: true
            }
            PropertyChanges {
                target: quick_bar
                visible: false
            }
        },
        State {
            name: "minimal"
            PropertyChanges {
                target: appIcon
                visible: false
            }
            PropertyChanges {
                target: btn
                visible: false
            }
            PropertyChanges {
                target: title_text
                visibleSwitch: false
            }
            PropertyChanges {
                target: quick_bar
                visible: true
            }
        }
    ]

    function show() {
        visible = true
    }

    function hide() {
        visible = false
    }

    onDoubleClicked: titlebar.maxButtonClicked()

    Item {
        id: titlebarBackground
        layer.enabled: true
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

        // TopRoundItem {
        //     target: topPanelBackround
        //     radius: program_constants.windowRadius
        // }

        Image {
            id: appIcon
            source: "image/logo.png"
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.top: parent.top
            anchors.topMargin: 5
        }

        TabButton {
            id: btn
            text: "DMovie"

            anchors.left: appIcon.right
            anchors.leftMargin: 3
            anchors.verticalCenter: appIcon.verticalCenter
            anchors.verticalCenterOffset: 1
        }

        Text {
            id: title_text
            width: Math.min(titlebar.width - (btn.x + btn.width + 20) * 2, implicitWidth)
            font.pixelSize: 13
            color: Qt.rgba(1, 1, 1, 0.6)
            elide: Text.ElideRight
            visible: visibleSwitch && width > implicitWidth / 2

            property bool visibleSwitch: true
            
            anchors.verticalCenter: windowButtonArea.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Row {
            id: quick_bar
            spacing: 5
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.top: parent.top
            anchors.topMargin: 10

            DImageButton {
                normal_image: "image/quick_1_1_normal.svg"
                hover_image: "image/quick_1_1_hover.svg"
                press_image: "image/quick_1_1_hover.svg"

                anchors.verticalCenter: parent.verticalCenter

                onClicked: titlebar.quickNormalSize()
            }
            DImageButton {
                normal_image: "image/quick_1_5_normal.svg"
                hover_image: "image/quick_1_5_hover.svg"
                press_image: "image/quick_1_5_hover.svg"

                anchors.verticalCenter: parent.verticalCenter

                onClicked: titlebar.quickOneHalfSize()
            }
            DImageButton {
                normal_image: "image/quick_fullscreen_normal.svg"
                hover_image: "image/quick_fullscreen_hover.svg"
                press_image: "image/quick_fullscreen_hover.svg"

                anchors.verticalCenter: parent.verticalCenter

                onClicked: titlebar.quickFullscreen()
            }
            DImageButton {
                normal_image: checkFlag ? "image/quick_untop_normal.svg" : "image/quick_top_normal.svg"
                hover_image: checkFlag ? "image/quick_untop_hover.svg" : "image/quick_top_hover.svg"
                press_image: checkFlag ? "image/quick_top_hover.svg" : "image/quick_top_hover.svg"

                property bool checkFlag: false

                anchors.verticalCenter: parent.verticalCenter

                onClicked: {
                    checkFlag = !checkFlag
                    titlebar.quickToggleTop()
                }
            }
        }

        Row {
            id: windowButtonArea
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 5
            anchors.rightMargin: 5

            ImageButton {
                id: menuButton
                imageName: "image/window_menu"
                onClicked: { titlebar.menuButtonClicked() }
            }

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