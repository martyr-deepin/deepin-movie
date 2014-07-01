import QtQuick 2.1
import QtMultimedia 5.0
import QtGraphicalEffects 1.0
import QtQuick.Window 2.1
import Deepin.Locale 1.0
import DBus.Org.Freedesktop.ScreenSaver 1.0

Rectangle {
    id: root
    state: "normal"
    color: "transparent"
    // QT takes care of WORKAREA for you which is thoughtful indeed, but it cause
    // problems sometime, we should be careful in case that it changes height for
    // you suddenly.
    x: (windowView.width - width) / 2
    width: windowView.width
    height: windowView.height
    layer.enabled: true
    
    property var windowLastState: ""

    property real widthHeightScale: (movieInfo.movie_width - 2 * program_constants.windowGlowRadius) / (movieInfo.movie_height - 2 * program_constants.windowGlowRadius)
    property int inhibitCookie: 0
    property bool hasResized: false
    property bool shouldAutoPlayNextOnInvalidFile: false

    property rect primaryRect: {
        return Qt.rect(0, 0, Screen.desktopAvailableWidth, Screen.desktopAvailableHeight)
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
            name: "no_glow"

            PropertyChanges { target: root; width: windowView.width; height: windowView.height }
            PropertyChanges { target: main_window; width: root.width; height: root.height }
            PropertyChanges { target: titlebar; width: root.width; anchors.top: root.top }
            PropertyChanges { target: controlbar; width: root.width; anchors.bottom: root.bottom}
            PropertyChanges { target: playlist; height: root.height; anchors.right: root.right }
        }
    ]

    Connections {
        target: windowView

        onWidthChanged: root.width = windowView.width
        onHeightChanged: root.height = windowView.height 
    }

    ScreenSaver { id: dbus_screensaver }

    Constants { id: program_constants }

    ToolTip { 
        id: tooltip 

        window: windowView
        screenSize: primaryRect
    }

    QtObject {
        id: purposes
        property string openVideoFile: "open_video_file"
        property string openSubtitleFile: "open_subtitle_file"
        property string addPlayListItem: "add_playlist_item"
    }

    OpenFileDialog {
        id: open_file_dialog
        folder: database.lastOpenedPath || _utils.homeDir

        property string purpose: purposes.openVideoFile

        onAccepted: {
            if (fileUrls.length > 0) {
                database.lastOpenedPath = fileUrls[0] // record last opened path

                if (purpose == purposes.openVideoFile) {
                    for (var i = 0; i < fileUrls.length; i++) {
                        var fileUrl = fileUrls[i] + ""
                        main_controller.addPlayListItem(fileUrl.substring(7))
                    }
                    movieInfo.movie_file = fileUrls[0]                    
                } else if (purpose == purposes.openSubtitleFile) {
                    movieInfo.subtitle_file = fileUrls[0]
                } else if (purpose == purposes.addPlayListItem) {
                    for (var i = 0; i < fileUrls.length; i++) {
                        var fileUrl = fileUrls[i] + ""
                        main_controller.addPlayListItem(fileUrl.substring(7))
                    }
                }
            }
        }
    }

    OpenFolderDialog {
        id: open_folder_dialog

        folder: database.lastOpenedPath || _utils.homeDir

        onAccepted: {
            var folderPath = fileUrl
            database.lastOpenedPath = folderPath // record last opened path
            var fileUrls = _utils.getAllVideoFilesInDir(folderPath)
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

    InformationWindow {
        id: info_window

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
        // if (config.playerAdjustType == "ADJUST_TYPE_LAST_TIME") {
        //     var lastSize = database.lastWindowSize
        //     if(database.lastWindowSize != "") {
        //         var lastSize = JSON.parse(lastSize)
        //         windowView.setWidth(lastSize.width)
        //         windowView.setHeight(lastSize.height)
        //         return
        //     }
        // }
        windowView.setWidth(windowView.defaultWidth)
        windowView.setHeight(windowView.defaultHeight)
    }

    function formatTime(millseconds) {
        if (millseconds <= 0) return "00:00:00";
        var secs = Math.ceil(millseconds / 1000)
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
        var mousePos = windowView.getCursorPos()
        var mouseInTitleBar = inRectCheck(Qt.point(mousePos.x - windowView.x, mousePos.y - windowView.y),
                                            Qt.rect(0, 0, main_window.width, titlebar.height))
        var mouseInControlBar = inRectCheck(Qt.point(mousePos.x - windowView.x, mousePos.y - windowView.y),
                                            Qt.rect(0, main_window.height - controlbar.height,
                                                    main_window.width, controlbar.height))

        return mouseInTitleBar || mouseInControlBar
    }

    function mouseInPlaylistArea() {
        var mousePos = windowView.getCursorPos()
        return playlist.expanded && inRectCheck(Qt.point(mousePos.x - windowView.x, mousePos.y - windowView.y),
                                            Qt.rect(main_window.width - program_constants.playlistWidth, 0, 
                                                program_constants.playlistWidth, main_window.height))        
    }

    /* to perform like a newly started program  */
    function reset() {
        root.state = "normal"
        titlebar.title = ""
        movieInfo.movie_file = ""
        main_controller.stop()
        controlbar.reset()
        showControls()
    }

    // To check wether the player is stopped by the app or by the user
    // if it is ther user that stopped the player, we'll not play it automatically.
    property bool videoStoppedByAppFlag: false 
    function monitorWindowState(state) {
        titlebar.windowNormalState = (state == Qt.WindowNoState)
        titlebar.windowFullscreenState = (state == Qt.WindowFullScreen)
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
        dbus_screensaver.UnInhibit(root.inhibitCookie)
        config.save("Normal", "volume", player.volume)
        database.record_video_position(player.source, player.position)
        database.playlist_local = playlist.getContent()
        database.lastWindowWidth = windowView.width
        movieInfo.movie_file && (database.lastPlayedFile = movieInfo.movie_file)
    }

    Timer {
        id: auto_play_next_on_invalid_timer
        interval: 1000 * 3

        onTriggered: main_controller.playNext()
    }

    Timer {
        id: hide_controls_timer
        running: true
        interval: 3000

        onTriggered: {
            if (!mouseInControlsArea() && player.source && player.hasVideo) {
                hideControls()

                if (player.playbackState == MediaPlayer.PlayingState) {
                    windowView.setCursorVisible(false)
                } 
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
        anchors.centerIn: parent

        Rectangle {
            id: bg
            color: "#050811"
            visible: { return !(player.hasVideo && player.visible) }
            anchors.fill: parent
            Image { anchors.centerIn: parent; source: "image/background.png" }
        }
    }

    Player {
        id: player
        muted: config.playerMuted
        volume: config.playerVolume
        source: movieInfo.movie_file

        subtitleShow: config.subtitleAutoLoad
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
            notifybar.hide()
            auto_play_next_on_invalid_timer.stop()
            main_controller.setWindowTitle(movieInfo.movie_title)

            root.inhibitCookie = dbus_screensaver.Inhibit("deepin-movie", "video playing") || 0

            lastSource = source
            database.lastPlayedFile = source
            if (config.playerFullscreenOnOpenFile) main_controller.fullscreen()

            if (config.playerCleanPlaylistOnOpenNewFile) playlist.clear()
            main_controller.addPlayListItem(source.toString().substring(7))
        }

        onStopped: {
            windowView.setTitle(dsTr("Deepin Movie"))
            dbus_screensaver.UnInhibit(root.inhibitCookie)
            database.record_video_position(lastSource, lastPosition)

            if (movieInfo.movie_duration 
                && Math.abs(position - movieInfo.movie_duration) < program_constants.videoEndsThreshold) { 
                // onStopped will be triggered when we change the movie source, 
                // we do this to make sure that the follwing code executed only when 
                // the movie played out naturally.
                shouldAutoPlayNextOnInvalidFile = true
                main_controller.playNext()
            }
        }

        onPositionChanged: {
            position != 0 && (lastPosition = position)
            subtitleContent = movieInfo.get_subtitle_at(position + subtitleDelay)
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
        width: main_window.width / 2
        anchors.top: root.top
        anchors.left: root.left
        anchors.topMargin: 60
        anchors.leftMargin: 30
    }

    TitleBar {
        id: titlebar
        visible: false
        window: windowView
        windowStaysOnTop: windowView.staysOnTop
        anchors.horizontalCenter: main_window.horizontalCenter

        onMenuButtonClicked: _menu_controller.show_menu()
        onMinButtonClicked: main_controller.minimize()
        onMaxButtonClicked: windowNormalState ? main_controller.maximize() : main_controller.normalize()
        onCloseButtonClicked: main_controller.close()

        onQuickNormalSize: main_controller.setScale(1)
        onQuickOneHalfSize: main_controller.setScale(1.5)
        onQuickToggleFullscreen: main_controller.fullscreen()
        onQuickToggleTop: main_controller.toggleStaysOnTop()
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
        dragbarVisible: root.state == "normal"

        anchors.horizontalCenter: main_window.horizontalCenter

        Timer {
            id: delay_seek_timer
            interval: 500
            property int destPos

            onTriggered: player.seek(destPos)
        }

        onPreviousButtonClicked: main_controller.playPrevious()
        onNextButtonClicked: main_controller.playNext()

        onChangeVolume: { main_controller.setVolume(volume) }
        onMutedSet: { main_controller.setMute(muted) }

        onPlayStopButtonClicked: { root.reset() }
        onPlayPauseButtonClicked: { main_controller.togglePlay() }
        onOpenFileButtonClicked: { main_controller.openFile() }
        onPlaylistButtonClicked: { hideControls(); playlist.toggleShow() }
        onPercentageSet: {
            delay_seek_timer.destPos = movieInfo.movie_duration * percentage
            delay_seek_timer.restart()
        }
    }

    Playlist {
        id: playlist
        width: 0
        visible: false
        window: windowView
        maxWidth: main_window.width * 0.6
        currentPlayingSource: player.source
        anchors.right: main_window.right
        anchors.verticalCenter: parent.verticalCenter

        onNewSourceSelected: movieInfo.movie_file = path
        onModeButtonClicked: _menu_controller.show_mode_menu()
        onAddButtonClicked: main_controller.openFileForPlaylist()
        onClearButtonClicked: playlist.clear()
    }
    
    Component.onCompleted: showControls()
}