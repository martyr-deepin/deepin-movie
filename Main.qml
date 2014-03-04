import QtQuick 2.1
import QtGraphicalEffects 1.0
import QtWebKit 3.0
import QtMultimedia 5.0
import QtQuick.LocalStorage 2.0

Item {
    id: window
    
    property int videoInitWidth: 950
    property int videoInitHeight: (videoInitWidth - padding * 2) * movieInfo.movie_height / movieInfo.movie_width + padding * 2
    property int videoMinWidth: 470
    property int videoMinHeight: (videoMinWidth - padding * 2) * movieInfo.movie_height / movieInfo.movie_width + padding * 2

    property int frameRadius: 3
    property int shadowRadius: 10
    property int padding: frameRadius + shadowRadius

    /* default property alias tabPages: tabs.children */
    property alias playPage: playPage
    property alias pageFrame: pageFrame
    /* property alias tabEffect: tabEffect */
    property alias player: player
    property alias titlebar: titlebar
    property alias frame: frame
    property int windowLastState: 0
    property int tabX: 0

    property bool inTitlebar: false
    property bool showTitlebar: true
    property bool inInteractiveArea: false

    property string selectWebPage: ""

    signal exitMouseArea

    Constants { id: program_constants }

    Timer {
        id: outWindowTimer
        interval: 50
        repeat: false
        onTriggered: {
            if (!inInteractiveArea) {
                player.hidingTimer.interval = 800
                player.hidingTimer.restart()
            }
        }
    }

    onExitMouseArea: {
        outWindowTimer.restart()
    }

    Connections {
        target: windowView

        onWidthChanged: {
            if (!playPage.visible) {
                pageManager.show_page(selectWebPage, pageFrame.x, pageFrame.y, pageFrame.width, pageFrame.height)
            }
        }
        onHeightChanged: {
            if (!playPage.visible) {
                pageManager.show_page(selectWebPage, pageFrame.x, pageFrame.y, pageFrame.width, pageFrame.height)
            }
        }
    }

    function monitorWindowClose() {
        database.record_video_position(player.source, player.position)
        config.save("Normal", "volume", player.volume)
    }

    function monitorWindowState(state) {
        if (windowLastState != state) {
            if (state == Qt.WindowMinimized) {
                player.tryPauseVideo()
            } else {
                player.tryPlayVideo()
            }
            windowLastState = state
        }
    }

    function toggleMaxWindow() {
        windowView.getState() == Qt.WindowMaximized ? maxButton.imageName = "image/window_max" : maxButton.imageName = "image/window_unmax"
        windowView.getState() == Qt.WindowMaximized ? shadow.visible = true : shadow.visible = false
        windowView.getState() == Qt.WindowMaximized ? frame.border.width = (shadowRadius + frameRadius) * 2 : frame.border.width = 0
        windowView.getState() == Qt.WindowMaximized ? frame.radius = frameRadius : frame.radius = 0
        windowView.getState() == Qt.WindowMaximized ? frameBackground.radius = frameRadius : frameBackground.radius = 0
        windowView.getState() == Qt.WindowMaximized ? frameBorder.visible = true : frameBorder.visible = false
        windowView.getState() == Qt.WindowMaximized ? windowView.showNormal() : windowView.showMaximized()
    }

    function toggleFullWindow() {
        windowView.getState() == Qt.WindowFullScreen ? shadow.visible = true : shadow.visible = false
        windowView.getState() == Qt.WindowFullScreen ? frame.border.width = (shadowRadius + frameRadius) * 2 : frame.border.width = 0
        windowView.getState() == Qt.WindowFullScreen ? frame.radius = frameRadius : frame.radius = 0
        windowView.getState() == Qt.WindowFullScreen ? frameBackground.radius = frameRadius : frameBackground.radius = 0
        windowView.getState() == Qt.WindowFullScreen ? frameBorder.visible = true : frameBorder.visible = false
        windowView.getState() == Qt.WindowFullScreen ? windowView.showNormal() : windowView.showFullScreen()

        if (windowView.getState() == Qt.WindowFullScreen) {
            titlebar.hideWithAnimation()
            player.hidingBottomPanelAnimation.restart()
        }
    }

    function initSize() {
        windowView.width = videoInitWidth
        windowView.height = videoInitHeight

        windowView.setMinSize(videoMinWidth, videoMinHeight)
    }

    Component.onCompleted: {
        initSize()
    }
    
    RectangularGlow {
        id: shadow
        anchors.fill: frame
        glowRadius: shadowRadius
        spread: 0.2
        color: Qt.rgba(0, 0, 0, 0.3)
        cornerRadius: frame.radius + shadowRadius
        visible: true
    }

    ResizeFrame {
        id: resizeFrame
        window: windowView
        framePadding: padding
        proportionalResize: true
        proportionalWidth: movieInfo.movie_width
        proportionalHeight: movieInfo.movie_height
    }

    ResizeArea {
        id: resizeArea
        window: windowView
        frame: frame
    }

    Rectangle {
        id: frame
        opacity: 1                /* frame transparent */
        color: Qt.rgba(0, 0, 0, 0)
        anchors.centerIn: parent
        radius: frameRadius
        border.width: (shadowRadius + frameRadius) * 2
        border.color: Qt.rgba(0, 0, 0, 0)
        width: window.width - border.width
        height: window.height - border.width

        Rectangle {
            id: frameBackground
            color: "#1D1D1D"
            anchors.fill: parent
            radius: frameRadius
        }

        RoundItem {
            target: frameBackground
            radius: frame.radius
        }
    }

    Item {
        id: pageFrame
        anchors.top: titlebar.bottom
        anchors.bottom: frame.bottom
        anchors.left: titlebar.left
        anchors.right: titlebar.right
    }

    Rectangle {
        id: playPage
        anchors.top: titlebar.top
        anchors.bottom: pageFrame.bottom
        anchors.left: pageFrame.left
        anchors.right: pageFrame.right
        color: Qt.rgba(0, 0, 0, 0)

        Player {
            id: player
            source: movieInfo.movie_file
            videoPreview.video.source: player.source
            anchors.fill: parent

            Component.onCompleted: {
                videoPreview.video.pause()
            }

            Connections {
                target: _menu_controller
                onClockwiseRotate: {
                    fake.rotation += 90
                }
                onAntiClosewiseRotate: {
                    fake.rotation -= 90
                }
            }

            onBottomPanelShow: {
                titlebar.showWithAnimation()
            }

            onBottomPanelHide: {
                if (playPage.visible) {
                    if (!titlebar.pressed && !inTitlebar) {
                        titlebar.hideWithAnimation()
                    }
                }
            }

            onShowCursor: {
                player.videoArea.cursorShape = Qt.ArrowCursor
            }

            onHideCursor: {
                if (!titlebar.pressed && !inTitlebar) {
                    player.videoArea.cursorShape = Qt.BlankCursor
                }
            }

            onToggleFullscreen: {
                toggleFullWindow()
            }

            onVisibleChanged: {
                if (!player.visible) {
                    player.tryPauseVideo()
                } else {
                    player.tryPlayVideo()
                }
            }
        }

        RoundItem {
            target: player
            radius: frame.radius
        }
    }

    // *** This item is intend to be the main controller of this program ***
    // Sandwiched between the video player layer and the controls layer,
    // it will response to user interaction(like mouse click and key control)
    // and serve as the logic controller of the whole program.
    /* Item { */
    /*     id: main_controller */
    /*     anchors.fill: frame */

    /*     MouseArea { */
    /*         acceptedButtons: Qt.LeftButton | Qt.RightButton */
    /*         anchors.fill: parent */
    /*         onClicked: { */
    /*             if (mouse.button == Qt.RightButton) { */
    /*                 _menu_controller.show_menu() */
    /*             } */
    /*         } */
    /*     } */
    /* } */

    TitleBar {
        id: titlebar
        window: windowView
        anchors.top: frame.top
        anchors.left: frame.left
        anchors.right: frame.right

        onShowed: { showTitlebar = true }
        onHided: { showTitlebar = false }
        
        onPositionChanged: {
            inTitlebar = true
        }

        onExited: {
            inTitlebar = false
        }

        onDoubleClicked: {
            toggleMaxWindow()
        }
    }

    Rectangle {
        id: frameBorder
        anchors.fill: frame
        color: Qt.rgba(0, 0, 0, 0)
        border.color: Qt.rgba(100, 100, 100, 0.3)
        border.width: 1
        smooth: true
        radius: frameRadius
    }
}
