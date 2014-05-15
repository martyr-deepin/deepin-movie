import QtQuick 2.1

Item {
    id: progressbar
    width: 300
    height: 7

    property real percentage: 0.0
    
    signal mouseOver (int mouseX)
    signal mouseDrag (int mouseX)
    signal mouseExit ()
    signal percentageSet(real percentage)
    
    MouseArea {
        hoverEnabled: true
        anchors.fill: parent

        onClicked: {
            progressbar.percentageSet(mouse.x / progressbar.width)
        }

        onPositionChanged: {
            progressbar.mouseOver(mouse.x)
        }

        onExited: {
            progressbar.mouseExit()
        }
    }

    onPercentageChanged: {
        if (!drag_area.drag.active) {
           pointer.x = progressbar.width * percentage - pointer.width / 2           
        }
    }

    Rectangle {
        id: background
        color: "#444a4a4a"
        anchors.fill: parent

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 1
            color: "#443c3c3c"
        }

        Rectangle {
            id: foreground
            anchors.left: parent.left
            anchors.top: parent.top
            height: parent.height
            width: pointer.x + pointer.width / 2
            color: "#007cc2"

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: 1
                color: "#04a4ff"
            }
        }

        Image {
            id: pointer
            opacity: 0 <= x && x <= background.width - width ? 1 : 0
            source: "image/progress_pointer.png"
            anchors.verticalCenter: parent.verticalCenter

            MouseArea {
                id: drag_area
                anchors.fill: parent

                drag.target: parent
                drag.axis: Drag.XAxis
                drag.minimumX: -(pointer.width / 2)
                drag.maximumX: background.width - (pointer.width / 2)

                onPositionChanged: {
                    progressbar.mouseDrag(pointer.x + pointer.width / 2)
                    progressbar.percentageSet((pointer.x + pointer.width / 2) / Math.max(progressbar.width, 1))
                }
            }
        }
    }
}
