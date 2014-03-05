import QtQuick 2.1
import QtMultimedia 5.0

MouseArea {
    hoverEnabled: true
    anchors.fill: window

    property var window
    property int resizeEdge
    property int triggerThreshold: 10  // threshold for resizing the window

    property int startX
    property int startY

    property bool shouldPlayOrPause: true

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
        if (!pressed) {
            changeCursor(getEdge(mouse))
            if (!playlist.expanded &&
                0 < mouse.x &&
                mouse.x <= program_constants.playlistTriggerThreshold) {
                playlist.show()
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
        resize_visual.hide()
    }

    onClicked: {
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

    ResizeVisual {
        id: resize_visual

        frameX: windowView.x // FixMe: we should also count the anchors.leftMaring here;
        frameY: windowView.y
        frameWidth: window.width
        frameHeight: window.height

        onResizeDone: {
            windowView.setX(frameX)
            windowView.setY(frameY)
            windowView.setWidth(frameWidth)
            windowView.setHeight(frameHeight)
            window.width = frameWidth
            window.height = frameHeight
        }
    }

    DropArea {
        anchors.fill: parent

        onDropped: {
            if (drop.hasUrls) {
                var file_path = drop.urls[0].substring(7)
                movieInfo.movie_file = file_path
                play()
            }
        }
    }
}