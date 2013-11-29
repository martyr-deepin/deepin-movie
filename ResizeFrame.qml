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
    
    property alias rect: rect
    property alias frame: frame
    property string borderColor: "#AAAEC1D5"
    
    function show() {
        rect.x = lastWindowX
        rect.y = lastWindowY
        rect.width = lastWindowWidth
        rect.height = lastWindowHeight
        win.visible = true
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
        rect.height = (rect.width - framePadding * 2) * movie_info["video_height"] / movie_info["video_width"] + framePadding * 2
    }
    
    function adjustHeightY() {
        var beforeHeight = rect.height
        rect.height = (rect.width - framePadding * 2) * movie_info["video_height"] / movie_info["video_width"] + framePadding * 2
        var afterHeight = rect.height
        
        rect.y -= afterHeight - beforeHeight + framePadding
    }
    
    function resize(edge, x, y) {
        if (proportionalResize && edge == edgeTopLeft) {
            moveresizeWidth(x, y)
            moveresizeHeight(x, y)
            
            adjustHeightY()
        } else if (proportionalResize && edge == edgeTopRight) {
            resizeWidth(x, y)
            moveresizeHeight(x, y)
            
            adjustHeightY()
        } else if (proportionalResize && edge == edgeBottomLeft) {
            resizeHeight(x, y)
            moveresizeWidth(x, y)
            
            adjustHeight()
        } else if (proportionalResize && edge == edgeBottomRight) {
            resizeWidth(x, y)
            resizeHeight(x, y)
            
            adjustHeight()
        } else {
            if (edge == edgeRight || edge == edgeTopRight || edge == edgeBottomRight) {
                resizeWidth(x, y)
            }
            
            if (edge == edgeBottom || edge == edgeBottomLeft || edge == edgeBottomRight) {
                resizeHeight(x, y)
            }
            
            if (edge == edgeLeft || edge == edgeTopLeft || edge == edgeBottomLeft) {
                moveresizeWidth(x, y)
            }
            
            if (edge == edgeTop || edge == edgeTopLeft || edge == edgeTopRight) {
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
