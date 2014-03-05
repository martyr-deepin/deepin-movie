import QtQuick 2.1
import QtMultimedia 5.0
import QtQuick.Window 2.1

Item {
    id: root
    width: 950
    height: 642

    ResizeEdge { id: resize_edge }
    Constants { id: program_constants }

    Connections {
        target: windowView

        onWidthChanged: {
            if (!player.visible) {
                pageManager.show_page(titlebar.currentPage, online.x, online.y, online.width, online.height)
            }
        }
        onHeightChanged: {
            if (!player.visible) {
                pageManager.show_page(titlebar.currentPage, online.x, online.y, online.width, online.height)
            }
        }
    }
    
    Rectangle {
        width: main_window.width + 2
        height: main_window.height + 2
        radius: main_window.radius
        border.color: Qt.rgba(100, 100, 100, 0.3)
        border.width: 1
        
        anchors.centerIn: parent
    }

    Rectangle {
        id: main_window
        width: root.width - 6
        height: root.height - 6
        clip: true
        color: "#1D1D1D"
        radius: program_constants.windowRadius
        anchors.centerIn: parent

        Rectangle {
            id: bg
            color: "#050811"
            visible: { 
                return !player.hasVideo &&
                player.visible
            }
            anchors.fill: parent
            Image { anchors.centerIn: parent; source: "image/background.png" }
        }

        PlaceHolder {
            id: online;
            width: parent.width
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.topMargin: program_constants.titlebarHeight
        }
        
        Player1 {
            id: player
            source: "/home/hualet/Videos/1.mp4"
            anchors.fill: parent

            onPlaybackStateChanged: {
                if (playbackState == MediaPlayer.PausedState) {
                    pause_notify.notify()
                }
            }
        }

        PauseNotify { id: pause_notify; visible: false; anchors.centerIn: parent }
    }

    MainController {
        window: root
    }
    
    Playlist { 
        id: playlist 
        width: 0
        height: main_window.height
        visible: false
        anchors.top: main_window.top
        anchors.left: main_window.left
    }

    TitleBar {
        id: titlebar;
        width: main_window.width
        anchors.top: main_window.top        
        anchors.horizontalCenter: main_window.horizontalCenter
    }

    ControlBar {
        id: controlbar

        visible: { return player.visible && player.hasVideo}
        width: main_window.width
        anchors.bottom: main_window.bottom
        anchors.horizontalCenter: main_window.horizontalCenter
    }
}