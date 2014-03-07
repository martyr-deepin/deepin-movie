import QtQuick 2.1
import QtMultimedia 5.0
import QtQuick.Window 2.1

Item {
    id: root
    state: "normal"
    width: movieInfo.movie_width
    height: movieInfo.movie_height

    onWidthChanged: windowView.width = width
    onHeightChanged: windowView.height = height

    ResizeEdge { id: resize_edge }
    Constants { id: program_constants }

    function formatTime(millseconds) {
        if (millseconds < 0) return "00:00:00";
        var secs = Math.floor(millseconds / 1000)
        var hr = Math.floor(secs / 3600);
        var min = Math.floor((secs - (hr * 3600))/60);
        var sec = secs - (hr * 3600) - (min * 60);

        if (hr < 10) {hr = "0" + hr; }
        if (min < 10) {min = "0" + min;}
        if (sec < 10) {sec = "0" + sec;}
        if (hr) {hr = "00";}
        return hr + ':' + min + ':' + sec;
    }
    
    states: [
        State {
            name: "normal"
            
            PropertyChanges { target: player; anchors.fill: main_window }
            PropertyChanges { target: titlebar; width: main_window.width; anchors.top: main_window.top }
            PropertyChanges { target: controlbar; width: main_window.width; anchors.bottom: main_window.bottom}
            PropertyChanges { target: notifybar; anchors.top: titlebar.bottom; anchors.left: main_window.left}
        },
        State {
            name: "fullscreen"
            
            PropertyChanges { target: player; anchors.fill: root }
            PropertyChanges { target: titlebar; width: root.width; anchors.top: root.top }
            PropertyChanges { target: controlbar; width: root.width; anchors.bottom: root.bottom}
            PropertyChanges { target: notifybar; anchors.top: titlebar.bottom; anchors.left: root.left}
        }        
    ]

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

    Connections {
        target: _menu_controller
        onClockwiseRotate: {
            player.orientation -= 90
        }
        onAntiClosewiseRotate: {
            player.orientation += 90
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
    }

    Player1 {
        id: player
        anchors.fill: parent
        source: movieInfo.movie_file

        property int lastPosition: 0

        onPlaybackStateChanged: {
            if (playbackState == MediaPlayer.PausedState) {
                pause_notify.notify()
            }
        }

        onPositionChanged: controlbar.percentage = position / movieInfo.movie_duration
        
        PauseNotify { id: pause_notify; visible: false; anchors.centerIn: parent }        
    }

    MainController {
        id: main_controller
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
        id: titlebar
        anchors.horizontalCenter: main_window.horizontalCenter
        
        onMinButtonClicked: main_controller.minimize()
        onMaxButtonClicked: main_controller.toggleMaximized()
        onCloseButtonClicked: main_controller.close()
    }

    ControlBar {
        id: controlbar

        position: player.position
        visible: { return player.visible && player.hasVideo }
        anchors.horizontalCenter: main_window.horizontalCenter

        onPercentageChanged: {
            player.seek(percentage * movieInfo.movie_duration)
        }
    }

    Notifybar {
        id: notifybar
        anchors.topMargin: 20
        anchors.leftMargin: 20
    }
}