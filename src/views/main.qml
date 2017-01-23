import QtQuick 2.1
import QtAV 1.5
import QtGraphicalEffects 1.0
import QtQuick.Window 2.1
import Deepin.Locale 1.0
import Deepin.Widgets 1.0
import "../controllers"
import "sources/ui_utils.js" as UIUtils

Rectangle {
    id: root
    state: "normal"
    color: "transparent"

    // this property will be set when the window's initializing its size,
    // and will be changed only when the resolution of the player changes.
    property real widthHeightScale
    property real actualScale: 1.0

    property bool hasResized: false
    property bool isMiniMode: false
    property bool shouldAutoPlayNextOnInvalidFile: false

    property rect primaryRect: {
        return Qt.rect(0, 0, Screen.desktopAvailableWidth, Screen.desktopAvailableHeight)
    }

    // Used to check whether the player is stopped by the app or by the user,
    // if it is the user that stopped the player, we'll not play it automatically.
    property bool videoStoppedByAppFlag: false
    property bool videoFullscreenByAppFlag: false

    // properties that used as ids
    property alias tooltip: tooltip_loader.item
    property alias shortcuts_viewer: shortcuts_viewer_loader.item

    states: [
        State {
            name: "normal"

            PropertyChanges { target: main_window; width: root.width - program_constants.windowGlowRadius * 2;
                              height: root.height - program_constants.windowGlowRadius * 2; }
            PropertyChanges { target: titlebar; width: main_window.width; anchors.top: main_window.top }
            PropertyChanges { target: controlbar; width: main_window.width; anchors.bottom: main_window.bottom}
            PropertyChanges { target: playlist; height: main_window.height; anchors.right: main_window.right }
            PropertyChanges { target: player; fillMode: VideoOutput.Stretch }
        },
        State {
            name: "no_glow"

            PropertyChanges { target: main_window; width: root.width; height: root.height }
            PropertyChanges { target: titlebar; width: root.width; anchors.top: root.top }
            PropertyChanges { target: controlbar; width: root.width; anchors.bottom: root.bottom}
            PropertyChanges { target: playlist; height: root.height; anchors.right: root.right }
            PropertyChanges { target: player; fillMode: VideoOutput.PreserveAspectFit }
        }
    ]

    onStateChanged: {
        if (state == "normal") {
            windowView.setDeepinWindowShadowHint(windowView.windowGlowRadius)
        } else if (state == "no_glow") {
            windowView.setDeepinWindowShadowHint(0)
        }
    }

    Constants { id: program_constants }

    PreferenceWindow { id: preference_window }
    InformationWindow {
        id: info_window
        onCopyToClipboard: _utils.copyToClipboard(text)
    }

    OpenFileDialog {
        id: open_file_dialog
        modality: Qt.ApplicationModal
        transientParent: windowView
        onAccepted: {
            shouldAutoPlayNextOnInvalidFile = false

            if (fileUrls.length > 0) {
                var filePaths = []
                for (var i = 0; i < fileUrls.length; i++) {
                    filePaths.push(decodeURIComponent(fileUrls[i]).replace("file://", ""))
                }

                if (state == "open_video_file") {
                    _settings.lastOpenedPath = folder
                    main_controller.playPaths(filePaths, true)
                } else if (state == "open_subtitle_file") {
                    _settings.lastOpenedPath = folder
                    var filename = filePaths[0]

                    if (_utils.fileIsSubtitle(filename)) {
                        main_controller.setSubtitle(filename)
                    } else {
                        main_controller.notifyInvalidFile(filename)
                    }
                } else if (state == "add_playlist_item") {
                    _settings.lastOpenedPath = folder

                    main_controller.playPaths(filePaths, false)
                } else if (state == "import_playlist") {
                    _settings.lastOpenedPlaylistPath = folder

                    var filename = filePaths[0]
                    main_controller.importPlaylistImpl(filename)
                } else if (state == "export_playlist") {
                    _settings.lastOpenedPlaylistPath = folder

                    var filename = filePaths[0]
                    if (filename.toString().search(".dmpl") == -1) {
                        filename = filename + ".dmpl"
                    }
                    main_controller.exportPlaylistImpl(filename)
                }
            }
        }
    }

    OpenFolderDialog {
        id: open_folder_dialog
        modality: Qt.ApplicationModal
        transientParent: windowView
        folder: _settings.lastOpenedPath || _utils.homeDir

        property bool playFirst: true

        onAccepted: {
            shouldAutoPlayNextOnInvalidFile = false

            var folderPath = fileUrl.toString()
            _settings.lastOpenedPath = folder // record last opened path
            main_controller.playPaths([folderPath], playFirst)
        }
    }

    DInputDialog {
        id: open_url_dialog
        modality: Qt.ApplicationModal
        message: dsTr("Please input the url of file played") + dsTr(":")
        confirmButtonLabel: dsTr("Confirm")
        cancelButtonLabel: dsTr("Cancel")

        cursorPosGetter: windowView

        property string lastInput: ""

        function open() {
            x = windowView.x + (windowView.width - width) / 2
            y = windowView.y + (windowView.height - height) / 2
            show()
        }

        onConfirmed: {
            var input = input.trim()

            if (input.search("://") == -1) {
                notifybar.show(dsTr("The parse failed"))
            } else if (input != player.source) {
                if (config.playerCleanPlaylistOnOpenNewFile) {
                    main_controller.clearPlaylist()
                }
                shouldAutoPlayNextOnInvalidFile = false
                main_controller.playPaths([input], true)
            }

            lastInput = input
        }

        onVisibleChanged: { if(visible) forceFocus() }
    }

    Component {
        id: tooltip_component

        ToolTip {
            window: windowView
            screenSize: primaryRect
        }
    }

    Component {
        id: shortcuts_viewer_component

        ShortcutsViewer {
            x: Math.max(0, Math.min(windowView.x + (windowView.width - width) / 2, Screen.width - width))
            y: Math.max(0, Math.min(windowView.y + (windowView.height - height) / 2, Screen.height - height))
        }
    }

    Loader {
        id: tooltip_loader
        asynchronous: true
        sourceComponent: tooltip_component
    }

    Loader {
        id: shortcuts_viewer_loader
        asynchronous: true
        sourceComponent: shortcuts_viewer_component
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
        resetWindowSize()
        root.widthHeightScale = (windowView.width - windowView.windowGlowRadius * 2) / (windowView.height - windowView.windowGlowRadius * 2)

        if (config.playerApplyLastClosedSize) {
            hasResized = true
            main_controller.setSizeForRootWindowWithWidth(_settings.lastWindowWidth)
        }
    }

    function resetWindowSize() {
        windowView.setMinimumWidth(windowView.minimumWidth)
        windowView.setMinimumHeight(windowView.minimumHeight)
        windowView.setWidth(windowView.defaultWidth)
        windowView.setHeight(windowView.defaultHeight)
    }

    // this function share the same name with one function in MainController,
    // but this function is mainly used to expose the dbus interface, tanslating
    // the dbus arguments into the ones that its namesake can understand.
    function playPaths(pathList) {
        var pathList = JSON.parse(pathList)
        var pathsExceptUrls = new Array()
        var firstIsUrl = false
        for (var i = 0; i < pathList.length; i++) {
            if (!_utils.urlIsNativeFile(pathList[i])) {
                main_controller.addPlaylistStreamItem(pathList[i])
                if (i == 0) {
                    main_controller.playPath(pathList[i])
                    firstIsUrl = true
                }
            } else {
                pathsExceptUrls.push(pathList[i])
            }
        }
        main_controller.playPaths(pathsExceptUrls, !firstIsUrl)
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

    // handle transient windows state
    function hideTransientWindows() {
        shortcuts_viewer.hide()
        resize_visual.hide()
    }

    function subtitleVisible() {
        return player.subtitleShow
    }

    function setSubtitleVisible(visible) {
        player.subtitleShow = visible;
    }

    function mouseInControlsArea() {
        var mousePos = windowView.getCursorPos()
        var mouseInTitleBar = UIUtils.inRectCheck(Qt.point(mousePos.x - windowView.x, mousePos.y - windowView.y),
                                            Qt.rect(0, 0, main_window.width, titlebar.height))
        var mouseInControlBar = UIUtils.inRectCheck(Qt.point(mousePos.x - windowView.x, mousePos.y - windowView.y),
                                            Qt.rect(0, main_window.height - controlbar.height,
                                                    main_window.width, controlbar.height))

        return mouseInTitleBar || mouseInControlBar
    }

    function mouseInPlaylistArea() {
        var mousePos = windowView.getCursorPos()
        return playlist.expanded && UIUtils.inRectCheck(Qt.point(mousePos.x - windowView.x, mousePos.y - windowView.y),
                                            Qt.rect(main_window.width - program_constants.playlistWidth, 0,
                                                program_constants.playlistWidth, main_window.height))
    }

    function mouseInPlaylistTriggerArea() {
        var mousePos = windowView.getCursorPos()
        return !playlist.expanded && UIUtils.inRectCheck(Qt.point(mousePos.x - windowView.x, mousePos.y - windowView.y),
                                            Qt.rect(main_window.width - program_constants.playlistTriggerThreshold, titlebar.height,
                                                    program_constants.playlistTriggerThreshold + 10, main_window.height - controlbar.height))
    }

    /* to perform like a newly started program  */
    function reset() {
        bg.visible = true
        root.state = "normal"
        root.resetWindowSize()
        _subtitle_parser.file_name = ""

        player.reset()
        titlebar.reset()
        controlbar.reset()
        main_controller.stop()
        root.showControls()
    }

    function monitorWindowState(state) {
        titlebar.windowNormalState = (state == Qt.WindowNoState)
        titlebar.windowFullscreenState = (state == Qt.WindowFullScreen)
        controlbar.windowFullscreenState = (state == Qt.WindowFullScreen)
        time_indicator.visibleSwitch = (state == Qt.WindowFullScreen && player.hasMedia)

        if (state == Qt.WindowMinimized) {
            root.state = "normal"

            if (config.playerPauseOnMinimized
                && player.playbackState == MediaPlayer.PlayingState)
            {
                main_controller.pause()
                videoStoppedByAppFlag = true
            }
        } else {
            if (videoStoppedByAppFlag == true) {
                main_controller.play()
                videoStoppedByAppFlag = false
            }

            if (state == Qt.WindowFullScreen) {
                root.state = "no_glow"
            } else if (state == Qt.WindowMaximized) {
                root.state = "no_glow"
            } else if (state == Qt.WindowNoState) {
                root.state = "normal"
            }
        }
    }

    function monitorWindowClose() {
        _utils.screenSaverUninhibit()
        main_controller.recordVideoPosition(player.sourceString, player.position)
        main_controller.recordVideoRotation(player.sourceString, player.orientation)
        _database.setPlaylistContentCache(playlist.getContent())
        _settings.lastWindowWidth = windowView.width
        player.sourceString && (_settings.lastPlayedFile = player.sourceString)
    }

    Timer {
        id: auto_play_next_on_invalid_timer
        interval: 1000 * 2

        property string invalidFile: ""

        function startWidthFile(file) {
            invalidFile = file
            restart()
        }

        onTriggered: {
            main_controller.playNextOf(invalidFile)
        }
    }

    Timer {
        id: hide_controls_timer
        running: true
        interval: 1500

        onTriggered: {
            if (!mouseInControlsArea() && player.source && player.hasVideo) {
                hideControls()

                if (player.playbackState == MediaPlayer.PlayingState && windowView.active) {
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
        width: root.width - program_constants.windowGlowRadius * 2
        height: root.height - program_constants.windowGlowRadius * 2
        clip: true
        color: "black"
        anchors.centerIn: parent

        Rectangle {
            id: bg
            color: "#000000"
            anchors.fill: parent

            Connections {
                target: player
                onPlaying: bg.visible = false
            }

            Image {
                source: "image/background.png"
                scale: Math.min(1, windowView.width / windowView.defaultWidth)

                anchors.centerIn: parent
            }
        }
    }

    Player {
        id: player
        muted: config.playerMuted
        volume: config.playerVolume

        subtitleFontSize: Math.floor(config.subtitleFontSize * main_window.width / windowView.defaultWidth)
        subtitleFontFamily: config.subtitleFontFamily || getSystemFontFamily()
        subtitleFontColor: config.subtitleFontColor
        subtitleFontBorderSize: config.subtitleFontBorderSize
        subtitleFontBorderColor: config.subtitleFontBorderColor
        subtitleVerticalPosition: config.subtitleVerticalPosition

        anchors.fill: main_window

        // theses properties are mainly used in onStopped.
        // because we can't ensure the source and position info available every
        // time the onStopped handler executes.
        property string lastVideoSource: ""
        property int lastVideoPosition: 0
        property int lastVideoDuration: 0
        property int lastForwardToPosition: 0
        property bool playerInit: true

        onStatusChanged: {
            if (status == MediaPlayer.Buffering) {
                notifybar.showPermanently(dsTr("Buffering..."))
            } else if (notifybar.text == dsTr("Buffering...")) {
                notifybar.hide()
            }
        }

        onResolutionChanged: main_controller.handleResolutionChanged()

        // onSourceChanged doesn't ensures that the file is playable, this one did.
        // 2014/9/16 add: not ensures url playable, either
        onPlaying: {
            if (playerInit) {
                if (config.playerFullscreenOnOpenFile) {
                    main_controller.fullscreen()
                    root.videoFullscreenByAppFlag = true
                } else if (root.videoFullscreenByAppFlag) {
                    main_controller.quitFullscreen()
                }
            }

            playerInit = false
            notifybar.hide()
            auto_play_next_on_invalid_timer.stop()
            main_controller.setWindowTitle(_utils.getTitleFromUrl(player.sourceString))

            _utils.screenSaverInhibit()

            lastVideoSource = sourceString
            lastVideoDuration = duration
        }

        onStopped: {
            lastForwardToPosition = 0
            resetRotationFlip()
            _utils.screenSaverUninhibit()
            main_controller.recordVideoPosition(lastVideoSource, lastVideoPosition)

            var videoPLayedOut = (lastVideoDuration - lastVideoPosition) < program_constants.videoEndsThreshold
            if (videoPLayedOut) {
                shouldAutoPlayNextOnInvalidFile = true
                main_controller.playNextOf(_settings.lastPlayedFile)
            }
        }

        onPlaybackStateChanged: {
            controlbar.videoPlaying = player.playbackState == MediaPlayer.PlayingState
        }

        onPositionChanged: {
            position != 0 && (lastVideoPosition = position)
            subtitleContent = _subtitle_parser.get_subtitle_at(position)
            controlbar.percentage = position / player.duration
        }

        property bool resetPlayHistoryCursor: true
        onSourceChanged: {
            playerInit = true
            resetRotationFlip()

            if (source.toString().trim()) {
                _settings.lastPlayedFile = sourceString
                _database.appendPlayHistoryItem(sourceString, resetPlayHistoryCursor)
                main_controller.recordVideoPosition(lastVideoSource, lastVideoPosition)
                resetPlayHistoryCursor = true

                _menu_controller.reset()
                main_controller.seekToLastPlayed()

                if (config.subtitleAutoLoad) {
                    var subtitleInfo = _database.getPlaylistItemSubtitle(player.sourceString)
                    var path = ""
                    var delay = 0

                    try {
                        var subtitleObj = JSON.parse(subtitleInfo)
                        path = subtitleObj["path"]
                        delay = subtitleObj["delay"]

                        if (path) {
                            main_controller.setSubtitle(path)
                            if (delay) _subtitle_parser.delay = delay
                        } else {
                            _subtitle_parser.set_subtitle_from_movie(player.sourceString)
                        }
                    } catch(e) {
                        _subtitle_parser.set_subtitle_from_movie(player.sourceString)
                    }
                } else {
                    _subtitle_parser.file_name = ""
                }

                var rotation = main_controller.fetchVideoRotation(source)
                var rotateClockwiseCount = Math.abs(Math.round((rotation % 360 - 360) % 360 / 90))
                for (var i = 0; i < rotateClockwiseCount; i++) {
                    main_controller.rotateClockwise()
                }
            }
        }

        onErrorChanged: {
            print(error, errorString)
            switch(error) {
                case MediaPlayer.FormatError:
                case MediaPlayer.ResourceError: {
                    if (player.sourceString == open_url_dialog.lastInput.trim())
                    {
                        playlist.removeItem(sourceString)
                        open_url_dialog.lastInput = ""
                    }

                    main_controller.notifyInvalidFile(sourceString)
                    if (root.shouldAutoPlayNextOnInvalidFile) {
                        main_controller.playNextOf(sourceString)
                    }
                }
                break
            }
        }
    }

    TimeIndicator {
        id: time_indicator
        visible: visibleSwitch && !titlebar.visible
        percentage: controlbar.percentage

        property bool visibleSwitch: false

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
        anchors.topMargin: 40
        anchors.leftMargin: 30
    }

    Playlist {
        id: playlist
        width: 0
        visible: false
        window: windowView
        maxWidth: main_window.width * 0.6
        currentPlayingSource: player.sourceString
        tooltipItem: tooltip
        canExpand: controlbar.status != "minimal"
        anchors.right: main_window.right
        anchors.verticalCenter: parent.verticalCenter

        onShowed: root.hideControls()

        onNewSourceSelected: {
            shouldAutoPlayNextOnInvalidFile = false
            main_controller.playPath(path)
        }
        onModeButtonClicked: _menu_controller.show_mode_menu()
        onAddButtonClicked: _menu_controller.show_add_button_menu()

        onMoveInWindowButtons: titlebar.showForPlaylist()
        onMoveOutWindowButtons: titlebar.hideForPlaylist()

        onCleared: main_controller.clearPlaylist()
        onItemRemoved: main_controller.removePlaylistItem(url)
        onCategoryRemoved: main_controller.removePlaylistCategory(name)
    }

    TitleBar {
        id: titlebar
        state: root.isMiniMode ? "minimal" : "normal"
        visible: false
        window: windowView
        windowStaysOnTop: windowView.staysOnTop
        anchors.horizontalCenter: main_window.horizontalCenter
        tooltipItem: tooltip

        onMenuButtonClicked: main_controller.showMainMenu()
        onMinButtonClicked: main_controller.minimize()
        onMaxButtonClicked: main_controller.toggleMaximized()
        onCloseButtonClicked: main_controller.close()

        onQuickNormalSize: main_controller.setScale(1)
        onQuickOneHalfSize: main_controller.setScale(1.5)
        onQuickToggleFullscreen: main_controller.toggleFullscreen()
        onQuickToggleTop: main_controller.toggleStaysOnTop()
    }

    ControlBar {
        id: controlbar
        videoPlayer: player
        visible: false
        window: windowView
        volume: player.volume
        percentage: player.position / player.duration
        muted: player.muted
        widthHeightScale: root.widthHeightScale
        dragbarVisible: root.state == "normal"
        timeInfoVisible: player.source != "" && player.hasMedia && player.duration != 0
        tooltipItem: tooltip
        videoSource: player.sourceString
        previewEnabled: config.playerShowPreview && heightWithPreview < main_window.height

        anchors.horizontalCenter: main_window.horizontalCenter

        Timer {
            id: delay_seek_timer
            interval: 500
            property int destPos

            onTriggered: player.seek(destPos)
        }

        onPreviousButtonClicked: { main_controller.playPrevious() }
        onNextButtonClicked: { main_controller.playNext() }

        onChangeVolume: { main_controller.setVolume(volume) }
        onMutedSet: { main_controller.setMute(muted) }

        onToggleFullscreenClicked: main_controller.toggleFullscreen()

        onPlayStopButtonClicked: { root.reset() }
        onPlayPauseButtonClicked: { main_controller.togglePlay() }
        onOpenFileButtonClicked: { main_controller.openFile() }
        onPlaylistButtonClicked: { playlist.toggleShow() }
        onPercentageSet: {
            if (player.duration) {
                delay_seek_timer.destPos = player.duration * percentage
                delay_seek_timer.restart()
            }
        }
    }

    ResizeEdge { id: resize_edge }
    ResizeVisual {
        id: resize_visual

        frameY: windowView.y
        frameX: windowView.x
        frameWidth: root.width
        frameHeight: root.height
        widthHeightScale: root.widthHeightScale
    }

    Component.onCompleted: showControls()
}
