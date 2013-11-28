import QtQuick 2.1

MouseArea {
    id: resizeArea
    anchors.fill: parent
    hoverEnabled: true

    property variant window
    property variant frame
    
    property real lastX: 0
    property real lastY: 0
    property real lastWindowX: 0
    property real lastWindowY: 0
    property real lastWindowWidth: 0
    property real lastWindowHeight: 0
    
    property int edge: -1
    property int edgeTop: 1
    property int edgeTopLeft: 2
    property int edgeTopRight: 3
    property int edgeBottom: 4
    property int edgeBottomLeft: 5
    property int edgeBottomRight: 6
    property int edgeLeft: 7
    property int edgeRight: 8
    
    property bool isPress: false
    
    function resize(edge, x, y) {
        if (edge == edgeRight || edge == edgeTopRight || edge == edgeBottomRight) {
            window.width = lastWindowWidth + x - lastX
        }
        
        if (edge == edgeBottom || edge == edgeBottomLeft || edge == edgeBottomRight) {
            window.height = lastWindowHeight + y - lastY
        }
        
        if (edge == edgeLeft || edge == edgeTopLeft || edge == edgeBottomLeft) {
            var tempWidth = lastWindowWidth - x + lastX
            if (tempWidth > window.minimumWidth) {
                window.x = x
                window.width = tempWidth
            }
        }
        
        if (edge == edgeTop || edge == edgeTopLeft || edge == edgeTopRight) {
            var tempHeight = lastWindowHeight - y + lastY
            if (tempHeight > window.minimumHeight) {
                window.y = y
                window.height = tempHeight
            }
        }
    }
    
    function changeEdge() {
        edge = -1
        if (mouseX < frame.x) {
            if (mouseY < frame.y) {
                edge = edgeTopLeft
            } else if (mouseY > frame.y + frame.height) {
                edge = edgeBottomLeft
            } else {
                edge = edgeLeft
            }
        } else if (mouseX > frame.x + frame.width) {
            if (mouseY < frame.y) {
                edge = edgeTopRight
            } else if (mouseY > frame.y + frame.height) {
                edge = edgeBottomRight
            } else {
                edge = edgeRight
            }
        } else {
            if (mouseY < frame.y) {
                edge = edgeTop
            } else {
                edge = edgeBottom
            }
        }
    }
    
    function changeCursor() {
        if (mouseX < frame.x) {
            if (mouseY < frame.y) {
                resizeArea.cursorShape = Qt.SizeFDiagCursor
            } else if (mouseY > frame.y + frame.height) {
                resizeArea.cursorShape = Qt.SizeBDiagCursor
            } else {
                resizeArea.cursorShape = Qt.SizeHorCursor
            }
        } else if (mouseX > frame.x + frame.width) {
            if (mouseY < frame.y) {
                resizeArea.cursorShape = Qt.SizeBDiagCursor
            } else if (mouseY > frame.y + frame.height) {
                resizeArea.cursorShape = Qt.SizeFDiagCursor
            } else {
                resizeArea.cursorShape = Qt.SizeHorCursor
            }
        } else {
            if (mouseY < frame.y) {
                resizeArea.cursorShape = Qt.SizeVerCursor
            } else {
                resizeArea.cursorShape = Qt.SizeVerCursor
            }
        }
    }
    
    onPressed: {
        isPress = true
        
        var pos = window.getCursorPos()
        lastX = pos.x
        lastY = pos.y
        
        lastWindowX = window.x
        lastWindowY = window.y
        lastWindowWidth = window.width
        lastWindowHeight = window.height
        
        changeCursor()
        changeEdge()
    }
    
    onPositionChanged: {
        if (isPress && edge > 0) {
            var pos = window.getCursorPos()
            resize(edge, pos.x, pos.y)
        }
        
        if (!isPress) {
            changeCursor()
        }
    }
    
    onReleased: {
        isPress = false
    }
    
    onExited: {
        resizeArea.cursorShape = Qt.ArrowCursor
    }
}
