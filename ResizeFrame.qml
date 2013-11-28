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

    function resize(edge, x, y) {
        if (edge == edgeRight || edge == edgeTopRight || edge == edgeBottomRight) {
            tempWidth = lastWindowWidth + x - lastX
            if (tempWidth >= window.minimumWidth) {
                rect.width = tempWidth
            }
        }
        
        if (edge == edgeBottom || edge == edgeBottomLeft || edge == edgeBottomRight) {
            tempHeight = lastWindowHeight + y - lastY
            if (tempHeight >= window.minimumHeight) {
                rect.height = tempHeight
            }
        }
        
        if (edge == edgeLeft || edge == edgeTopLeft || edge == edgeBottomLeft) {
            var tempWidth = lastWindowWidth - x + lastX
            if (tempWidth >= window.minimumWidth) {
                rect.x = x
                rect.width = tempWidth
            } else {
                rect.width = window.minimumWidth
            }
        }
        
        if (edge == edgeTop || edge == edgeTopLeft || edge == edgeTopRight) {
            var tempHeight = lastWindowHeight - y + lastY
            if (tempHeight >= window.minimumHeight) {
                rect.y = y
                rect.height = tempHeight
            } else {
                rect.height = window.minimumHeight
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
            anchors.margins: 10
        }
    }
}
