import QtQuick 2.1
import QtMultimedia 5.0
import QtGraphicalEffects 1.0
import QtQuick.Window 2.1

Rectangle {
    id: root
    state: "normal"
    color: "transparent"
    radius: main_window.radius
    // QT takes care of WORKAREA for you which is thoughtful indeed, but it cause
    // problems sometime, we should be careful in case that it changes height for
    // you suddenly.
    x: (windowView.width - width) / 2
    width: height * widthHeightScale
    height: windowView.height
    
    property var windowLastState: ""

    onHeightChanged: {
        if (state != "fullscreen") {
            if (width > primaryRect.width) {
                windowView.setHeight((primaryRect.width) / widthHeightScale)
                windowView.setWidth(primaryRect.width)
            } else {
                windowView.setWidth(height * widthHeightScale)
            }
        }
        windowView.moveToCenter()
    }

    property real widthHeightScale: movieInfo.movie_width / movieInfo.movie_height

    property rect primaryRect: {
        return Qt.rect(0, 0, Screen.desktopAvailableWidth, Screen.desktopAvailableHeight)
    }

    Constants { id: program_constants }

    ToolTip { id: tooltip }

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

    PreferenceWindow {
        id: preference_window
        x: windowView.x + (windowView.width - width) / 2
        y: windowView.y + (windowView.height - height) / 2
        width: 800
        height: 500
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
        /* result[result.length - 1] = [result[result.length - 1], url] */
        return [[result[result.length - 1].toString(), url.toString(), ""]]
    }

    function showControls() {
        titlebar.show()
        controlbar.show()
        hide_controls_timer.restart()
    }

    function hideControls() {
        titlebar.hide()
        controlbar.hide()
        hide_controls_timer.stop()
    }

    // Utils functions
    function inRectCheck(point, rect) {
        return rect.x <= point.x && point.x <= rect.x + rect.width &&
        rect.y <= point.y && point.y <= rect.y + rect.height
    }

    function mouseInControlsArea() {
        if (main_controller.mouseX == 0 && main_controller.mouseY == 0) return false//mouse is not in window area

        return inRectCheck(Qt.point(main_controller.mouseX, main_controller.mouseY),
                           Qt.rect(0, 0, main_window.width, titlebar.height)) || inRectCheck(
            Qt.point(main_controller.mouseX, main_controller.mouseY),
            Qt.rect(0, main_window.height - controlbar.height, main_window.width, controlbar.height))
    }

    /* to perform like a newly started program  */
    function reset() {
        root.state = "normal"
        movieInfo.movie_file = ""
        main_controller.stop()
        controlbar.reset()
        showControls()
    }

    function monitorWindowState(state) {
        time_indicator.visible = (state == Qt.WindowFullScreen && 
                                  player.playbackState == MediaPlayer.PlayingState)
        if (windowLastState != state) {
            if (state == Qt.WindowMinimized) {
                main_controller.pause()
            } else {
                main_controller.play()
            }
            windowLastState = state
        }
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

            PropertyChanges { target: root; width: height * widthHeightScale; height: windowView.height }
            PropertyChanges { target: main_window; width: root.width - program_constants.windowGlowRadius * 2;
                              height: root.height - program_constants.windowGlowRadius * 2; }
            PropertyChanges { target: titlebar; width: main_window.width; anchors.top: main_window.top }
            PropertyChanges { target: controlbar; width: main_window.width; anchors.bottom: main_window.bottom}
            PropertyChanges { target: notifybar; anchors.top: root.top; anchors.left: root.left}
            PropertyChanges { target: playlist; height: main_window.height; anchors.right: main_window.right }
        },
        State {
            name: "fullscreen"

            PropertyChanges { target: root; width: windowView.width; height: windowView.height }
            PropertyChanges { target: main_window; width: root.width; height: root.height }
            PropertyChanges { target: titlebar; width: root.width; anchors.top: root.top }
            PropertyChanges { target: controlbar; width: root.width; anchors.bottom: root.bottom}
            PropertyChanges { target: notifybar; anchors.top: titlebar.bottom; anchors.left: root.left}
            PropertyChanges { target: playlist; height: root.height; anchors.right: root.right }
        }
    ]

    Timer {
        id: hide_controls_timer
        running: true
        interval: 3000

        onTriggered: {
            if (!mouseInControlsArea()) {
                hideControls()
            } else {
                hide_controls_timer.restart()
            }
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
        color: "black"
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
        muted: config.fetchBool("Player", "muted")
        volume: controlbar.volume
        anchors.centerIn: main_window
        source: movieInfo.movie_file
        anchors.fill: main_window

        onSourceChanged: {
            if (source != "") playlist.addItem("local", urlToPlaylistItem(source))
        }

        onStopped: {
            if (Math.abs(position - movieInfo.movie_duration) < 1000) {
                var next = playlist.getNextSource()
                if (next) {
                    movieInfo.movie_file = next
                } else {
                    root.reset()
                }
            }
        }

        onPositionChanged: {
            subtitleContent = movieInfo.get_subtitle_at(position)
            controlbar.percentage = position / movieInfo.movie_duration
        }
    }
    
    TimeIndicator {
        id: time_indicator
        visible: false
        percentage: controlbar.percentage
        anchors.top: main_window.top
        anchors.right: main_window.right
        anchors.topMargin: 10
        anchors.rightMargin: 10
    }

    MainController {
        id: main_controller
        window: root
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

        volume: config.fetch("Normal", "volume")
        percentage: player.position / movieInfo.movie_duration
        videoPlaying: player.playbackState == MediaPlayer.PlayingState
        muted: config.fetchBool("Player", "muted")

        anchors.horizontalCenter: main_window.horizontalCenter

        onPreviousButtonClicked: main_controller.playPrevious()
        onNextButtonClicked: main_controller.playNext()

        onTogglePlay: {
            main_controller.togglePlay()
        }

        onChangeVolume: {
            main_controller.setVolume(volume)
        }

        onMutedSet: {
            main_controller.setMute(muted)
        }

        onConfigButtonClicked: {
            // preference_window.show()
        }

        onPlayStopButtonClicked: { root.reset() }
        onOpenFileButtonClicked: { main_controller.openFile() }
        onPlaylistButtonClicked: { hideControls(); playlist.toggleShow() }
        onPercentageSet: player.seek(movieInfo.movie_duration * percentage)
    }

    Playlist {
        id: playlist
        width: 0
        visible: false
        currentPlayingSource: player.source
        anchors.right: main_window.right
        anchors.verticalCenter: parent.verticalCenter

        onNewSourceSelected: movieInfo.movie_file = path
        onShowingAnimationWillStart: { player.shouldShowNotify=false; player.pause() }
        onShowingAnimationDone: { player.shouldShowNotify=true; player.play() }
        onHidingAnimationWillStart: { player.shouldShowNotify=false; player.pause() }
        onHidingAnimationDone: { player.shouldShowNotify=true; player.play() }

        onModeButtonClicked: _menu_controller.show_mode_menu()
        onAddButtonClicked: main_controller.openFile()
        onClearButtonClicked: playlist.clear()
    }

    Component.onCompleted: showControls()
}