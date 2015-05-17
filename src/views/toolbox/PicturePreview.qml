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

                function moveHCenter() {
                    x = (parent.width - width) / 2
                }

                function moveVCenter() {
                    y = (parent.height - height) / 2
                }

                onCustomScaleChanged: {
                    width = implicitWidth * customScale
                    height = implicitHeight * customScale
                }

                onImplicitWidthChanged: {
                    height = Math.min(parent.height, implicitWidth)
                    width = height * implicitWidth / implicitHeight
                    customScale = width / implicitWidth

                    img.moveHCenter()
                    img.moveVCenter()
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
                    var step = 0.01
                    var customScale_old = img.customScale
                    var xDelta = (wheel.x - img.x) / img.width * step * img.implicitWidth
                    var yDelta = (wheel.y - img.y) / img.height * step * img.implicitHeight

                    if (wheel.angleDelta.y > 0) {
                        img.customScale = Math.min(1.5 * img.parent.width / img.implicitWidth,
                                                   img.customScale + step)
                    } else {
                        img.customScale = Math.max(0.5 * img.parent.width / img.implicitWidth,
                                                   img.customScale - step)
                    }

                    if (img.width > img.parent.width) {
                        // The positioning rule is quit simple, try to simulate
                        // the effect that the image is zoomed in or zoomed out
                        // using the mouse as its origin.
                        if (img.customScale > customScale_old) {
                            img.x = img.x - xDelta
                            img.y = img.y - yDelta
                        } else if (img.customScale < customScale_old) {
                            img.x = img.x + xDelta
                            img.y = img.y + yDelta
                        }
                        // Don't let the corners of the image get into the
                        // container area.
                        if (img.x > 0) img.x = 0
                        if (img.x + img.width < img.parent.width) img.x = img.parent.width - img.width
                        if (img.y > 0) img.y = 0
                        if (img.y + img.height < img.parent.height) img.y = img.parent.height - img.height
                    } else {
                        // The img should be centered if it's scaled to a
                        // smaller size than the contianer.
                        if (img.width < img.parent.width) {
                            img.moveHCenter()
                        }
                        if (img.height < img.parent.height) {
                            img.moveVCenter()
                        }
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