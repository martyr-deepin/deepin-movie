import QtQuick 2.1
import QtGraphicalEffects 1.0
import Deepin.Widgets 1.0

DragableArea {
    id: titlebar
    state: "normal"
    height: program_constants.titlebarHeight

    property bool windowNormalState: true
    property alias windowFullscreenState: quick_fullscreen_button.checkFlag
    property alias windowStaysOnTop: quick_stays_on_top.checkFlag
    property alias title: title_text.text
    property bool titleVisibleSwitch: titlebar.width > program_constants.simplifiedModeTriggerWidth
    property QtObject tooltipItem

    signal menuButtonClicked ()
    signal minButtonClicked ()
    signal maxButtonClicked ()
    signal closeButtonClicked ()

    signal quickNormalSize()
    signal quickOneHalfSize()
    signal quickToggleFullscreen()
    signal quickToggleTop()

    states: [
        State {
            name: "normal"
            PropertyChanges {
                target: appIcon
                visible: true && !visibleForPlaylist
            }
            PropertyChanges {
                target: btn
                visible: true && !visibleForPlaylist
            }
            PropertyChanges {
                target: title_text
                visible: titlebar.titleVisibleSwitch && !visibleForPlaylist
            }
            PropertyChanges {
                target: quick_bar
                visible: false && !visibleForPlaylist
            }
        },
        State {
            name: "minimal"
            PropertyChanges {
                target: appIcon
                visible: false && !visibleForPlaylist
            }
            PropertyChanges {
                target: btn
                visible: false && !visibleForPlaylist
            }
            PropertyChanges {
                target: title_text
                visible: false && !visibleForPlaylist
            }
            PropertyChanges {
                target: quick_bar
                visible: true && !visibleForPlaylist
            }
        }
    ]

    function show() {
        visible = true
    }

    function hide() {
        visible = false
    }

    Timer {
        id: show_for_playlist_timer
        interval: 200
        onTriggered: {
            topPanelBackround.visible = false
            visibleForPlaylist = true
            show()
        }
    }

    property bool visibleForPlaylist: false
    function showForPlaylist() { 
        show_for_playlist_timer.restart() 
    }
    function hideForPlaylist() { 
        show_for_playlist_timer.stop()

        if (visibleForPlaylist) {
            topPanelBackround.visible = true
            visibleForPlaylist = false
            hide()
        }
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

            ImageButton {
                tooltip: dsTr("Shown in a proportion of 1:1")
                tooltipItem: titlebar.tooltipItem

                normal_image: "image/quick_1_1_normal.svg"
                hover_image: "image/quick_1_1_hover.svg"
                press_image: "image/quick_1_1_hover.svg"

                anchors.verticalCenter: parent.verticalCenter

                onClicked: titlebar.quickNormalSize()
            }
            ImageButton {
                tooltip: dsTr("Shown in 1.5 times")
                tooltipItem: titlebar.tooltipItem

                normal_image: "image/quick_1_5_normal.svg"
                hover_image: "image/quick_1_5_hover.svg"
                press_image: "image/quick_1_5_hover.svg"

                anchors.verticalCenter: parent.verticalCenter

                onClicked: titlebar.quickOneHalfSize()
            }
            ImageButton {
                id: quick_fullscreen_button
                tooltip: checkFlag ? dsTr("Return to mini mode") : dsTr("Shown in fullscreen")
                tooltipItem: titlebar.tooltipItem

                normal_image: checkFlag ? "image/quick_quit_fullscreen_normal.svg" : "image/quick_fullscreen_normal.svg"
                hover_image: checkFlag ? "image/quick_quit_fullscreen_hover.svg" : "image/quick_fullscreen_hover.svg"
                press_image: checkFlag ? "image/quick_quit_fullscreen_hover.svg" : "image/quick_fullscreen_hover.svg"

                property bool checkFlag: false

                anchors.verticalCenter: parent.verticalCenter

                onClicked: titlebar.quickToggleFullscreen()
            }
            ImageButton {
                id: quick_stays_on_top
                tooltip: checkFlag ? dsTr("Cancel \"On Top\"") : dsTr("On Top")
                tooltipItem: titlebar.tooltipItem

                normal_image: checkFlag ? "image/quick_untop_normal.svg" : "image/quick_top_normal.svg"
                hover_image: checkFlag ? "image/quick_untop_hover.svg" : "image/quick_top_hover.svg"
                press_image: checkFlag ? "image/quick_untop_hover.svg" : "image/quick_top_hover.svg"

                property bool checkFlag: false
                anchors.verticalCenter: parent.verticalCenter

                onClicked: { titlebar.quickToggleTop() }
            }
        }

        // the -1 operation is all because that there's only 28x24 pics while 
        // they demanding the 27 spacing.
        Row {
            id: windowButtonArea
            spacing: -1
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 5
            anchors.rightMargin: 5 - 1

            ImageButton {
                id: menuButton
                normal_image: "image/window_menu_normal.png"
                hover_image: "image/window_menu_hover.png"
                press_image: "image/window_menu_press.png"
                onClicked: { titlebar.menuButtonClicked() }
            }

            ImageButton {
                id: minButton
                normal_image: "image/window_min_normal.png"
                hover_image: "image/window_min_hover.png"
                press_image: "image/window_min_press.png"
                onClicked: { titlebar.minButtonClicked() }
            }

            ImageButton {
                id: maxButton
                normal_image: windowNormalState ? "image/window_max_normal.png" : "image/window_unmax_normal.png"
                hover_image: windowNormalState ? "image/window_max_hover.png" : "image/window_unmax_hover.png"
                press_image: windowNormalState ? "image/window_max_press.png" : "image/window_unmax_press.png"
                onClicked: { titlebar.maxButtonClicked() }
            }

            ImageButton {
                id: closeButton
                normal_image: "image/window_close_normal.png"
                hover_image: "image/window_close_hover.png"
                press_image: "image/window_close_press.png"
                onClicked: { titlebar.closeButtonClicked() }
            }
        }
    }
}