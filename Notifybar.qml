import QtQuick 2.1
import QtGraphicalEffects 1.0

Rectangle {
    id: notify
    property string notifyIcon: ""
    property string notifyText: ""
    opacity: 0
    visible: true
    
    property alias textGlow: textGlow
    
    function show(icon, text) {
        notifyIcon = icon
        notifyText = text
        opacity = 1
        showingNotifyAnimation.restart()
        
        hidingNotifyTimer.restart()
    }
    
    Image {
        id: notifyImage
        anchors.verticalCenter: parent.verticalCenter
        source: notifyIcon
        visible: notify.visible
    }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: notifyImage.right
        anchors.leftMargin: 5
        
        Text {
            id: text
            anchors.verticalCenter: parent.verticalCenter
            text: notifyText
            font.pixelSize: 17
            color: "#80e6ff"
            /* color: "#000" */
        }
        
        Glow {
            id: textGlow
            anchors.fill: text
            source: text
            radius: 4
            samples: 10
            color: "#000"
            /* color: "#F00" */
        }    
        
    }

    Timer {
        id: hidingNotifyTimer
        interval: 2000
        repeat: false
        onTriggered: {
            hidingNotifyAnimation.restart()
        }
    }
    
    ParallelAnimation{
        id: showingNotifyAnimation
        alwaysRunToEnd: true
        
        PropertyAnimation {
            target: notify
            property: "opacity"
            to: 1
            duration: 100
            easing.type: Easing.OutQuint
        }
    }    

    ParallelAnimation{
        id: hidingNotifyAnimation
        alwaysRunToEnd: true
        
        PropertyAnimation {
            target: notify
            property: "opacity"
            to: 0
            duration: 100
            easing.type: Easing.OutQuint
        }
    }    
}
