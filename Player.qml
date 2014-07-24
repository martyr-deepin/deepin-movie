import QtQuick 2.1
import QtMultimedia 5.0
 
Video {
    id: video
    autoPlay: false
    transform: flip
    visible: playbackState != MediaPlayer.StoppedState

    property bool hasMedia: hasVideo || hasAudio

    property alias subtitleContent: subtitle.text
    property alias subtitleFontSize: subtitle.fontSize
    property alias subtitleFontColor: subtitle.fontColor
    property alias subtitleFontFamily: subtitle.fontFamily
    property alias subtitleFontBorderSize: subtitle.fontBorderSize
    property alias subtitleFontBorderColor: subtitle.fontBorderColor
    property alias subtitleShow: subtitle.visible
    property real subtitleVerticalPosition: 0.2
    property int subtitleDelay: 0

    property bool isPreview: false

    function flipHorizontal() {
        if (flip.axis.y == 1) {
            flip.axis.y = 0
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
            flip.axis.x = 0
        } else {
            if (flip.axis.y == 1) {
                flip.axis.y = 0
                video.orientation -= 180
            } else {
                flip.axis.x = 1
            }
        }
    }

    function rotateClockwise() { video.orientation -= 90 }
    function rotateAnticlockwise() { video.orientation += 90 }

    function resetRotationFlip() {
        video.orientation = 0
        flip.axis.x = 0
        flip.axis.y = 0
        flip.axis.z = 0
        flip.angle = 180
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

    // onPlaying: { pause_notify.visible = false }
    // onPaused: { if(!isPreview) pause_notify.visible = true }

    // PauseNotify { 
    //     id: pause_notify
    //      visible: false
    //      anchors.centerIn: parent 
    // }

    Subtitle { 
        id: subtitle

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        anchors.bottomMargin: parent.subtitleVerticalPosition * (parent.height - subtitle.height)
    }
}
