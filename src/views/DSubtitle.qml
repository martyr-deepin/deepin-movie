import QtQuick 2.1
import QtGraphicalEffects 1.0

Item {
    id: item
    width: 1000
    height: txt.implicitHeight

    property alias text: txt.text
    property alias fontColor: txt.color
    property alias fontSize: txt.font.pixelSize
    property alias fontFamily: txt.font.family
    property alias fontBorderColor: glow.color
    property alias fontBorderSize: glow.radius

    Text {
        id: txt
        width: parent.width
        color: "white"
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        maximumLineCount: 10
        font.pixelSize: 28
    }

    Glow {
        id: glow
        anchors.fill: parent
        spread: 1
        samples: 16
        source: txt
        visible: radius != 0
    }
}