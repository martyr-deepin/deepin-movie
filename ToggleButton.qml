import QtQuick 2.1

Image {
    property string imageName: ""
    property bool active: true
    source: imageName + (active ? "_active.png" : "_inactive.png")
    signal clicked

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        
        onClicked: {
            active = !active
            parent.clicked()
        }
    }
}
