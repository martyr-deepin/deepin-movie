import QtQuick 2.1
import QtMultimedia 5.0
import DBus.Com.Deepin.Daemon.Power 1.0
 
Video {
    id: video
    autoPlay: true
    transform: flip
    visible: playbackState != MediaPlayer.StoppedState

    property bool shouldShowNotify: true
    property alias subtitleContent: subtitle.text
    property alias subtitleFontSize: subtitle.fontSize
    property alias subtitleFontColo: subtitle.fontColor

    function flipHorizontal() {
        if (flip.axis.y == 1) {
            flip.axis.y == 0
        } else {
            if (flip.axis.x == 1) {
                flip.axis.x = 0
                video.orientation -= 180
            } else {
                flip.axis.y = 1
            }
        }
    }

    function flipVertical() {
        if (flip.axis.x == 1) {
            flip.axis.x == 0
        } else {
            if (flip.axis.y == 1) {
                flip.axis.y = 0
                video.orientation -= 180
            } else {
                flip.axis.x = 1
            }
        }
    }

    Rotation { 
        id: flip
        origin.x: width / 2
        origin.y: height / 2
        axis.x: 0
        axis.y: 0
        axis.z: 0
        angle: 180
    }

    onPlaying: pause_notify.visible = false

    onPaused: { if (shouldShowNotify) pause_notify.notify() }

    PauseNotify { 
        id: pause_notify
         visible: false
         anchors.centerIn: parent 
    }

    Subtitle { 
        id: subtitle

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        anchors.bottomMargin: 30
    }
}
