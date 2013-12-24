import QtQuick 2.1

Rectangle {
    property variant target
    
    anchors.right: target.right
    anchors.bottom: target.bottom
    anchors.rightMargin: 2
    anchors.bottomMargin: 2
    width: anchors.rightMargin + dragbarImage.width
    height: anchors.bottomMargin + dragbarImage.height
    color: "transparent"
    
    Image {
        id: dragbarImage
        source: "image/dragbar.png"
        visible: showBottomPanel && windowView.getState() != Qt.WindowFullScreen
    }
    
    MouseArea {
        id: dragbarArea
        anchors.fill: parent
        hoverEnabled: true
        
        ResizeConstant {
            id: constant
        }
        
        onEntered: {
            if (windowView.getState() != Qt.WindowFullScreen) {
                dragbarArea.cursorShape = Qt.SizeFDiagCursor
            }
        }
        
        onExited: {
            if (windowView.getState() != Qt.WindowFullScreen) {
                dragbarArea.cursorShape = Qt.ArrowCursor
            }
            
            hidingTimer.restart()
        }
        
        onPressed: {
            resizeFrame.show()
        }
        
        onPositionChanged: {
            if (pressed) {
                var pos = windowView.getCursorPos()
                resizeFrame.resize(constant.edgeBottomRight, pos.x, pos.y)
            }
            
            hidingTimer.stop()
        }
        
        onReleased: {
            resizeFrame.hide()
            dragbarArea.cursorShape = Qt.ArrowCursor
        }
        
        InteractiveItem {
            targetItem: parent
        }
    }
}