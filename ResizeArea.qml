import QtQuick 2.1
import QtQuick.Window 2.1

MouseArea {
    id: resizeArea
    anchors.fill: parent
    hoverEnabled: true

    property variant window
    property variant frame
    
    property int edge: -1
    
    ResizeConstant {
        id: constant
    }
    
    function changeEdge() {
        if (mouseX < frame.x) {
            if (mouseY < frame.y) {
                edge = constant.edgeTopLeft
            } else if (mouseY > frame.y + frame.height) {
                edge = constant.edgeBottomLeft
            } else {
                edge = constant.edgeLeft
            }
        } else if (mouseX > frame.x + frame.width) {
            if (mouseY < frame.y) {
                edge = constant.edgeTopRight
            } else if (mouseY > frame.y + frame.height) {
                edge = constant.edgeBottomRight
            } else {
                edge = constant.edgeRight
            }
        } else {
            if (mouseY < frame.y) {
                edge = constant.edgeTop
            } else if (mouseY > frame.y + frame.height) {
                edge = constant.edgeBottom
            } else {
                edge = -1
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
            } else if (mouseY > frame.y + frame.height) {
                resizeArea.cursorShape = Qt.SizeVerCursor
            } else {
                resizeArea.cursorShape = Qt.ArrowCursor
            }
        }
    }
    
    onPressed: {
        changeCursor()
        changeEdge()
        resizeFrame.show()
    }
    
    onPositionChanged: {
        if (pressed && edge > 0) {
            var pos = window.getCursorPos()
            resizeFrame.resize(edge, pos.x, pos.y)
        }
        
        changeCursor()
    }
    
    onReleased: {
        changeCursor()
        resizeFrame.hide()
    }
}
