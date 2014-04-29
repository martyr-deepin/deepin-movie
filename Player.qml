import QtQuick 2.1
import QtMultimedia 5.0
import DBus.Com.Deepin.Daemon.Power 1.0
 
Video {
    id: video
    autoPlay: true
    anchors.fill: parent
    transform: flip

    property alias subtitleContent: subtitle.text

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

    // property int screensaverInhibitId

    // ScreenSaver { id: dbus_screensaver }

    // onPlaying: {
    //     if (!dbus_screensaver.isInhibited) {
    //         screensaverInhibitId = dbus_screensaver.Inhibit("DMovie", "videos' playing")
    //     }
    // }
    onPaused: {
        // if (screensaverInhibitId) {
        //     dbus_screensaver.Uninhibit(screensaverInhibitId)
        // }
        pause_notify.notify()
    }
    // onStopped: {
    //     if (screensaverInhibitId) {
    //         dbus_screensaver.Uninhibit(screensaverInhibitId)
    //     }
    // }

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
        anchors.margins: 20
    }
}
