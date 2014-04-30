import QtQuick 2.1
import QtMultimedia 5.0

MouseArea {
    focus: true
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    anchors.fill: window

    property var window
    property int resizeEdge
    property int triggerThreshold: 10  // threshold for resizing the window

    property int startX
    property int startY

    property bool shouldPlayOrPause: true

    property int movieDuration: movieInfo.movie_duration

    Connections {
        target: movieInfo

        onMovieSourceChanged: {
            var last_watched_pos = database.fetch_video_position(player.source)
            if (Math.abs(last_watched_pos - movieInfo.movie_duration) < 10) {
                seek_to_last_watched_timer.schedule(last_watched_pos)
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
        }
    }

    Timer {
        id: show_playlist_timer
        interval: 30

        onTriggered: {
            if (mouseX <= program_constants.playlistTriggerThreshold) {
                hideControls()
                playlist.state = "active"
                playlist.show()
            }
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

    function close() {
        windowView.close()
    }

    function normalize() {
        root.state = "normal"
        windowView.showNormal()
    }

    function fullscreen() {
        root.state = "fullscreen"
        windowView.showFullScreen()
    }

    function maximize() {
        root.state = "normal"
        windowView.showMaximized()
    }

    function minimize() {
        root.state = "normal"
        windowView.showMaximized()
    }

    function toggleFullscreen() {
        windowView.getState() == Qt.WindowFullScreen ? normalize() : fullscreen()
    }

    function toggleMaximized() {
        windowView.getState() == Qt.WindowMaximized ? normalize() : maximize()
    }

    // player control operation related
    function play() {
        if (player.hasVideo) {
            player.play()
        }
    }

    function pause() {
        if (player.hasVideo) {
            player.pause()
        }
    }

    function togglePlay() {
        if (player.hasVideo) {
            player.playbackState == MediaPlayer.PlayingState ? pause() : play()
        }
    }

    function forward(delta) {
        player.seek(player.position + delta)
        notifybar.show("image/notify_forward.png", "快进至 " + formatTime(player.position))
    }

    function backward(delta) {
        player.seek(player.position - delta)
        notifybar.show("image/notify_backward.png", "快退至 " + formatTime(player.position))
    }

    function increaseVolume(delta) {
        player.volume = Math.min(player.volume + delta, 1.0)

        notifybar.show("image/notify_volume.png", "音量: " + Math.round(player.volume * 100) + "%")
    }

    function decreaseVolume(delta) {
        player.volume = Math.max(player.volume - delta, 0.0)

        notifybar.show("image/notify_volume.png", "音量: " + Math.round(player.volume * 100) + "%")
    }

    Keys.onSpacePressed: togglePlay()
    Keys.onLeftPressed: backward(5000)
    Keys.onRightPressed: forward(5000)
    Keys.onUpPressed: increaseVolume(0.05)
    Keys.onDownPressed: decreaseVolume(0.05)
    Keys.onEscapePressed: {
    }

    onEntered: {
        showControls()
    }

    onExited: {
    /* hideControls() */
    }

    onWheel: wheel.angleDelta.y > 0 ? increaseVolume(wheel.angleDelta.y / 120 * 0.05) : decreaseVolume(-wheel.angleDelta.y / 120 * 0.05)

    onPressed: {
        resizeEdge = getEdge(mouse)
        if (resizeEdge != resize_edge.resizeNone) {
            resize_visual.resizeEdge = resizeEdge
        } else {
            startX = mouse.x
            startY = mouse.y
        }
    }

    onPositionChanged: {
        showControls()

        if (!pressed) {
            changeCursor(getEdge(mouse))

            if (!playlist.expanded &&
                0 < mouse.x &&
                mouse.x <= program_constants.playlistTriggerThreshold) {
                show_playlist_timer.restart()
            }
        }
        else {
            // prevent play or pause event from happening if we intend to move or resize the window
            shouldPlayOrPause = false
            if (resizeEdge != resize_edge.resizeNone) {
                resize_visual.show()
                resize_visual.intelligentlyResize(windowView, mouse.x, mouse.y)
            }
            else {
                windowView.setX(windowView.x + mouse.x - startX)
                windowView.setY(windowView.y + mouse.y - startY)
            }
        }
    }

    onReleased: {
        resizeEdge = resize_edge.resizeNone

        // do the actual resize action
        resize_visual.hide()
        windowView.setX(resize_visual.frameX)
        windowView.setY(resize_visual.frameY)
        windowView.setWidth(resize_visual.frameWidth)
        windowView.setHeight(resize_visual.frameHeight)
        window.width = resize_visual.frameWidth
        window.height = resize_visual.frameHeight
    }

    onClicked: {
        if (playlist.expanded) {
            playlist.hide()
            return 
        }
        
        if (mouse.button == Qt.RightButton) {
            _menu_controller.show_menu()
        } else {
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
    }

    onDoubleClicked: {
        toggleFullscreen()
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
                movieInfo.movie_file = file_path
                play()
            }
        }
    }
}