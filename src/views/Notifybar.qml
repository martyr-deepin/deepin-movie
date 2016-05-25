import QtQuick 2.1
import QtGraphicalEffects 1.0

Item {
    id: notify
    width: 300
    height: background.height
    visible: false

    property alias text: txt.text

    function showPermanently(text) {
        visible = true
        txt.text = text
        hide_notify_timer.stop()
    }

    function show(text) {
        showPermanently(text)
        hide_notify_timer.restart()
    }

    function hide() {
        visible = false
    }

    Item {
        id: background
        width: notify.width
        height: txt.implicitHeight + glow.radius * 2

        Text {
            id: txt
            width: parent.width - glow.radius * 2
            font.pixelSize: 16
            color: "#4fbbff"
            wrapMode: Text.Wrap
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
