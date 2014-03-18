import QtQuick 2.1
import QtQuick.Window 2.1

Window {
    id: toolTip
    width: tipText.width + 10
    height: tipText.height + 10
    flags: Qt.Popup | Qt.WindowStaysOnTopHint
    color: Qt.rgba(0, 0, 0, 0)

    function showTip(x, y, s){
        toolTip.x = x + 10
        toolTip.y = y + 10
        tipText.text = s        
        
        timeoutShow.restart()
    }

    function hideTip(){
        toolTip.hide()
        if(timeoutShow.running){
            timeoutShow.stop()
        }
    }

    Timer {
        id: timeoutShow
        interval: 500
        running: false
        repeat: false
        onTriggered: {
            toolTip.show()
        }
    }
    
    Rectangle {
        width: parent.width
        height: parent.height
        color: Qt.rgba(0, 0, 0, 0.9)
        radius: 4

        Text {
            id: tipText
            anchors.centerIn: parent
            font.pixelSize: 12
            color: "white"
        }
    }
}
