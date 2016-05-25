import QtQuick 2.1
import QtAV 1.5
import QtGraphicalEffects 1.0
import Deepin.Widgets 1.0

Row {
    id: item
    spacing: 5
    width: toggle_button.width
    height: toggle_button.height

    property double volume: 1.0
    property alias muted: toggle_button.checkFlag
    property alias tooltipItem: toggle_button.tooltipItem

    property bool showBarFlag: false // for internal useage
    property bool showBarSwitch: true // for external useage

    signal changeVolume (double volume)
    signal mutedSet (bool muted)

    function emulateHover() {
        item.showBarFlag = true
        toggle_button.state = "hovered"
        hide_bar_timer.restart()
    }

    Timer {
        id: hide_bar_timer

        interval: 300
        onTriggered: {
            if (volume_bar_mouse_area.containsMouse || toggle_button.mouseArea.containsMouse) {
                hide_bar_timer.restart()
            } else {
                item.showBarFlag = false
                toggle_button.state = "normal"
            }
        }
    }

    ImageButton {
        id: toggle_button
        tooltip: dsTr("Volume")

        sourceSize.width: 28
        sourceSize.height: 28
        normal_image: checkFlag ? "image/volume_muted_normal.svg" :
                                    item.volume > 1.0 ? "image/volume_5_normal.svg" :
                                    item.volume > 0.75 ? "image/volume_4_normal.svg" :
                                    item.volume > 0.5 ? "image/volume_3_normal.svg":
                                    item.volume > 0.25 ? "image/volume_2_normal.svg":
                                                        "image/volume_1_normal.svg"
        hover_image: checkFlag ? "image/volume_muted_hover_press.svg" :
                                    item.volume > 1.0 ? "image/volume_5_hover_press.svg" :
                                    item.volume > 0.75 ? "image/volume_4_hover_press.svg" :
                                    item.volume > 0.5 ? "image/volume_3_hover_press.svg":
                                    item.volume > 0.25 ? "image/volume_2_hover_press.svg":
                                                        "image/volume_1_hover_press.svg"
        press_image: checkFlag ? "image/volume_muted_hover_press.svg" :
                                    item.volume > 1.0 ? "image/volume_5_hover_press.svg" :
                                    item.volume > 0.75 ? "image/volume_4_hover_press.svg" :
                                    item.volume > 0.5 ? "image/volume_3_hover_press.svg":
                                    item.volume > 0.25 ? "image/volume_2_hover_press.svg":
                                                        "image/volume_1_hover_press.svg"

        property bool checkFlag: false

        onStateChanged: {
            if(state == "hovered") {
                item.showBarFlag = true
            } else {
                hide_bar_timer.restart()
            }
        }

        onClicked: {
            item.mutedSet(!checkFlag)
        }
    }

    Item {
        id: bar_item
        visible: item.showBarSwitch && item.showBarFlag && !toggle_button.checkFlag
        width: volume_bar.width
        height: toggle_button.height

        Item {
            id: volume_bar
            width: actual_background.width + 4
            height: 7

            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                id: actual_background
                width: 63
                height: parent.height
                radius: 4
                color: "#e5e5e5"
                antialiasing: true
                anchors.centerIn: parent
            }

            MouseArea {
                id: volume_bar_mouse_area
                hoverEnabled: true
                anchors.fill: parent

                onContainsMouseChanged: toggle_button.state = containsMouse ? "hovered" : "normal"

                onClicked: {
                    var volume_pointer_x = Math.min(Math.max(mouse.x - volume_pointer.width / 2, 0), parent.width)
                    item.changeVolume(volume_pointer_x / (volume_bar.width - volume_pointer.width))
                }
            }

            Rectangle {
                id: left_part
                width: volume_pointer.x + volume_pointer.width / 2
                height: parent.height
                radius: 4
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#2b97dd"}
                    GradientStop { position: 1.0; color: "#4fdaff"}
                }
                anchors.verticalCenter: parent.verticalCenter
                antialiasing: true
            }

            Image {
                id: volume_pointer
                anchors.verticalCenter: parent.verticalCenter
                source: "image/volume_pointer.png"
                x: (volume_bar.width - volume_pointer.width) * Math.min(item.volume, 1.0)

                onXChanged: {
                    if (pointer_mouse_area.pressed) {
                        item.changeVolume(x / (volume_bar.width - volume_pointer.width))
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