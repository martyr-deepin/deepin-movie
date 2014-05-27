import QtQuick 2.1
import QtMultimedia 5.0
import QtGraphicalEffects 1.0

Row {
    id: item
    spacing: 5
    width: toggle_button.width
    height: toggle_button.height

    property double volume: 1.0
    property alias muted: toggle_button.checkFlag
    
    property bool showBarFlag: false

    signal changeVolume
    signal mutedSet (bool muted)

    function emulateHover() {
        item.showBarFlag = true
        toggle_button.state = "hover"
        hide_bar_timer.restart()
    }

    Timer {
        id: hide_bar_timer

        interval: 500
        onTriggered: {
            if (volume_bar_mouse_area.containsMouse) {
                hide_bar_timer.restart()
            } else {
                item.showBarFlag = false
                toggle_button.state = "normal"
            }
        }
    }

    OpacityImageButton {
        id: toggle_button
        imageName: checkFlag ? "image/player_volume_inactive.png" : "image/player_volume_active.png"

        property bool checkFlag: false
        
        onEntered: {
            item.showBarFlag = true
        }

        onExited: {
            hide_bar_timer.restart()
        }

        onClicked: {
            checkFlag = !checkFlag
            item.mutedSet(checkFlag)
        }
    }

    Item {
        id: bar_item
        visible: item.showBarFlag && !toggle_button.checkFlag
        width: volume_bar.width
        height: toggle_button.height

        Image {
            id: volume_bar
            source: "image/volume_background.png"
            anchors.verticalCenter: parent.verticalCenter

            MouseArea {
                id: volume_bar_mouse_area
                hoverEnabled: true
                anchors.fill: parent

                onContainsMouseChanged: toggle_button.state = containsMouse ? "hover" : "normal"

                onClicked: {
                    volume_pointer.x = Math.min(Math.max(mouse.x - volume_pointer.width / 2, 0), parent.width)
                    volume = volume_pointer.x / (volume_bar.width - volume_pointer.width)
                    item.changeVolume(volume)
                }
            }

            Image {
                id: left_part
                anchors.left: parent.left
                source: "image/volume_foreground_left.png"
            }

            Image {
                id: center_part
                anchors.left: left_part.right
                anchors.right: volume_pointer.horizontalCenter
                source: "image/volume_foreground_middle.png"
                fillMode: Image.TileHorizontally
            }

            Image {
                id: volume_pointer
                anchors.verticalCenter: parent.verticalCenter
                source: "image/volume_pointer.png"
                x: (volume_bar.width - volume_pointer.width) * item.volume

                onXChanged: {
                    if (pointer_mouse_area.pressed) {
                        volume = x / (volume_bar.width - volume_pointer.width)
                        item.changeVolume(volume)
                    }
                }

                MouseArea {
                    id: pointer_mouse_area
                    anchors.fill: parent
                    drag.target: volume_pointer
                    drag.axis: Drag.XAxis
                    drag.minimumX: 0
                    drag.maximumX: volume_bar.width - volume_pointer.width
                }
            }
        }
    }
}