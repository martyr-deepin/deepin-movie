import QtQuick 2.1
import QtGraphicalEffects 1.0

Item {
    id: notify
    width: txt.width
    height: txt.height
    visible: false
    
    function show(text) {
        visible = true
        txt.text = text
        
        hide_notify_timer.restart()
    }

    Item {
        id: background
        width: txt.implicitWidth + glow.radius * 2
        height: txt.implicitHeight + glow.radius * 2

        Text {
            id: txt
            font.pixelSize: 16
            color: "#4fbbff"
            style: Text.Outline
            styleColor: Qt.rgba(0, 0, 0, 0.2)

            anchors.centerIn: parent
        }
    }

    Glow {
        id: glow
        anchors.fill: background
        radius: 8
        spread: 0.2
        samples: 16
        color: "black"
        source: background
    }
    
    Timer {
        id: hide_notify_timer
        interval: 2000
        repeat: false
        onTriggered: { notify.visible = false }
    }   
}
