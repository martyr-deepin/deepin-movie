import QtQuick 2.1

Image {
    property string imageName: ""
    property bool active: true
    source: imageName + (active ? "_active.png" : "_inactive.png")
    signal clicked
    signal entered
    signal exited

    MouseArea {
        id: mouseArea
        hoverEnabled: true
        anchors.fill: parent
        
        onClicked: {
            active = !active
            parent.clicked()
        }

        onEntered: {
            parent.entered()
        }

        onExited: {
            parent.exited()
        }
    }
}
