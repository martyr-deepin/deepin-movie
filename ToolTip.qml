import QtQuick 2.1
import QtQuick.Window 2.1

Window {
    id: toolTip
    width: tipText.width + 10
    height: tipText.height + 10
    flags: Qt.Popup | Qt.WindowStaysOnTopHint
    color: Qt.rgba(0, 0, 0, 0)

    property var window
    property var screenSize

    function showTip(s){
        tipText.text = s

        var cursorPosition = tooltip.window.getCursorPos()
        var screenSize = tooltip.screenSize
        toolTip.x = cursorPosition.x + 10
        toolTip.y = cursorPosition.y + 10
        if (toolTip.x + toolTip.width > screenSize.width){
            toolTip.x = screenSize.width - toolTip.width
        }
        // if (toolTip.y + toolTip.height > screenSize.height){
            // toolTip.y = screenSize.height - 10 - toolTip.height
        // }
        toolTip.show()
        toolTip.visible = true
        toolTip.raise()
        timeoutHide.restart()
    }

    function hideTip(){
        toolTip.hide()
        toolTip.visible = false
    }

    Timer {
        id: timeoutHide
        interval: 3000
        running: false
        repeat: false 
        onTriggered: {
            toolTip.hideTip()
        }
    }

    Rectangle {
        id: background
        width: parent.width
        height: parent.height
        color: Qt.rgba(0, 0, 0, 0.9)
        radius: 4

        Text {
            id: tipText
            anchors.centerIn: parent
            font.pixelSize: 12
            color: Qt.rgba(1, 1, 1, 0.7)
        }
    }
}
