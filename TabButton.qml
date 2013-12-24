import QtQuick 2.1
import QtGraphicalEffects 1.0

Rectangle {
    id: textButton
    width: label.width
    height: parent.height
    smooth: true
    color: Qt.rgba(1, 0, 0, 0)
    
    property int tabIndex: 0
    property alias text: label.text
    
    signal pressed

    Text {
        id: label
		font { pixelSize: 15 }
        anchors.centerIn: parent
        color: "white"
        style: Text.Outline
        styleColor: "black"
    }
    
    MouseArea {
        id: button
        anchors.fill: parent
        hoverEnabled: true
        
        onPressed: {parent.pressed()}

        InteractiveItem {
            targetItem: parent
        }
    }
}
