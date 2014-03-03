import QtQuick 2.1

Image {
    property string imageName: ""
    source: imageName + "_normal.png"
    signal clicked

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        
        onEntered: {
            parent.source = imageName + "_hover.png"
        }
        onExited: {
            parent.source = imageName + "_normal.png"
        }
        onPressed: {parent.source = imageName + "_press.png"}
        onReleased: {parent.source = imageName + "_hover.png"}
        onClicked: {parent.clicked()}
    }
}
