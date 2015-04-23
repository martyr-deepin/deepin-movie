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
        width: root.width
        height: root.height
        frame.color: Qt.rgba(0, 0, 0, 0.5)

        Item {
            width: parent.width
            height: parent.height
            clip: true

            AnimatedImage {
                id: img

                property real customScale: 1

                onCustomScaleChanged: {
                    width = width * customScale
                    height = height * customScale
                }

                onImplicitWidthChanged: {
                    height = parent.height
                    width = height * implicitWidth / implicitHeight
                    x = (parent.width - width) / 2
                    y = (parent.height - height) / 2
                }
            }

            MouseArea {
                anchors.fill: parent
                drag.target: (img.width > parent.width || img.height > parent.height) ? img : undefined
                drag.axis: (img.width > parent.width ? Drag.XAxis : 0) | (img.height > parent.height ? Drag.YAxis : 0)
                drag.threshold: 1
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