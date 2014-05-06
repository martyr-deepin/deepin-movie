import QtQuick 2.1
import QtMultimedia 5.0
import QtQuick.Window 2.1
import QtGraphicalEffects 1.0

Rectangle {
    id: root
    color: "red"
    state: "normal"
    // QT takes care of WORKAREA for you which is thoughtful indeed, but it cause 
    // problems sometime, we should be careful in case that is changes height for 
    // you suddently.
    width: height * windowView.width / windowView.height * widthProportion
    height: windowView.height * heightProportion

    property real widthProportion: 1
    property real heightProportion: 1

    Constants { id: program_constants }

    MenuResponder {}
    ToolTip { id: tooltip }
    ResizeEdge { id: resize_edge }

    OpenFileDialog {
        id: open_file_dialog
        folder: _utils.homeDir

        onAccepted: {
            if (fileUrls.length > 0) {
                for (var i = 0; i < fileUrls.length; i++) {
                    playlist.addItem("local", urlToPlaylistItem(fileUrls[i]))
                }
                movieInfo.movie_file = fileUrls[0]
            }
        }
    }

    OpenFolderDialog {
        id: open_folder_dialog

        folder: _utils.homeDir

        onAccepted: {
            var fileUrls = _utils.getAllFilesInDir(fileUrl)
            for (var i = 0; i < fileUrls.length; i++) {
               playlist.addItem("local", urlToPlaylistItem("file://"+fileUrls[i]))
           }           
        }
    }

    function formatTime(millseconds) {
        if (millseconds < 0) return "00:00:00";
        var secs = Math.floor(millseconds / 1000)
        var hr = Math.floor(secs / 3600);
        var min = Math.floor((secs - (hr * 3600))/60);
        var sec = secs - (hr * 3600) - (min * 60);

        if (hr < 10) {hr = "0" + hr; }
        if (min < 10) {min = "0" + min;}
        if (sec < 10) {sec = "0" + sec;}
        if (!hr) {hr = "00";}
        return hr + ':' + min + ':' + sec;
    }

    function urlToPlaylistItem(url) {
        var pathDict = (url + "").split("/")
        var result = pathDict.slice(pathDict.length - 2, pathDict.length + 1)
        result[result.length - 1] = [result[result.length - 1], url]
        return result
    }

    property bool controlsShowedFlag: true
    function showControls() {
        if (!controlsShowedFlag && !playlist.expanded) {
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

    /* to perform like a newly started program  */
    function reset() {
        movieInfo.movie_file = ""
        player.visible = false
        controlbar.visible = false
    }

    function monitorWindowClose() {
        config.save("Normal", "volume", player.volume)
        database.record_video_position(player.source, player.position)
        database.playlist_local = playlist.getContent("local")
        database.playlist_network = playlist.getContent("network")
    }

    states: [
        State {
            name: "normal"

            PropertyChanges { target: player; width: main_window.width; height: main_window.height }
            PropertyChanges { target: titlebar; width: main_window.width; anchors.top: main_window.top }
            PropertyChanges { target: controlbar; width: main_window.width; anchors.bottom: main_window.bottom}
            PropertyChanges { target: notifybar; anchors.top: root.top; anchors.left: root.left}
        },
        State {
            name: "fullscreen"

            PropertyChanges { target: player; width: root.width; height: root.height }
            PropertyChanges { target: titlebar; width: root.width; anchors.top: root.top }
            PropertyChanges { target: controlbar; width: root.width; anchors.bottom: root.bottom}
            PropertyChanges { target: notifybar; anchors.top: titlebar.bottom; anchors.left: root.left}
        }
    ]

    Timer {
        id: hide_controls_timer
        running: true
        interval: 5000

        onTriggered: {
            hideControls()
        }
    }

    RectangularGlow {
        id: shadow
        anchors.fill: main_window
        glowRadius: program_constants.windowGlowRadius - 5
        spread: 0
        color: Qt.rgba(0, 0, 0, 1)
        cornerRadius: 10
        visible: true
    }

    Rectangle {
        id: main_window
        width: root.width - program_constants.windowGlowRadius * 2 //height * (movieInfo.movie_width / movieInfo.movie_height)
        height: root.height - program_constants.windowGlowRadius * 2
        clip: true
        color: "#1D1D1D"
        radius: program_constants.windowRadius
        anchors.centerIn: parent

        Rectangle {
            id: bg
            color: "#050811"
            radius: main_window.radius
            visible: { return !(player.hasVideo && player.visible) }
            anchors.fill: parent
            Image { anchors.centerIn: parent; source: "image/background.png" }
        }
    }

    Player {
        id: player
        anchors.centerIn: main_window
        source: movieInfo.movie_file

        onStopped: {
            var next = playlist.getNextSource()
            if (next) {
                movieInfo.movie_file = next
            } else {
                root.reset()
            }
        }

        onPositionChanged: {
            subtitleContent = movieInfo.get_subtitle_at(position)
        }
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
        currentPlayingSource: player.source
        anchors.top: main_window.top
        anchors.left: main_window.left

        onNewSourceSelected: movieInfo.movie_file = path
    }

    Notifybar {
        id: notifybar
        anchors.topMargin: 60
        anchors.leftMargin: 30
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
        width: root.width
        percentage: player.position / movieInfo.movie_duration
        visible: { return (player.visible && player.hasVideo) }
        anchors.horizontalCenter: main_window.horizontalCenter

        onTogglePlay: {
            main_controller.togglePlay()
        }

        onPercentageSet: player.seek(movieInfo.movie_duration * percentage)
    }

    Image {
        source: "image/dragbar.png"

        anchors.rightMargin: 5
        anchors.bottomMargin: 5
        anchors.right: main_window.right
        anchors.bottom: main_window.bottom
    }
}