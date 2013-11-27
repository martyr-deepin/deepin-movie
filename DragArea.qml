import QtQuick 2.1

MouseArea {
    id: dragArea
    property variant window
    
    property real lastMouseX: 0
    property real lastMouseY: 0
    
    property bool isHover: false
    property bool isDoubleClick: false
    
    property real lastX: 0
    property real lastY: 0
    property real lastWindowX: 0
    property real lastWindowY: 0
    
    signal singleClicked
    
    onPressed: {
        isHover = false
        isDoubleClick = false
        
        lastMouseX = mouseX
        lastMouseY = mouseY
        
        var pos = xobject.get_pointer_coordiante()
        lastX = pos[0]
        lastY = pos[1]
        
        lastWindowX = window.x
        lastWindowY = window.y
    }
    
    onClicked: {
        if (!isHover) {
            clickTimer.restart()
        }
    }
    
    onDoubleClicked: {
        isDoubleClick = true
    }
    
    onPositionChanged: {
        isHover = true
        
        if (pressedButtons == Qt.LeftButton) {
            var pos = xobject.get_pointer_coordiante()
            window.x = lastWindowX + pos[0] - lastX
            window.y = lastWindowY + pos[1] - lastY
            
            /* window.x += mouseX - lastMouseX */
            /* window.y += mouseY - lastMouseY */
        }
    }
    
    Timer {
        id: clickTimer
        interval: 200
        repeat: false
        onTriggered: {
            if (!dragArea.isDoubleClick) {
                singleClicked()
            }
        }
    }
}