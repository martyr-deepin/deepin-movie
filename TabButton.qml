import QtQuick 2.1
import QtGraphicalEffects 1.0

Rectangle {
    id: textButton
    width: label.width + 20
    height: parent.height
    smooth: true
    radius: 2
    color: Qt.rgba(1, 0, 0, 0)
    
    property int tabIndex: 0
    property alias text: label.text
    
    signal pressed

    Text {
        id: label
        anchors.centerIn: parent
        color: "white"
    }
    
    InteractiveArea {
        anchors.fill: parent
        hoverEnabled: true
        
        onPressed: {parent.pressed()}
    }
}
