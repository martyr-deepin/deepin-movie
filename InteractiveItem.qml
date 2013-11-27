import QtQuick 2.1

Item {
    property variant targetItem
    
    Connections {
        target: targetItem
        
        onEntered: {
            inInteractiveArea = true
        }
        
        onExited: {
            inInteractiveArea = false
            window.exitMouseArea()
        }
    }
}
