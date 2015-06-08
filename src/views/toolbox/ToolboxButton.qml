import QtQuick 2.2

MouseArea {
    id: root
    state: "grid"
    hoverEnabled: true

    property url normalImage
    property url hoverImage
    property url pressedImage

    property alias text: txt.text

    states: [
        State {
            name: "grid"
            PropertyChanges {
                target: root
                width: 60
                height: 60
            }
            PropertyChanges {
                target: img
                anchors {
                    top: img.parent.top
                    topMargin: 8
                    horizontalCenter: img.parent.horizontalCenter
                    verticalCenter: undefined
                }
            }
            PropertyChanges {
                target: txt
                anchors {
                    top: img.bottom
                    topMargin: 4
                    left: undefined
                    leftMargin: 0
                    horizontalCenter: txt.parent.horizontalCenter
                    verticalCenter: undefined
                }
            }
        },
        State {
            name: "list"
            PropertyChanges {
                target: root
                width: 130
                height: 24
            }
            PropertyChanges {
                target: img
                anchors {
                    top: undefined
                    topMargin: 0
                    horizontalCenter: undefined
                    verticalCenter: img.parent.verticalCenter
                }
            }
            PropertyChanges {
                target: txt
                anchors {
                    top: undefined
                    topMargin: 0
                    left: txt.parent.left
                    leftMargin: 32
                    horizontalCenter: undefined
                    verticalCenter: txt.parent.verticalCenter
                }
            }
        }
    ]

    Image { id: img; source: normalImage }

    Text {
        id: txt
        color: "white"
        font.pixelSize: 12
    }

    onEntered: img.source = hoverImage
    onExited: img.source = normalImage
    onPressed: img.source = pressedImage
    onReleased: {
        if (containsMouse) {
            img.source = hoverImage
        } else {
            img.source = normalImage
        }
    }
}