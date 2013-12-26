import QtQuick 2.1
import QtGraphicalEffects 1.0
import QtWebKit 3.0
import QtMultimedia 5.0
import QtQuick.LocalStorage 2.0

Item {
    id: window
    
    property int videoInitWidth: 950
    property int videoInitHeight: (videoInitWidth - padding * 2) * movieInfo.get_movie_height() / movieInfo.get_movie_width() + padding * 2
    property int videoMinWidth: 470
    property int videoMinHeight: (videoMinWidth - padding * 2) * movieInfo.get_movie_height() / movieInfo.get_movie_width() + padding * 2
    
    property int titlebarHeight: 45
    property int frameRadius: 3
    property int shadowRadius: 10
    property int padding: frameRadius + shadowRadius
    
    default property alias tabPages: tabs.children
    property alias playPage: playPage
    property alias pageFrame: pageFrame
    property alias tabEffect: tabEffect
    property alias player: player
    property alias titlebar: titlebar
    property alias frame: frame
    property int windowLastState: 0
    property int tabX: 0
    
    property bool inTitlebar: false
    property bool showTitlebar: true
    property bool inInteractiveArea: false
    
    signal exitMouseArea
    
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
            hidingTitlebarAnimation.restart()
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
        proportionalWidth: movieInfo.get_movie_width()
        proportionalHeight: movieInfo.get_movie_height()
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
    
    Rectangle {
        id: pageFrame
        anchors.top: titlebar.bottom
        anchors.bottom: frame.bottom
        anchors.left: titlebar.left
        anchors.right: titlebar.right
        color: Qt.rgba(0, 0, 0, 0)
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
            width: parent.width
            height: parent.height
            source: movieInfo.get_movie_file()
            videoPreview.video.source: player.source
            
            Component.onCompleted: {
                videoPreview.video.pause()
            }
            
            onBottomPanelShow: {
                showingTitlebarAnimation.restart()
            }

            onBottomPanelHide: {
                if (playPage.visible) {
                    if (!titlebar.pressed && !inTitlebar) {
                        hidingTitlebarAnimation.restart()
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
    
    DragArea {
        id: titlebar
        window: windowView
        anchors.top: frame.top
        anchors.left: frame.left
        anchors.right: frame.right
        width: frame.width
        height: titlebarHeight
        hoverEnabled: true
        
        onPositionChanged: {
            inTitlebar = true
        }
        
        onExited: {
            inTitlebar = false
        }
        
        onDoubleClicked: {
            toggleMaxWindow()
        }
        
        Rectangle {
            id: titlebarBackground
            anchors.fill: parent
            color: "#00000000"
        
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
                visible: playPage.visible && showTitlebar
            }
            
            TopRoundItem {
                target: topPanelBackround
                radius: frame.radius
                visible: playPage.visible && showTitlebar
            }
    
            Image {
                id: appIcon
                source: "image/logo.png"
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 8
                visible: showTitlebar ? 1 : 0
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
                            } else if (index == 1) {
                                pageManager.show_page("movie_store", pageFrame.width, pageFrame.height)
                                playPage.visible = false
                            } else if (index == 2) {
                                pageManager.show_page("movie_search", pageFrame.width, pageFrame.height)
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
        
        InteractiveItem {
            targetItem: parent
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
    
    ParallelAnimation{
        id: showingTitlebarAnimation
        alwaysRunToEnd: true
        
        PropertyAnimation {
            target: titlebar
            property: "height"
            to: titlebarHeight
            duration: 100
            easing.type: Easing.OutQuint
        }
        
        onRunningChanged: {
            if (!showingTitlebarAnimation.running) {
                showTitlebar = true
            }
        }
    }    

    ParallelAnimation{
        id: hidingTitlebarAnimation
        alwaysRunToEnd: true
        
        PropertyAnimation {
            target: titlebar
            property: "height"
            to: 0
            duration: 100
            easing.type: Easing.OutQuint
        }
        
        onRunningChanged: {
            if (!showingTitlebarAnimation.running) {
                showTitlebar = false
            }
        }
    }    
}

