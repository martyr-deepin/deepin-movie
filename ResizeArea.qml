import QtQuick 2.1
import QtQuick.Window 2.1

MouseArea {
    id: resizeArea
    anchors.fill: parent
    hoverEnabled: true

    property variant window
    property variant frame
    property int resizeOffset: 0
    property bool proportionalResize: false
    property int framePadding: 10
    
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
    
    ResizeFrame {
        id: resizeFrame
    }
    
    function changeEdge() {
        if (mouseX < frame.x + resizeOffset) {
            if (mouseY < frame.y + resizeOffset) {
                edge = edgeTopLeft
            } else if (mouseY > frame.y + frame.height - resizeOffset) {
                edge = edgeBottomLeft
            } else {
                edge = edgeLeft
            }
        } else if (mouseX > frame.x + frame.width - resizeOffset) {
            if (mouseY < frame.y + resizeOffset) {
                edge = edgeTopRight
            } else if (mouseY > frame.y + frame.height - resizeOffset) {
                edge = edgeBottomRight
            } else {
                edge = edgeRight
            }
        } else {
            if (mouseY < frame.y + resizeOffset) {
                edge = edgeTop
            } else if (mouseY > frame.y + frame.height - resizeOffset) {
                edge = edgeBottom
            } else {
                edge = -1
            }
        }
    }
    
    function changeCursor() {
        if (mouseX < frame.x + resizeOffset) {
            if (mouseY < frame.y + resizeOffset) {
                resizeArea.cursorShape = Qt.SizeFDiagCursor
            } else if (mouseY > frame.y + frame.height - resizeOffset) {
                resizeArea.cursorShape = Qt.SizeBDiagCursor
            } else {
                resizeArea.cursorShape = Qt.SizeHorCursor
            } 
        } else if (mouseX > frame.x + frame.width - resizeOffset) {
            if (mouseY < frame.y + resizeOffset) {
                resizeArea.cursorShape = Qt.SizeBDiagCursor
            } else if (mouseY > frame.y + frame.height - resizeOffset) {
                resizeArea.cursorShape = Qt.SizeFDiagCursor
            } else {
                resizeArea.cursorShape = Qt.SizeHorCursor
            } 
        } else {
            if (mouseY < frame.y + resizeOffset) {
                resizeArea.cursorShape = Qt.SizeVerCursor
            } else if (mouseY > frame.y + frame.height - resizeOffset) {
                resizeArea.cursorShape = Qt.SizeVerCursor
            } else {
                resizeArea.cursorShape = Qt.ArrowCursor
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
        
        resizeFrame.show()
    }
    
    onPositionChanged: {
        if (isPress && edge > 0) {
            var pos = window.getCursorPos()
            resizeFrame.resize(edge, pos.x, pos.y)
        }
        
        changeCursor()
    }
    
    onReleased: {
        isPress = false
        
        changeCursor()

        window.x = resizeFrame.rect.x
        window.y = resizeFrame.rect.y
        window.width = resizeFrame.rect.width
        window.height = resizeFrame.rect.height
        
        resizeFrame.visible = false
    }
}
