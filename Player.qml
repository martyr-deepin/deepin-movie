import QtQuick 2.1
import QtMultimedia 5.0
import DBus.Com.Deepin.Daemon.Power 1.0
 
Video {
    id: video
    autoPlay: true
    anchors.fill: parent

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

    PauseNotify { id: pause_notify; visible: false; anchors.centerIn: parent }
}
