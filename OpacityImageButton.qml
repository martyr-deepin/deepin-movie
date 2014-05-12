import QtQuick 2.1

MouseArea {
    state: "normal"
    hoverEnabled: true
    width: image.implicitWidth
    height: image.implicitHeight
    property alias imageName: image.source

    states: [
        State { name: "normal"; PropertyChanges { target: image; opacity: 0.6 } },
        State { name: "hover"; PropertyChanges { target: image; opacity: 1.0 } },
        State { name: "press"; PropertyChanges { target: image; opacity: 0.4 } }
    ]

    Image { id: image }

    onEntered: {
        state = "hover"
    }
    onExited: {
        state = "normal"
    }
    onPressed: { state = "press" }
    onReleased: { state = "hover" }
}