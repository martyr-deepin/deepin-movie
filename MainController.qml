import QtQuick 2.1
import QtMultimedia 5.0

MouseArea {
    id: mouse_area
    focus: true
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    anchors.fill: window

    property var window
    property int resizeEdge
    property int triggerThreshold: 10  // threshold for resizing the window

    property int dragStartX
    property int dragStartY
    property int windowLastX
    property int windowLastY

    property bool shouldPlayOrPause: true

    property int movieDuration: movieInfo.movie_duration

    ResizeEdge { id: resize_edge }
    MenuResponder { id: menu_responder }
    KeysResponder { id: keys_responder }

    Connections {
        target: movieInfo

        // Notice:
        // QWindow.setHeight probably will not set the actual height of the
        // window to the given value(automatically adjusted by the WM or something),
        // though QWindow.height is set to the given value actually,
        // so QWindow.height is not reliable here to get the actual height of the window,
        // fortunately, we can get it from the rootObject(here is root) of the QQuickView.

        /* onMovieWidthChanged: { */
        /*     windowView.setWidth(movieInfo.movie_width) */
        /*     windowView.moveToCenter() */
        /* } */

        onMovieHeightChanged: {
            windowView.setHeight(movieInfo.movie_height)
            windowView.moveToCenter()
        }

        onMovieSourceChanged: {
            var last_watched_pos = database.fetch_video_position(player.source)
            if (Math.abs(last_watched_pos - movieInfo.movie_duration) > 10) {
                seek_to_last_watched_timer.schedule(last_watched_pos)
            } else {
                play()
            }

            playlist.hide()
            titlebar.show()
            controlbar.show()
        }
    }

    Timer {
        id: seek_to_last_watched_timer
        interval: 500

        property int last_watched_pos

        function schedule(pos) {
            start()
            last_watched_pos = pos
        }

        onTriggered: {
            player.seek(last_watched_pos)
            play()
        }
    }

    Timer {
        id: show_playlist_timer
        interval: 3000

        onTriggered: {
            if (mouseX >= main_window.width - program_constants.playlistTriggerThreshold) {
                hideControls()
                playlist.state = "active"
                playlist.show()
            }
        }
    }

    Timer {
        id: hide_mouse_timer
        interval: 1000 * 10

        onTriggered: {
            if (player.playbackState == MediaPlayer.PlayingState) 
                mouse_area.cursorShape = Qt.BlankCursor
        }
    }

    property int clickCount: 0
    Timer {
        id: double_click_check_timer
        interval: 300

        onTriggered: {
            if (mouse_area.clickCount == 1) {
                mouse_area.doSingleClick()
            } else if (mouse_area.clickCount == 2) {
                mouse_area.doDoubleClick()
            }
            mouse_area.clickCount = 0
        }
    }

    // resize operation related
    function getEdge(mouse) {
        if (0 < mouse.x && mouse.x < triggerThreshold) {
            if (0 < mouse.y && mouse.y < triggerThreshold) {
                return resize_edge.resizeTopLeft
            } else if (window.height - triggerThreshold < mouse.y && mouse.y < window.height) {
                return resize_edge.resizeBottomLeft
            } else {
                return resize_edge.resizeLeft
            }
        } else if (window.width - triggerThreshold < mouse.x && mouse.x < window.width) {
            if (0 < mouse.y && mouse.y < triggerThreshold) {
                return resize_edge.resizeTopRight
            } else if (window.height - triggerThreshold < mouse.y && mouse.y < window.height) {
                return resize_edge.resizeBottomRight
            } else {
                return resize_edge.resizeRight
            }
        } else if (0 < mouse.y && mouse.y < triggerThreshold){
            return resize_edge.resizeTop
        } else if (window.height - triggerThreshold < mouse.y && mouse.y < window.height) {
            return resize_edge.resizeBottom
        } else {
            return resize_edge.resizeNone
        }
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

    function doSingleClick() {
        if (playlist.expanded) {
            playlist.hide()
            return
        }

        if (shouldPlayOrPause) {
            if (player.playbackState == MediaPlayer.PausedState) {
                play()
            } else if (player.playbackState == MediaPlayer.PlayingState) {
                pause()
            }
        } else {
            shouldPlayOrPause = true
        }
    }

    function doDoubleClick(mouse) {
        toggleFullscreen()
    }

    function close() {
        windowView.close()
    }

    function normalize() {
        root.state = "normal"
        _utils.enable_zone()
        windowView.showNormal()
    }

    function fullscreen() {
        root.state = "fullscreen"
        _utils.disable_zone()
        windowView.showFullScreen()
    }

    function maximize() {
        root.state = "normal"
        windowView.showMaximized()
    }

    function minimize() {
        root.state = "normal"
        windowView.doMinimized()
    }

    function toggleFullscreen() {
        windowView.getState() == Qt.WindowFullScreen ? normalize() : fullscreen()
    }

    function toggleMaximized() {
        windowView.getState() == Qt.WindowMaximized ? normalize() : maximize()
    }

    function rotateClockwise() { player.orientation -= 90 }
    function rotateAnticlockwise() { player.orientation += 90 }

    // player control operation related
    function play() { player.play() }
    function pause() { player.pause() }
    function stop() { player.stop() }

    function togglePlay() {
        if (player.hasVideo) {
            player.playbackState == MediaPlayer.PlayingState ? pause() : play()
        }
    }

    function forwardByDelta(delta) {
        player.seek(player.position + delta)
        notifybar.show("image/notify_forward.png", "快进至 " + formatTime(player.position))
    }

    function backwardByDelta(delta) {
        player.seek(player.position - delta)
        notifybar.show("image/notify_backward.png", "快退至 " + formatTime(player.position))
    }

    function forward() { forwardByDelta(5000) }
    function backward() { backwardByDelta(5000) }

    function increaseVolumeByDelta(delta) {
        player.volume = Math.min(player.volume + delta, 1.0)

        notifybar.show("image/notify_volume.png", "音量: " + Math.round(player.volume * 100) + "%")
    }

    function decreaseVolumeByDelta(delta) {
        player.volume = Math.max(player.volume - delta, 0.0)

        notifybar.show("image/notify_volume.png", "音量: " + Math.round(player.volume * 100) + "%")
    }

    function increaseVolume() { increaseVolumeByDelta(0.05) }
    function decreaseVolume() { decreaseVolumeByDelta(0.05) }

    function setVolume(volume) {
        config.playerVolume = volume
        notifybar.show("image/notify_volume.png", "音量: " + Math.round(player.volume * 100) + "%")
    }

    function setMute(muted) {
        config.playerMuted = muted
        config.save("Player", "muted", muted)

        if (player.muted) {
            notifybar.show("image/notify_volume.png", "静音")
        } else {
            notifybar.show("image/notify_volume.png", "音量: " + Math.round(player.volume * 100) + "%")
        }
    }

    function toggleMute() {
        setMute(!player.muted)
    }

    function openFile() { open_file_dialog.open() }
    function openDir() { open_folder_dialog.open() }

    function playNext() { movieInfo.movie_file = playlist.getNextSource() }
    function playPrevious() { movieInfo.movie_file = playlist.getPreviousSource() }

    Keys.onPressed: keys_responder.respondKey(event)

    onWheel: wheel.angleDelta.y > 0 ? increaseVolume(wheel.angleDelta.y / 120 * 0.05) : decreaseVolume(-wheel.angleDelta.y / 120 * 0.05)

    onPressed: {
        resizeEdge = getEdge(mouse)
        if (resizeEdge != resize_edge.resizeNone) {
            resize_visual.resizeEdge = resizeEdge
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

        mouse_area.cursorShape = Qt.ArrowCursor
        hide_mouse_timer.restart()

        if (!pressed) {
            changeCursor(getEdge(mouse))

            if (inRectCheck(mouse, Qt.rect(0, 0, main_window.width,
                                           program_constants.titlebarTriggerThreshold))) {
                showControls()
            } else if (inRectCheck(mouse, Qt.rect(0, main_window.height - controlbar.height,
                                                  main_window.width, program_constants.controlbarTriggerThreshold))) {
                showControls()
            }
        /* else if (!playlist.expanded && inRectCheck(mouse,  */
        /*     Qt.rect(main_window.width - program_constants.playlistTriggerThreshold, 0,  */
        /*     program_constants.playlistTriggerThreshold, main_window.height))) { */
        /*     show_playlist_timer.restart() */
        /* } */
        }
        else {
            // prevent play or pause event from happening if we intend to move or resize the window
            shouldPlayOrPause = false
            if (resizeEdge != resize_edge.resizeNone) {
                resize_visual.show()
                resize_visual.intelligentlyResize(windowView, mouse.x, mouse.y)
            }
            else {
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

        // do the actual resize action
        if (resize_visual.visible) {
            resize_visual.hide()
            windowView.setX(resize_visual.frameX)
            windowView.setY(resize_visual.frameY)
            windowView.setWidth(resize_visual.frameWidth)
            windowView.setHeight(resize_visual.frameHeight)
        }
    }

    onClicked: {
        if (mouse.button == Qt.RightButton) {
            _menu_controller.show_menu()
        } else {
            clickCount++
            if (!double_click_check_timer.running) {
                double_click_check_timer.start()
            }
        }
    }

    ResizeVisual {
        id: resize_visual

        // FixMe: we should also count the anchors.leftMaring here;
        frameY: windowView.y
        frameX: windowView.x
        frameWidth: window.width
        frameHeight: window.height
    }

    DropArea {
        anchors.fill: parent

        onDropped: {
            showControls()

            if (drop.hasUrls) {
                var file_path = drop.urls[0].substring(7)
                movieInfo.movie_file = decodeURIComponent(file_path)
            }
        }
    }
}