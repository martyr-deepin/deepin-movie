import QtQuick 2.1
import QtMultimedia 5.0
import QtQuick.Window 2.1

Item {
    id: root
    state: "normal"
    width: movieInfo.movie_width * widthProportion
    height: movieInfo.movie_height * heightProportion
    
    property real widthProportion: 1
    property real heightProportion: 1

    onWidthChanged: windowView.width = width
    onHeightChanged: windowView.height = height
    
    MenuResponder {}
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
    
    function urlToPlaylistItem(url) {
        var pathDict = (url + "").split("/")
        return pathDict.slice(pathDict.length - 2, pathDict.length + 1)
    }

    property bool controlsShowedFlag: true
    function showControls() {
        if (!controlsShowedFlag) {
            titlebar.show()
            controlbar.show()
            hide_controls_timer.restart()
            controlsShowedFlag = true
        }
    }

    function hideControls() {
        if (controlsShowedFlag) {
            titlebar.hide()
            controlbar.hide()
            hide_controls_timer.stop()
            controlsShowedFlag = false
        }
    }

    function monitorWindowClose() {
        print("monitorWindowClose")
        database.record_video_position(player.source, player.position)
        config.save("Normal", "volume", player.volume)
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

    Timer {
        id: hide_controls_timer
        running: true
        interval: 5000

        onTriggered: {
            hideControls()
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
        
        onSourceChanged: {      /* FixMe: this signal is fired twice. */
            seek(database.fetch_video_position(source))
            playlist.addItem("local", urlToPlaylistItem(source))
        }

        onPlaybackStateChanged: {
            if (playbackState == MediaPlayer.PausedState) {
                pause_notify.notify()
            }
        }

        onPositionChanged: {
            var newPercentage = position / movieInfo.movie_duration
            
            if ((newPercentage - controlbar.percentage) * movieInfo.movie_duration > 5000) {
                controlbar.percentage = position / movieInfo.movie_duration
            }
        }

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
        
        onVideoSelected: movieInfo.movie_file = path
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