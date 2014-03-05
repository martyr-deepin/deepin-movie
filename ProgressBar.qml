import QtQuick 2.1

Item {
    id: progressbar
    width: 300
    height: 7

    property real percentage: 0.0
    
    onPercentageChanged: {
        print("percentage changed ", percentage)
    }

    signal mouseOver (var mouse)
    signal mouseExit ()
    
    MouseArea {
        hoverEnabled: true
        anchors.fill: parent

        onClicked: {
            pointer.x = mouse.x - pointer.width / 2
        }

        onPositionChanged: {
            progressbar.mouseOver(mouse)
        }

        onExited: {
            progressbar.mouseExit()
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
            width: progressbar.percentage * progressbar.width
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
            x: -(pointer.width / 2)
            opacity: 0 <= x && x <= background.width - width ? 1 : 0
            source: "image/progress_pointer.png"
            anchors.verticalCenter: parent.verticalCenter

            MouseArea {
                anchors.fill: parent

                drag.target: parent
                drag.axis: Drag.XAxis
                drag.minimumX: -(pointer.width / 2)
                drag.maximumX: background.width - (pointer.width / 2)
            }
            
            onXChanged: {
                progressbar.percentage = (x + pointer.width / 2) / Math.max(progressbar.width, 1)
            }
        }
    }
}
