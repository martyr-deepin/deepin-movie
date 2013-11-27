import QtQuick 2.1

MouseArea {
    id: dragArea
    property variant window
    
    property real lastMouseX: 0
    property real lastMouseY: 0
    
    property bool isHover: false
    property bool isDoubleClick: false
    
    signal singleClicked
    
    onPressed: {
        isHover = false
        isDoubleClick = false
        
        lastMouseX = mouseX
        lastMouseY = mouseY
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
            window.x += mouseX - lastMouseX
            window.y += mouseY - lastMouseY
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