import QtQuick 2.1

Item {
    id: root_rect
    width: 80
    height: 40
    
    property real percentage: 0

    Text {
        id: time_txt
        anchors.horizontalCenter: parent.horizontalCenter
        text: ""
        font.pixelSize: 20
        color: "#80DDDDDD"
        style: Text.Outline
        styleColor: "#FF333333"

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: {
                time_txt.text = Qt.formatDateTime(new Date(), "hh:mm")
            }
        }
    }

    Row {
        id: position_row
        spacing: 2
        anchors.top: time_txt.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        property int dotSize: 3

        Repeater {
            model: 10
            delegate: Rectangle {
                color: root_rect.percentage * 10 > index ? "#80DDDDDD" : "#80666666"
                width: position_row.dotSize
                height: position_row.dotSize
            }
        }
    }
}