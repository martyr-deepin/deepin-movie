import QtQuick 2.1
import QtAV 1.5
import "../controllers"
import "sources/ui_utils.js" as UIUtils

MouseArea {
    id: mouse_area
    focus: true
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    anchors.fill: window

    property var window
    property int resizeEdge
    property int triggerThreshold: 10  // threshold for resizing the window
    property int cornerTriggerThreshold: 20

    property int dragStartX
    property int dragStartY
    property int windowLastX
    property int windowLastY

    property bool shouldPerformClick: true
    property bool shouldPlayThefirst: true

    MenuResponder { id: menu_responder }
    KeysResponder { id: keys_responder }

    Connections {
        target: _findVideoThreadManager

        onFirstVideoFound: {
            main_controller.shouldPlayThefirst && main_controller.playPath(path)
        }

        onFindVideoDone: {
            invalidCount > 0 && notifybar.show(dsTr("%1 files unable to be parsed have been excluded").arg(invalidCount))

            _database.addPlaylistCITuples(tuples)
        }
    }

    Connections {
        target: _database

        onPlaylistItemAdded: {
            playlist.addItem(category, name, url)
        }

        onImportDone: { notifybar.show(dsTr("Imported") + ": " + filename)}

        onItemVInfoGot: info_window.showInfo(vinfo)
    }

    Connections {
        target: _file_monitor
        onFileExistenceChanged: playlist.changeFileExistence(file, existence)
    }

    Connections {
        target: _subtitle_parser
        onFileNameChanged: {
            _database.setPlaylistItemSubtitle(player.sourceString,
                                              _subtitle_parser.file_name,
                                              _subtitle_parser.delay)
        }
        onDelayChanged: {
            _database.setPlaylistItemSubtitle(player.sourceString,
                                              _subtitle_parser.file_name,
                                              _subtitle_parser.delay)
        }
    }

    Timer {
        id: seek_to_last_watched_timer
        interval: 300

        onTriggered: {
            var last_watched_pos = main_controller.fetchVideoPosition(player.sourceString)
            if (config.playerAutoPlayFromLast
                && last_watched_pos > program_constants.videoEndsThreshold
                && _utils.urlIsNativeFile(player.sourceString)
                && Math.abs(last_watched_pos - player.duration) > program_constants.videoEndsThreshold) {
                player.seek(last_watched_pos)
            }
        }
    }

    Timer {
        id: show_playlist_timer
        interval: 100

        onTriggered: {
            if (mouseX >= main_window.width - program_constants.playlistTriggerThreshold) {
                playlist.showHandle()
            }
        }
    }

    Timer {
        id: double_click_check_timer
        interval: 400

        onTriggered: doSingleClick()
    }

    function _getActualWidthWithWidth(destWidth) {
        var widthHeightScale = root.widthHeightScale
        var destHeight = (destWidth - program_constants.windowGlowRadius * 2) / widthHeightScale + program_constants.windowGlowRadius * 2
        if (destHeight > primaryRect.height) {
            return (primaryRect.height - 2 * program_constants.windowGlowRadius) * widthHeightScale + 2 * program_constants.windowGlowRadius
        } else {
            return destWidth
        }
    }

    function setSizeForRootWindowWithWidth(destWidth) {
        var widthHeightScale = root.widthHeightScale

        var destWidth = Math.min(destWidth, primaryRect.width)
        var destHeight = (destWidth - program_constants.windowGlowRadius * 2) / widthHeightScale + program_constants.windowGlowRadius * 2
        if (destHeight > primaryRect.height) {
            destWidth = (primaryRect.height - 2 * program_constants.windowGlowRadius) * widthHeightScale + 2 * program_constants.windowGlowRadius
            destHeight = primaryRect.height
        }

        var deltaX = windowView.x + destWidth - primaryRect.width
        var deltaY = windowView.y + destHeight - primaryRect.height
        if (deltaX > 0 && Math.abs(destWidth - windowView.width) > 5) {
            windowView.setX(windowView.x - deltaX)
        }
        if (deltaY > 0 && Math.abs(destHeight - windowView.height) > 5) {
            windowView.setY(windowView.y - deltaY)
        }
        windowView.setWidth(destWidth)
        windowView.setHeight(destHeight)
    }

    function setWindowTitle(title) {
        titlebar.title = title
        windowView.setTitle(title)
    }

    // resize operation related
    function getEdge(mouse) {
        if (windowView.getState() == Qt.WindowFullScreen) return resize_edge.resizeNone
        // four corners
        if (0 < mouse.x && mouse.x < cornerTriggerThreshold) {
            if (0 < mouse.y && mouse.y < cornerTriggerThreshold)
                return resize_edge.resizeTopLeft
            if (window.height - cornerTriggerThreshold < mouse.y && mouse.y < window.height)
                return resize_edge.resizeBottomLeft
        } else if (window.width - cornerTriggerThreshold < mouse.x && mouse.x < window.width) {
            if (0 < mouse.y && mouse.y < cornerTriggerThreshold)
                return resize_edge.resizeTopRight
            if (window.height - cornerTriggerThreshold < mouse.y && mouse.y < window.height)
                return resize_edge.resizeBottomRight
        }
        // four sides
        if (0 < mouse.x && mouse.x < triggerThreshold) {
            return resize_edge.resizeLeft
        } else if (window.width - triggerThreshold < mouse.x && mouse.x < window.width) {
            return resize_edge.resizeRight
        } else if (0 < mouse.y && mouse.y < triggerThreshold){
            return resize_edge.resizeTop
        } else if (window.height - triggerThreshold < mouse.y && mouse.y < window.height) {
            return resize_edge.resizeBottom
        }

        return resize_edge.resizeNone
    }

    function changeCursor(resizeEdge) {
        if (resizeEdge == resize_edge.resizeLeft || resizeEdge == resize_edge.resizeRight) {
            cursorShape = Qt.SizeHorCursor
        } else if (resizeEdge == resize_edge.resizeTop || resizeEdge == resize_edge.resizeBottom) {
            cursorShape = Qt.SizeVerCursor
        } else if (resizeEdge == resize_edge.resizeTopLeft || resizeEdge == resize_edge.resizeBottomRight) {
            cursorShape = Qt.SizeFDiagCursor
        } else if (resizeEdge == resize_edge.resizeBottomLeft || resizeEdge == resize_edge.resizeTopRight){
            cursorShape = Qt.SizeBDiagCursor
        } else {
            cursorShape = Qt.ArrowCursor
        }
    }

    function _getPlaylistItemInfo(category, url) {
        var urlIsNativeFile = _utils.urlIsNativeFile(url)

        url = url.replace("file://", "")
        var pathDict = url.split("/")
        var result = pathDict.slice(pathDict.length - 2, pathDict.length + 1)
        var itemName = urlIsNativeFile ? result[result.length - 1].toString() : url
        url = "file://" + url

        return [itemName, url, category]
    }

    function addPlayListItem(category, url) {
        if (_database.containsPlaylistItem(url)) return

        if (category) {
            var info = _getPlaylistItemInfo(category, url)
            _database.addPlaylistItem(info[0], info[1], info[2])
        } else {
            var info = _getPlaylistItemInfo("", url)
            _database.addPlaylistItem(info[0], info[1], info[2])
        }
    }

    function addPlaylistStreamItem(url) {
        // NOTE: playlist.addItem and _database.addPlaylistItem have different
        // parameter order.
        playlist.addItem("", url.toString(), url.toString())
    }

    function removePlaylistItem(url) {
        _database.removePlaylistItem(url)
    }

    function removePlaylistCategory(name) {
        _database.removePlaylistCategory(name)
    }
    function clearPlaylist() {
        _database.clearPlaylist()
        _settings.lastPlayedFile = ""
        _database.clearPlayHistory()
    }

    function recordVideoPosition(url, played) {
        _database.setPlaylistItemPlayed(url, played)
    }

    function fetchVideoPosition(url) {
        return _database.getPlaylistItemPlayed(url)
    }

    function recordVideoRotation(url, rotation) {
        _database.setPlaylistItemRotation(url, rotation)
    }

    function fetchVideoRotation(url) {
        return _database.getPlaylistItemRotation(url)
    }

    function showMainMenu() {
        var stateInfo = {
            "videoSource": player.sourceString,
            "hasVideo": player.hasVideo,
            "subtitleFile": _subtitle_parser.file_name,
            "subtitleVisible": player.subtitleShow,
            "isFullscreen": windowView.getState() == Qt.WindowFullScreen,
            "isMiniMode": root.isMiniMode,
            "isOnTop": windowView.staysOnTop,
        }
        _menu_controller.show_menu(JSON.stringify(stateInfo))
    }

    function notifyInvalidFile(file) {
        notifybar.show(dsTr("Invalid file") + dsTr(":") + " " + file)
    }

    function close() {
        windowView.close()
    }

    property bool fullscreenFromMaximum: false
    property bool fullscreenFromMiniMode: false
    function fullscreen() {
        if (!player.hasVideo) return

        fullscreenFromMaximum = (windowView.getState() == Qt.WindowMaximized)
        fullscreenFromMiniMode = root.isMiniMode
        windowView.showFullScreen()
        root.videoStoppedByAppFlag = false

        fullscreenFromMiniMode && quitMiniMode()
    }

    function quitFullscreen() {
        fullscreenFromMaximum ? maximize() : windowView.showNormal()

        maximizeFromMiniMode && miniMode()
    }

    property bool maximizeFromMiniMode: false
    function maximize() {
        maximizeFromMiniMode = root.isMiniMode
        windowView.showMaximized()

        maximizeFromMiniMode && quitMiniMode()
    }

    function quitMaximized() {
        windowView.showNormal()
        maximizeFromMiniMode && miniMode()
    }

    function minimize() {
        windowView.doMinimized()
    }

    property int backupWidth: 0
    property point backupCenter: Qt.point(0, 0)
    function quitMiniMode() {
        if (!player.hasVideo) return

        windowView.staysOnTop = false
        if (windowView.getState() != Qt.WindowMaximized
            && windowView.getState() != Qt.WindowFullScreen)
        {
            setSizeForRootWindowWithWidth(backupWidth)
            windowView.setX(backupCenter.x - windowView.width / 2)
            windowView.setY(backupCenter.y - windowView.height / 2)
        }
        windowView.requestActivate()

        root.isMiniMode = false
    }
    function miniMode() {
        if (!player.hasVideo) return

        _menu_controller.videoScale = ""
        if (windowView.getState() != Qt.WindowMaximized
            && windowView.getState() != Qt.WindowFullScreen)
        {
            backupWidth = windowView.width
            backupCenter = Qt.point(windowView.x + windowView.width / 2,
                windowView.y + windowView.height / 2)
        }
        windowView.showNormal()
        windowView.staysOnTop = true
        setSizeForRootWindowWithWidth(program_constants.miniModeWidth)

        windowView.setX(backupCenter.x - windowView.width / 2)
        windowView.setY(backupCenter.y - windowView.height / 2)
        windowView.requestActivate()

        root.isMiniMode = true
    }

    function toggleMiniMode() {
        root.isMiniMode ? quitMiniMode() : miniMode()
    }

    function showManual() { _utils.showManual() }

    function showPreferenceWindow() {
        preference_window.flags = windowView.getState() == Qt.WindowFullScreen ? Qt.BypassWindowManagerHint : Qt.FramelessWindowHint | Qt.Dialog
        preference_window.close()
        preference_window.x = windowView.x + (windowView.width - preference_window.width) / 2
        preference_window.y = windowView.y + (windowView.height - preference_window.height) / 2
        preference_window.scrollToTop()
        preference_window.show()
    }

    function showInformationWindow(url) {
        info_window.flags = windowView.getState() == Qt.WindowFullScreen ? Qt.BypassWindowManagerHint : Qt.FramelessWindowHint | Qt.Dialog
        info_window.close()
        info_window.x = windowView.x + (windowView.width - info_window.width) / 2
        info_window.y = windowView.y + (windowView.height - info_window.height) / 2
        _database.getPlaylistItemVInfo(url)
    }

    function setProportion(propWidth, propHeight) {
        if (propWidth == 1 && propHeight == 1) { // indicates we should reset the proportion, see menu_controller.py for more details
            root.widthHeightScale = (player.resolution.width - program_constants.windowGlowRadius * 2) / (player.resolution.height - program_constants.windowGlowRadius * 2)
        } else {
            root.widthHeightScale = propWidth / propHeight
        }

        var destWidth = (player.resolution.width - program_constants.windowGlowRadius * 2) * root.actualScale + program_constants.windowGlowRadius * 2
        player.fillMode = VideoOutput.Stretch

        setSizeForRootWindowWithWidth(destWidth)
    }

    function setScale(scale) {
        root.actualScale = scale
        var destWidth = (player.resolution.width - program_constants.windowGlowRadius * 2) * root.actualScale + program_constants.windowGlowRadius * 2

        setSizeForRootWindowWithWidth(destWidth)
    }

    function toggleFullscreen() {
        windowView.getState() == Qt.WindowFullScreen ? quitFullscreen() : fullscreen()
    }

    function toggleMaximized() {
        windowView.getState() == Qt.WindowMaximized ? quitMaximized() : maximize()
    }

    function toggleStaysOnTop() {
        windowView.staysOnTop = !windowView.staysOnTop
    }

    function togglePlaylist() {
        if (playlist.expanded) {
            playlist.hide()
        } else {
            playlist.show()
        }
    }
    function handleResolutionChanged() {
        if (!player.sourceString) return

        if (player.resolution.width > player.resolution.height) {
            windowView.setMinimumWidth(Math.max(windowView.minimumWidth, windowView.minimumHeight))
            windowView.setMinimumHeight(Math.min(windowView.minimumWidth, windowView.minimumHeight))
        } else {
            windowView.setMinimumWidth(Math.min(windowView.minimumWidth, windowView.minimumHeight))
            windowView.setMinimumHeight(Math.max(windowView.minimumWidth, windowView.minimumHeight))
        }

        root.widthHeightScale = player.resolution.width / player.resolution.height
        if (root.isMiniMode) {
            backupWidth = player.resolution.width
            setSizeForRootWindowWithWidth(windowView.width)
            backupCenter = Qt.point(windowView.x + windowView.width / 2,
                                    windowView.y + windowView.height / 2)
            return
        }

        if (root.hasResized) {
            if (player.playerInit) {
                root.actualScale = (windowView.width - program_constants.windowGlowRadius * 2) / player.resolution.width
            }
            setSizeForRootWindowWithWidth(player.resolution.width * root.actualScale + program_constants.windowGlowRadius * 2)
        } else {
            var destWidth = player.resolution.width + program_constants.windowGlowRadius * 2
            if (player.playerInit) {
                root.actualScale = (_getActualWidthWithWidth(destWidth) - program_constants.windowGlowRadius * 2) / player.resolution.width
            }
            setSizeForRootWindowWithWidth(destWidth)
        }
    }

    function flipHorizontal() { player.flipHorizontal(); controlbar.flipPreviewHorizontal() }
    function flipVertical() { player.flipVertical(); controlbar.flipPreviewVertical() }

    function rotateClockwise() {
        player.rotateClockwise()
        controlbar.rotatePreviewClockwise()
        main_controller.recordVideoRotation(player.sourceString, player.orientation)
    }
    function rotateAnticlockwise() {
        player.rotateAnticlockwise()
        controlbar.rotatePreviewAntilockwise()
        main_controller.recordVideoRotation(player.sourceString, player.orientation)
    }

    // player control operation related
    function play() { player.play() }
    function pause() { player.pause() }
    function stop() { player.stop() }

    function togglePlay() {
        if (player.hasMedia && player.source != "") {
            player.playbackState == MediaPlayer.PlayingState ? pause() : play()
        } else {
            if (_settings.lastPlayedFile) {
                notifybar.show(dsTr("Play last movie played"))
                main_controller.playPath(_settings.lastPlayedFile)
            } else {
                var playlistFirst = playlist.getFirst()
                if (playlistFirst) {
                    main_controller.playPath(playlistFirst)
                } else {
                    openFile()
                }
            }
        }
    }

    function seekToLastPlayed() {
        // TODO: really should pause the video here, play it later in the timer.
        seek_to_last_watched_timer.start()

        playlist.hide()
        root.showControls()
    }

    // Player.position is not that reliable if there are multiple seek+
    // operations performed, thus we need lastForwardToPosition to record the
    // position last time we sought to. seek- operations don't need this.
    function forwardByDelta(delta) {
        if (!player.hasVideo) return

        var tempRate = player.playbackRate
        player.playbackRate = 1.0
        player.lastForwardToPosition = Math.min(Math.max(player.lastForwardToPosition, player.position) + delta, player.duration)
        player.seek(player.lastForwardToPosition)
        var percentage = Math.min(Math.floor(player.lastForwardToPosition / player.duration * 100), 100)
        var percentageInfo = player.duration != 0 ? " (%1%)".arg(percentage) : ""
        notifybar.show(dsTr("Forward") + ": " + UIUtils.formatTime(player.lastForwardToPosition) + percentageInfo)
        player.playbackRate = tempRate
    }

    function backwardByDelta(delta) {
        if (!player.hasVideo) return

        var tempRate = player.playbackRate
        player.playbackRate = 1.0
        player.seek(Math.max(player.position - delta), 1)
        var percentage = Math.min(Math.floor(player.position / (player.duration + 1) * 100), 100)
        var percentageInfo = player.duration != 0 ? " (%1%)".arg(percentage) : ""
        notifybar.show(dsTr("Rewind") + ": " + UIUtils.formatTime(player.position) + percentageInfo)
        player.playbackRate = tempRate
    }

    function forward() { forwardByDelta(Math.floor(config.playerForwardRewindStep * 1000)) }
    function backward() { backwardByDelta(Math.floor(config.playerForwardRewindStep * 1000)) }

    function speedUp() {
        var restoreInfo = config.hotkeysPlayRestoreSpeed+"" ? dsTr("(Press %1 to restore)").arg(config.hotkeysPlayRestoreSpeed) : ""
        player.playbackRate = Math.min(2.0, (player.playbackRate + 0.1).toFixed(1))
        notifybar.show(dsTr("Playback rate: ") + player.playbackRate + restoreInfo)
    }

    function slowDown() {
        var restoreInfo = config.hotkeysPlayRestoreSpeed+"" ? dsTr("(Press %1 to restore)").arg(config.hotkeysPlayRestoreSpeed) : ""
        player.playbackRate = Math.max(0.1, (player.playbackRate - 0.1).toFixed(1))
        notifybar.show(dsTr("Playback rate: ") + player.playbackRate + restoreInfo)
    }

    function restoreSpeed() {
        player.playbackRate = 1
        notifybar.show(dsTr("Playback rate: ") + player.playbackRate)
    }

    function increaseVolumeByDelta(delta) { setVolume(Math.min(player.volume + delta, 2.0)) }
    function decreaseVolumeByDelta(delta) { setVolume(Math.max(player.volume - delta, 0.0)) }

    function increaseVolume() { increaseVolumeByDelta(0.05) }
    function decreaseVolume() { decreaseVolumeByDelta(0.05) }

    function setVolume(volume) {
        config.playerVolume = volume
        config.playerMuted = false
        notifybar.show(dsTr("Volume: ") + Math.round(player.volume * 100) + "%")
    }

    function setMute(muted) {
        config.playerMuted = muted

        if (player.muted) {
            notifybar.show(dsTr("Muted"))
        } else {
            notifybar.show(dsTr("Volume: ") + Math.round(player.volume * 100) + "%")
        }
    }

    function toggleMute() {
        setMute(!player.muted)
    }

    function setSoundChannel(channelLayout) {
        switch(channelLayout) {
            case "auto": {
                player.channelLayout = MediaPlayer.ChannelLayoutAuto
                break
            }
            case "mono": {
                player.channelLayout = MediaPlayer.Mono
                break
            }
            case "left": {
                player.channelLayout = MediaPlayer.Left
                break
            }
            case "right": {
                player.channelLayout = MediaPlayer.Right
                break
            }
            case "stero": {
                player.channelLayout = MediaPlayer.Stero
                break
            }
        }
    }

    function openFile() { open_file_dialog.state = "open_video_file"; open_file_dialog.open() }
    function openDir() { open_folder_dialog.playFirst = true; open_folder_dialog.open() }
    function openUrl() { open_url_dialog.open() }
    function openDirForPlaylist() { open_folder_dialog.playFirst = false; open_folder_dialog.open() }
    function openFileForPlaylist() { open_file_dialog.state = "add_playlist_item"; open_file_dialog.open() }
    function openFileForSubtitle() { open_file_dialog.state = "open_subtitle_file"; open_file_dialog.open() }

    // To ensure that all the sources passed to player is a url other than a string.
    function playPath(path) {
        player.sourceString = path.trim()
        player.source = path[0] == "/" ? encodeURIComponent(path) : path
        player.play()
    }

    // playPaths is not quit perfect here, whether the play operation will
    // be performed is decided by the playFirst parameter.
    function playPaths(pathList, playFirst) {
        var paths = pathList

        if (paths.length > 0 && playFirst
            && config.playerCleanPlaylistOnOpenNewFile) {
            playlist.clear()
        }

        if (paths.length == 1 &&
            !_utils.urlIsDir(paths[0]) &&
            !_utils.fileIsValidVideo(paths[0]) &&
            !_utils.stringIsValidUri(paths[0]))
        {
            main_controller.notifyInvalidFile(paths[0])
        } else {
            main_controller.shouldPlayThefirst = playFirst
            _findVideoThreadManager.findSerie = config.playerAutoPlaySeries
            _findVideoThreadManager.getAllVideoFilesInPathList(paths)
        }
    }

    function playNextOf(file) {
        var next = null

        if (config.playerPlayOrderType == "ORDER_TYPE_RANDOM") {
            next = playlist.getRandom()
        } else if (config.playerPlayOrderType == "ORDER_TYPE_IN_ORDER") {
            next = playlist.getNextSource(file)
        } else if (config.playerPlayOrderType == "ORDER_TYPE_SINGLE") {
            next = null
        } else if (config.playerPlayOrderType == "ORDER_TYPE_SINGLE_CYCLE") {
            next = _settings.lastPlayedFile
        } else if (config.playerPlayOrderType == "ORDER_TYPE_PLAYLIST_CYCLE") {
            next = playlist.getNextSourceCycle(file)
        }

        next ? main_controller.playPath(next) : root.reset()
    }

    function playNext() {
        var next = null

        if (config.playerPlayOrderType == "ORDER_TYPE_RANDOM") {
            next = playlist.getRandom()
        } else {
            next = playlist.getNextSourceCycle(_settings.lastPlayedFile)
        }

        next ? main_controller.playPath(next) : root.reset()
    }
    function playPrevious() {
        player.resetPlayHistoryCursor = false
        main_controller.playPath(_database.playHistoryGetPrevious())
    }

    function importPlaylist() { open_file_dialog.state = "import_playlist"; open_file_dialog.open() }
    function exportPlaylist() { open_file_dialog.state = "export_playlist"; open_file_dialog.open() }
    function importPlaylistImpl(filename) {
        if(_utils.fileIsPlaylist(filename)) {
            playlist.clear()
            _database.importPlaylist(filename)
        } else {
            main_controller.notifyInvalidFile(filename)
        }
    }

    function exportPlaylistImpl(filename) {
        _database.exportPlaylist(filename)
    }

    function setSubtitleVerticalPosition(percentage) {
        config.subtitleVerticalPosition = Math.max(0, Math.min(1, percentage))
        player.subtitleVerticalPosition = Qt.binding(function () { return config.subtitleVerticalPosition })
    }

    function subtitleMoveUp() { setSubtitleVerticalPosition(config.subtitleVerticalPosition + 0.05)}
    function subtitleMoveDown() { setSubtitleVerticalPosition(config.subtitleVerticalPosition - 0.05)}

    function subtitleForward() {
        if (_subtitle_parser.file_name) {
            _subtitle_parser.delay = Math.max(program_constants.minSubtitleDelay * 1000,
                                              _subtitle_parser.delay - config.subtitleDelayStep * 1000)

            var delay = Math.abs((_subtitle_parser.delay / 1000).toFixed(1))
            if (_subtitle_parser.delay < 0) {
                notifybar.show(dsTr("Subtitle advanced %1 seconds").arg(delay))
            } else if (_subtitle_parser.delay > 0) {
                notifybar.show(dsTr("Subtitle delayed %1 seconds").arg(delay))
            }
        }
    }
    function subtitleBackward() {
        if (_subtitle_parser.file_name) {
            _subtitle_parser.delay = Math.min(program_constants.maxSubtitleDelay * 1000,
                                              _subtitle_parser.delay + config.subtitleDelayStep * 1000)

            var delay = Math.abs((_subtitle_parser.delay / 1000).toFixed(1))
            if (_subtitle_parser.delay < 0) {
                notifybar.show(dsTr("Subtitle advanced %1 seconds").arg(delay))
            } else if (_subtitle_parser.delay > 0) {
                notifybar.show(dsTr("Subtitle delayed %1 seconds").arg(delay))
            }
        }
    }

    function setSubtitle(subtitle) {
        if (subtitle && _utils.urlIsNativeFile(subtitle)) {
            _subtitle_parser.file_name = subtitle
        }
    }

    function doSingleClick() {
        if (config.othersLeftClick) {
            if (player.playbackState == MediaPlayer.PausedState) {
                play()
            } else if (player.playbackState == MediaPlayer.PlayingState) {
                pause()
            }
        }
    }

    function doDoubleClick(mouse) {
        hideControls()

        if (player.playbackState != MediaPlayer.StoppedState) {
            if (config.othersDoubleClick) {
                toggleFullscreen()
            }
        } else {
            openFile()
        }
    }

    Keys.onPressed: keys_responder.respondKey(event)
    Keys.onReleased: if(!event.isAutoRepeat) shortcuts_viewer.hide()

    onWheel: {
        if (config.othersWheel) {
            wheel.angleDelta.y > 0 ? increaseVolumeByDelta(wheel.angleDelta.y / 120 * 0.05)
                                    :decreaseVolumeByDelta(-wheel.angleDelta.y / 120 * 0.05)
            controlbar.emulateVolumeButtonHover()
        }
    }

    onPressed: {
        resizeEdge = getEdge(mouse)
        if (resizeEdge != resize_edge.resizeNone) {
            resize_visual.resizeEdge = resizeEdge
            resize_visual.show()
        } else {
            var pos = windowView.getCursorPos()

            windowLastX = windowView.x
            windowLastY = windowView.y
            dragStartX = pos.x
            dragStartY = pos.y
        }
    }

    onPositionChanged: {
        playlist.state = "inactive"
        windowView.setCursorVisible(true)
        mouse_area.cursorShape = Qt.ArrowCursor
        hide_controls_timer.restart()

        if (!pressed) {
            changeCursor(getEdge(mouse))

            if (mouseInControlsArea() && !playlist.expanded) {
                showControls()
            }
            else if (mouseInPlaylistTriggerArea) {
                controlbar.status != "minimal" && show_playlist_timer.restart()
            }
        }
        else {
            // prevent play or pause event from happening if we intend to move or resize the window
            shouldPerformClick = false
            if (resizeEdge != resize_edge.resizeNone) {
                if (player.hasVideo) {
                    resize_visual.minimumWidth = windowView.minimumWidth
                    resize_visual.minimumHeight = windowView.minimumHeight
                } else {
                    if (config.playerApplyLastClosedSize && _settings.lastWindowWidth < windowView.defaultWidth) {
                        var widthHeightScale = root.widthHeightScale
                        resize_visual.minimumWidth = _settings.lastWindowWidth
                        resize_visual.minimumHeight = _settings.lastWindowWidth / widthHeightScale
                    } else {
                        resize_visual.minimumWidth = windowView.defaultWidth
                        resize_visual.minimumHeight = windowView.defaultHeight
                    }
                }
                resize_visual.intelligentlyResize(mouse.x, mouse.y)
                _menu_controller.videoScale = ""
            }
            else if (windowView.getState() != Qt.WindowFullScreen){
                var pos = windowView.getCursorPos()
                windowView.setX(windowLastX + pos.x - dragStartX)
                windowView.setY(windowLastY + pos.y - dragStartY)
                windowLastX = windowView.x
                windowLastY = windowView.y
                dragStartX = pos.x
                dragStartY = pos.y
            }
        }
    }

    onReleased: {
        resizeEdge = resize_edge.resizeNone

        if (resize_visual.visible) {
            hasResized = true
            resize_visual.hide()
            // do the actual resize action
            windowView.setX(resize_visual.frameX)
            windowView.setY(resize_visual.frameY)
            setSizeForRootWindowWithWidth(resize_visual.frameWidth)
            root.actualScale = (windowView.width - program_constants.windowGlowRadius * 2) / player.resolution.width
        }
    }

    onClicked: {
        if (!shouldPerformClick) {
            shouldPerformClick = true
            return
        }

        if (playlist.expanded) {
            playlist.hide()
            return
        }

        if (mouse.button == Qt.RightButton) {
            main_controller.showMainMenu()
        } else if (mouse.button == Qt.LeftButton) {
            if (double_click_check_timer.running) {
                double_click_check_timer.stop()
                doDoubleClick()
            } else {
                double_click_check_timer.start()
            }
        }
    }

    DropArea {
        anchors.fill: parent

        onPositionChanged: {
            if (drag.x > parent.width - program_constants.playlistWidth) {
                playlist.show()
            }
        }

        onDropped: {
            shouldAutoPlayNextOnInvalidFile = false
            var dragInPlaylist = drag.x > parent.width - program_constants.playlistWidth

            var filePaths = []
            for (var i = 0; i < drop.urls.length; i++) {
                filePaths.push(decodeURIComponent(drop.urls[i]).replace("file://", ""))
            }

            if (filePaths.length == 1) {
                var file_path = filePaths[0]
                if (dragInPlaylist) {
                    main_controller.playPaths([file_path], false)
                } else {
                    if (_utils.urlIsDir(file_path)) {
                        main_controller.playPaths([file_path], true)
                    } else if (_utils.fileIsValidVideo(file_path)) {
                        main_controller.playPaths([file_path], true)
                    } else if (_utils.fileIsSubtitle(file_path)) {
                        main_controller.setSubtitle(file_path)
                    } else {
                        main_controller.notifyInvalidFile(file_path)
                    }
                }
            } else {
                main_controller.playPaths(filePaths, !dragInPlaylist)
            }
        }
    }
}
