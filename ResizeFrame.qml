import QtQuick 2.1
import QtQuick.Window 2.1
import QtGraphicalEffects 1.0

Window {
	id: win
	flags: Qt.Popup | Qt.FramelessWindowHint
    width: Screen.width
    height: Screen.height
	visible: false
	color: "transparent"
    
    property variant window
    
    property int framePadding: 10
    
    property real lastX: 0
    property real lastY: 0
    property real lastWindowX: 0
    property real lastWindowY: 0
    property real lastWindowWidth: 0
    property real lastWindowHeight: 0
    
    property alias rect: rect
    property alias frame: frame
    property string borderColor: "#AAAEC1D5"
    property bool proportionalResize: false
    property int proportionalWidth: 0
    property int proportionalHeight: 0
    
    ResizeConstant {
        id: constant
    }
    
    function show() {
        var pos = window.getCursorPos()
        lastX = pos.x
        lastY = pos.y
        
        lastWindowX = window.x
        lastWindowY = window.y
        lastWindowWidth = window.width
        lastWindowHeight = window.height
        
        rect.x = lastWindowX
        rect.y = lastWindowY
        rect.width = lastWindowWidth
        rect.height = lastWindowHeight
        win.visible = true
    }
    
    function hide() {
        window.x = rect.x
        window.y = rect.y
        window.width = rect.width
        window.height = rect.height
        
        win.visible = false
    }

    function resizeWidth(x, y) {
        var tempWidth = lastWindowWidth + x - lastX
        if (tempWidth >= window.minimumWidth) {
            rect.width = tempWidth
        }
    }
    
    function resizeHeight(x, y) {
        var tempHeight = lastWindowHeight + y - lastY
        if (tempHeight >= window.minimumHeight) {
            rect.height = tempHeight
        }
    }
    
    function moveresizeWidth(x, y) {
        var tempWidth = lastWindowWidth - x + lastX
        if (tempWidth >= window.minimumWidth) {
            rect.x = x
            rect.width = tempWidth
        } else {
            rect.width = window.minimumWidth
        }
    }
    
    function moveresizeHeight(x, y) {
        var tempHeight = lastWindowHeight - y + lastY
        if (tempHeight >= window.minimumHeight) {
            rect.y = y
            rect.height = tempHeight
        } else {
            rect.height = window.minimumHeight
        }
    }
    
    function adjustHeight() {
        rect.height = (rect.width - framePadding * 2) * proportionalHeight / proportionalWidth + framePadding * 2
    }
    
    function adjustHeightY() {
        var beforeHeight = rect.height
        rect.height = (rect.width - framePadding * 2) * proportionalHeight / proportionalWidth + framePadding * 2
        var afterHeight = rect.height
        
        rect.y -= afterHeight - beforeHeight + framePadding
    }
    
    function resize(edge, x, y) {
        var pos = window.getCursorPos()
        if (proportionalResize && edge == constant.edgeTopLeft) {
            moveresizeWidth(x, y)
            moveresizeHeight(x, y)
            
            adjustHeightY()
        } else if (proportionalResize && edge == constant.edgeTopRight) {
            resizeWidth(x, y)
            moveresizeHeight(x, y)
            
            adjustHeightY()
        } else if (proportionalResize && edge == constant.edgeBottomLeft) {
            resizeHeight(x, y)
            moveresizeWidth(x, y)
            
            adjustHeight()
        } else if (proportionalResize && edge == constant.edgeBottomRight) {
            resizeWidth(x, y)
            resizeHeight(x, y)
            
            adjustHeight()
        } else {
            if (edge == constant.edgeRight || edge == constant.edgeTopRight || edge == constant.edgeBottomRight) {
                resizeWidth(x, y)
            }
            
            if (edge == constant.edgeBottom || edge == constant.edgeBottomLeft || edge == constant.edgeBottomRight) {
                resizeHeight(x, y)
            }
            
            if (edge == constant.edgeLeft || edge == constant.edgeTopLeft || edge == constant.edgeBottomLeft) {
                moveresizeWidth(x, y)
            }
            
            if (edge == constant.edgeTop || edge == constant.edgeTopLeft || edge == constant.edgeTopRight) {
                moveresizeHeight(x, y)
            }
        }
    }
    
    Rectangle {
        id: rect
        color: "transparent"
        visible: parent.visible
        
        Rectangle {
            id: frame
            anchors.fill: parent
            visible: parent.visible
            color: "transparent"
            border.color: borderColor
            border.width: 2
            radius: 3
            anchors.margins: framePadding
        }
    }
}
