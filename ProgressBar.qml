import QtQuick 2.1

Item {
    id: progressbar
    height: 7
    
    property real percentage: 0
    
    signal mouseOver (var mouse)
    signal mouseExit (var mouse)

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
            width: progressbar.percentage * (progressbar.width - pointer.width / 2)
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
            source: "image/progress_pointer.png"
            anchors.verticalCenter: parent.verticalCenter

            MouseArea {
                anchors.fill: parent

                drag.target: parent
                drag.axis: Drag.XAxis
                drag.minimumX: 0
                drag.maximumX: background.width - width
            }

            onXChanged: {
                progressbar.percentage = x / (background.width - width)
            }
        }
        
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
                progressbar.mouseExit(mouse)
            }
        }
    }
}
