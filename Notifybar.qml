import QtQuick 2.1

Rectangle {
    id: notify
    property string notifyIcon: ""
    property string notifyText: ""
    opacity: 0
    visible: true
    
    function show(icon, text) {
        notifyIcon = icon
        notifyText = text
        opacity = 1
        showingNotifyAnimation.restart()
        
        hidingNotifyTimer.restart()
    }
    
    Row {
        spacing: 5
        
        Image {
            anchors.verticalCenter: parent.verticalCenter
            source: notifyIcon
            visible: notify.visible
        }
        
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: notifyText
            font.pixelSize: 17
            color: "#80e6ff"
            style: Text.Outline
            styleColor: Qt.color(0, 0, 0, 0.4)
            visible: notify.visible
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
