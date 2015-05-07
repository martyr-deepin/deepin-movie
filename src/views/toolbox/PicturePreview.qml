import QtQuick 2.2
import QtQuick.Window 2.1
import Deepin.Widgets 1.0

DWindow {
    id: root
    width: 600
    height: 500
    color: "transparent"
    flags: Qt.FramelessWindowHint

    property alias picture: img.source

    DWindowFrame {
        frame.color: Qt.rgba(0, 0, 0, 0.5)
        anchors.fill: parent

        Item {
            clip: true
            anchors.fill: parent

            AnimatedImage {
                id: img
                width: implicitWidth * customScale
                height: implicitHeight * customScale

                property real customScale: 1

                onSourceChanged: {
                    x = Qt.binding(function() { return (parent.width - implicitWidth) / 2 })
                    y = Qt.binding(function() { return (parent.height - implicitHeight) / 2})
                }
            }

            MouseArea {
                anchors.fill: parent
                drag.target: (img.width > parent.width || img.height > parent.height) ? img : undefined
                drag.axis: (img.width > parent.width ? Drag.XAxis : 0) | (img.height > parent.height ? Drag.YAxis : 0)
                drag.minimumX: parent.width - img.width
                drag.maximumX: 0
                drag.minimumY: parent.height - img.height
                drag.maximumY: 0

                onWheel: {
                    var step = 0.1
                    var customScale_old = img.customScale
                    var xDelta = (wheel.x - img.x) / img.width * step * img.implicitWidth
                    var yDelta = (wheel.y - img.y) / img.height * step * img.implicitHeight

                    if (wheel.angleDelta.y > 0) {
                        img.customScale = Math.min(1.5, img.customScale + step)
                    } else {
                        img.customScale = Math.max(1.0, img.customScale - step)
                    }

                    if (img.customScale > customScale_old) {
                        img.x = img.x - xDelta
                        img.y = img.y - yDelta
                    } else if (img.customScale < customScale_old) {
                        img.x = img.x + xDelta
                        img.y = img.y + yDelta
                    }
                }
            }
        }

        DDragableArea {
            id: title_bar
            width: parent.width
            height: close_button.height
            window: root

            DTitleCloseButton {
                id: close_button
                anchors.right: parent.right

                onClicked: root.close()
            }
        }
    }
}