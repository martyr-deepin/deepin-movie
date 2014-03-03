import QtQuick 2.1

MouseArea {
    hoverEnabled: true
    anchors.fill: window

    property var window
    property int resizeEdge
    property int triggerThreshold: 5  // threshold for resizing the window

    property int startX
    property int startY

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
        }
        else {
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
}