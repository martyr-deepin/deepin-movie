import QtQuick 2.1
import QtMultimedia 5.0
import QtGraphicalEffects 1.0

ToggleButton {
    id: volumeButton
    
    imageName: "image/player_volume"
    
    property alias volumebar: volumebar
    property alias volumeMiddle: volumeMiddle
    
    property double volume: 1.0
    property int hideWidth: 0.0
    property int showWidth: 58.0
    property int hidePosition: hideWidth
    property int showPosition: volume * showWidth
    
    signal inVolumebar
    signal changeVolume
    signal clickMute
    
    Connections {
        target: volumeButton
        onClicked: {
            volumebar.visible = volumeButton.active
            volumeButton.clickMute(volumeButton.active)
        }
    }
    
    InteractiveArea {
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        
        onPositionChanged: {
            volumeButton.inVolumebar()
            
            if (volumeButton.active) {
                volumebar.visible = true
            }
            
            hideVolumebarTimer.start()
        }
        
        onClicked: {
            mouse.accepted = false
        }
    }
    
    Image {
        id: volumebar
        source: "image/volume_background.png"
        anchors.left: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 8
        visible: false
        
        Image {
            id: volumeLeft
            anchors.left: parent.left
            source: "image/volume_foreground_left.png"
        }
        
        Image {
            id: volumeMiddle
            anchors.left: volumeLeft.right
            source: "image/volume_foreground_middle.png"
            fillMode: Image.TileHorizontally
            width: showPosition
        }
        
        Image {
            id: volumeRight
            anchors.left: volumeMiddle.right
            source: "image/volume_foreground_right.png"
        }
        
        Image {
            id: volumePointer
            anchors.right: volumeRight.right
            source: "image/volume_pointer.png"
        }
    }
    
    InteractiveArea {
        id: volumebarArea
        anchors.top: volumebar.top
        anchors.bottom: volumebar.bottom
        anchors.left: volumebar.left
        anchors.right: volumebar.right
        hoverEnabled: true

        onClicked: {
            volume = mouseX / showWidth
            volumeMiddle.width = showPosition
            volumeButton.changeVolume()
        }
        
        onPositionChanged: {
            volumeButton.inVolumebar()
            
            volumebar.width = showWidth
            volumeMiddle.width = showPosition
            
            hideVolumebarTimer.stop()
        }
        
        onExited: {
            hideVolumebarTimer.start()
        }
        
        onWheel: {
            volume = Math.max(Math.min(volume + (wheel.angleDelta.y / 120 * 0.05), 1.0), 0.0)
            volumeMiddle.width = showPosition
            volumeButton.changeVolume()
        }
    }

    Timer {
        id: hideVolumebarTimer
        interval: 2000
        repeat: false
        onTriggered: {
            volumebar.visible = false
        }
    }
}
