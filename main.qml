import QtQuick 2.1
import QtMultimedia 5.0
import QtGraphicalEffects 1.0
import QtQuick.Window 2.1
import Deepin.Locale 1.0

Rectangle {
    id: root
    state: "normal"
    color: "transparent"
    radius: main_window.radius
    // QT takes care of WORKAREA for you which is thoughtful indeed, but it cause
    // problems sometime, we should be careful in case that it changes height for
    // you suddenly.
    x: (windowView.width - width) / 2
    width: windowView.width
    height: windowView.height
    layer.enabled: true
    
    property var windowLastState: ""

    property real widthHeightScale: movieInfo.movie_width / movieInfo.movie_height

    property rect primaryRect: {
        return Qt.rect(0, 0, Screen.desktopAvailableWidth, Screen.desktopAvailableHeight)
    }

    Connections {
        target: windowView

        onWidthChanged: { 
            root.width = windowView.width
            database.lastWindowSize = JSON.stringify({ "width":windowView.width, "height":windowView.height }) 
        }
        onHeightChanged: { 
            root.height = windowView.height 
            database.lastWindowSize = JSON.stringify({ "width":windowView.width, "height":windowView.height }) 
        }
    }

    Constants { id: program_constants }

    ToolTip { 
        id: tooltip 

        window: windowView
        screenSize: primaryRect
    }

    OpenFileDialog {
        id: open_file_dialog
        folder: database.lastOpenedPath || _utils.homeDir

        onAccepted: {
            if (fileUrls.length > 0) {
                database.lastOpenedPath = fileUrls[0] // record last opened path

                for (var i = 0; i < fileUrls.length; i++) {
                    var fileUrl = fileUrls[i] + ""
                    main_controller.addPlayListItem(fileUrl.substring(7))
                }
                movieInfo.movie_file = fileUrls[0]
            }
        }
    }

    OpenFolderDialog {
        id: open_folder_dialog

        folder: database.lastOpenedPath || _utils.homeDir

        onAccepted: {
            database.lastOpenedPath = fileUrl // record last opened path

            var fileUrls = _utils.getAllFilesInDir(fileUrl)
            if (fileUrls.length > 0) {
                for (var i = 0; i < fileUrls.length; i++) {
                    main_controller.addPlayListItem(fileUrls[i])
                }                
            }
            movieInfo.movie_file = fileUrls[0]
        }
    }

    PreferenceWindow {
        id: preference_window
        x: windowView.x + (windowView.width - width) / 2
        y: windowView.y + (windowView.height - height) / 2
        width: 560
        height: 480
    }

    InfomationWindow {
        id: info_window
        title: movieInfo.movie_title
        fileType: movieInfo.movie_type
        fileSize: formatSize(movieInfo.movie_size)
        movieResolution: "%1x%2".arg(movieInfo.movie_width).arg(movieInfo.movie_height)
        movieDuration: formatTime(movieInfo.movie_duration)
        filePath: formatFilePath(movieInfo.movie_file)

        onCopyToClipboard: _utils.copyToClipboard(text)
    }

    // translation tools
    property var dssLocale: DLocale {
        domain: "deepin-movie"
    }
    function dsTr(s) {
        return dssLocale.dsTr(s)
    }

    function getSystemFontFamily() {
        var text = Qt.createQmlObject('import QtQuick 2.1; Text {}', root, "");
        return text.font.family
    }

    function initWindowSize() {
        if (config.playerAdjustType == "ADJUST_TYPE_LAST_TIME") {
            var lastSize = database.lastWindowSize
            if(database.lastWindowSize != "") {
                var lastSize = JSON.parse(lastSize)
                windowView.setWidth(lastSize.width)
                windowView.setHeight(lastSize.height)
                return
            }
        }
        windowView.setWidth(windowView.defaultWidth)
        windowView.setHeight(windowView.defaultHeight)
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

    function formatSize(capacity) {
        var teras = capacity / (1024 * 1024 * 1024 * 1024)
        capacity = capacity % (1024 * 1024 * 1024 * 1024)
        var gigas = capacity / (1024 * 1024 * 1024)
        capacity = capacity % (1024 * 1024 * 1024)
        var megas = capacity / (1024 * 1024)
        capacity = capacity % (1024 * 1024)
        var kilos = capacity / 1024

        return Math.floor(teras) ? teras.toFixed(1) + "TB" :
                Math.floor(gigas) ? gigas.toFixed(1) + "GB":
                Math.floor(megas) ? megas.toFixed(1) + "MB" :
                kilos + "KB"
    }

    function formatFilePath(file_path) {
        return file_path.indexOf("file://") != -1 ? file_path.substring(7) : file_path
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

    // To check wether the player is stopped by the app or by the user
    // if it is ther user that stopped the player, we'll not play it automatically.
    property bool videoStoppedByAppFlag: false 
    function monitorWindowState(state) {
        time_indicator.visible = (state == Qt.WindowFullScreen && 
                                  player.playbackState == MediaPlayer.PlayingState)
        if (windowLastState != state) {
            if (config.playerPauseOnMinimised) {
                if (state == Qt.WindowMinimized) {
                    if (player.playbackState == MediaPlayer.PlayingState) {
                        main_controller.pause()
                        videoStoppedByAppFlag = true
                    }
                } else {                    
                    if (videoStoppedByAppFlag == true) {                      
                        main_controller.play()
                        videoStoppedByAppFlag = false
                    }
                }                
            }
            windowLastState = state
        }
    }

    function monitorWindowClose() {
        config.save("Normal", "volume", player.volume)
        database.record_video_position(player.source, player.position)
        database.playlist_local = playlist.getContent()
    }

    states: [
        State {
            name: "normal"

            PropertyChanges { target: root; width: height * widthHeightScale; height: windowView.height }
            PropertyChanges { target: main_window; width: root.width - program_constants.windowGlowRadius * 2;
                              height: root.height - program_constants.windowGlowRadius * 2; }
            PropertyChanges { target: titlebar; width: main_window.width; anchors.top: main_window.top }
            PropertyChanges { target: controlbar; width: main_window.width; anchors.bottom: main_window.bottom}
            PropertyChanges { target: playlist; height: main_window.height; anchors.right: main_window.right }
        },
        State {
            name: "fullscreen"

            PropertyChanges { target: root; width: windowView.width; height: windowView.height }
            PropertyChanges { target: main_window; width: root.width; height: root.height }
            PropertyChanges { target: titlebar; width: root.width; anchors.top: root.top }
            PropertyChanges { target: controlbar; width: root.width; anchors.bottom: root.bottom}
            PropertyChanges { target: playlist; height: root.height; anchors.right: root.right }
        }
    ]

    Timer {
        id: hide_controls_timer
        running: true
        interval: 5000

        onTriggered: {
            if (!mouseInControlsArea() && player.source && player.hasVideo) {
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
        muted: config.playerMuted
        volume: controlbar.volume
        source: movieInfo.movie_file

        subtitleFontSize: Math.floor(config.subtitleFontSize * main_window.width / windowView.defaultWidth)
        subtitleFontFamily: config.subtitleFontFamily || getSystemFontFamily()
        subtitleFontColor: config.subtitleFontColor
        subtitleFontBorderSize: config.subtitleFontBorderSize
        subtitleFontBorderColor: config.subtitleFontBorderColor
        subtitleVerticalPosition: config.subtitleVerticalPosition

        anchors.fill: main_window

        property url lastSource: ""
        property int lastPosition: 0

        // onSourceChanged doesn't ensures that the file is playable, this one did.
        onPlaying: { 
            main_controller.setWindowTitle(movieInfo.movie_title)
            lastSource = source
            database.lastPlayedFile = source 

            if (config.playerCleanPlaylistOnOpenNewFile) playlist.clear()
            main_controller.addPlayListItem(source.toString().substring(7))
        }

        onStopped: {
            database.record_video_position(lastSource, lastPosition)
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
            position != 0 && (lastPosition = position)
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
        anchors.top: root.top
        anchors.left: root.left
        anchors.topMargin: 60
        anchors.leftMargin: 30
    }

    TitleBar {
        id: titlebar
        visible: false
        window: windowView
        showMaximizButton: root.state != "fullscreen"
        anchors.horizontalCenter: main_window.horizontalCenter

        onMinButtonClicked: main_controller.minimize()
        onMaxButtonClicked: main_controller.toggleMaximized()
        onCloseButtonClicked: main_controller.close()
    }

    ControlBar {
        id: controlbar
        visible: false
        window: windowView
        volume: config.playerVolume
        percentage: player.position / movieInfo.movie_duration
        videoPlaying: player.playbackState == MediaPlayer.PlayingState
        muted: config.playerMuted
        widthHeightScale: movieInfo.movie_width / movieInfo.movie_height
        previewHasVideo: player.hasVideo

        anchors.horizontalCenter: main_window.horizontalCenter

        onPreviousButtonClicked: main_controller.playPrevious()
        onNextButtonClicked: main_controller.playNext()

        onTogglePlay: {
            main_controller.togglePlay()
        }

        onChangeVolume: { main_controller.setVolume(volume) }
        onMutedSet: { main_controller.setMute(muted) }

        onPlayStopButtonClicked: { root.reset() }
        onOpenFileButtonClicked: { main_controller.openFile() }
        onPlaylistButtonClicked: { hideControls(); playlist.toggleShow() }
        onPercentageSet: player.seek(movieInfo.movie_duration * percentage)
    }

    Playlist {
        id: playlist
        width: 0
        visible: false
        window: windowView
        currentPlayingSource: player.source
        anchors.right: main_window.right
        anchors.verticalCenter: parent.verticalCenter

        onNewSourceSelected: movieInfo.movie_file = path
        onModeButtonClicked: _menu_controller.show_mode_menu()
        onAddButtonClicked: main_controller.openFile()
        onClearButtonClicked: playlist.clear()
    }
    
    Component.onCompleted: showControls()
}