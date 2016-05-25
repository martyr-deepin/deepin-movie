import QtQuick 2.1

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
        color: Qt.rgba(1, 1, 1, 0.85)
        style: Text.Outline
        styleColor: "black"
    }
    
    MouseArea {
        id: button
        anchors.fill: parent
        hoverEnabled: true
        
        onPressed: {parent.pressed()}
    }
}
