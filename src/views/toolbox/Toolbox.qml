import QtQuick 2.2
import Deepin.Widgets 1.0

MouseArea {
    id: root
    width: content.width + rect.blurWidth * 2
    height: content.height + rect.blurWidth * 2 + rect.cornerHeight
    hoverEnabled: true
    state: {
        var locale = Qt.locale().name
        return locale == "zh_CN" ? "grid" : "list"
    }

    signal screenshotButtonClicked ()
    signal burstModeButtonClicked ()

    // prevent mouse move event from being propagated to progressbar.
    onPositionChanged: {}

    states: [
        State {
            name: "grid"
            PropertyChanges {
                target: content
                width: 135
                height: 68
            }
            PropertyChanges {
                target: content_loader
                sourceComponent: grid
            }
        },
        State {
            name: "list"
            PropertyChanges {
                target: content
                width: 146
                height: 70
            }
            PropertyChanges {
                target: content_loader
                sourceComponent: list
            }
        }
    ]

    DRectWithCorner {
        id: rect
        rectWidth: parent.width
        rectHeight: parent.height
        borderWidth: 0
        borderColor: "transparent"
        fillColor: "#1A1B1B"
    }

    Component {
        id: grid

        Grid {
            rows: 2
            columns: 3
            columnSpacing: 3
            anchors.fill: parent
            anchors.topMargin: 4
            anchors.bottomMargin: 4
            anchors.leftMargin: 6
            anchors.rightMargin: 6

            ToolboxButton {
                text: dsTr("Screenshot")
                normalImage: "../image/toolbox_screenshot_normal.svg"
                hoverImage: "../image/toolbox_screenshot_hover_press.svg"
                pressedImage: "../image/toolbox_screenshot_hover_press.svg"

                onClicked: { root.visible = false; root.screenshotButtonClicked() }
            }

            ToolboxButton {
                text: "Burst"
                normalImage: "../image/toolbox_serial_screenshots_normal.svg"
                hoverImage: "../image/toolbox_serial_screenshots_hover_press.svg"
                pressedImage: "../image/toolbox_serial_screenshots_hover_press.svg"

                onClicked: { root.visible = false; root.burstModeButtonClicked() }
            }
        }
    }

    Component {
        id: list

        Column {
            spacing: 6
            anchors.fill: parent
            anchors.margins: 8

            ToolboxButton {
                state: "list"
                text: dsTr("Screenshot")
                normalImage: "../image/toolbox_screenshot_normal.svg"
                hoverImage: "../image/toolbox_screenshot_hover_press.svg"
                pressedImage: "../image/toolbox_screenshot_hover_press.svg"

                onClicked: { root.visible = false; root.screenshotButtonClicked() }
            }

            ToolboxButton {
                state: "list"
                text: "Burst"
                normalImage: "../image/toolbox_serial_screenshots_normal.svg"
                hoverImage: "../image/toolbox_serial_screenshots_hover_press.svg"
                pressedImage: "../image/toolbox_serial_screenshots_hover_press.svg"

                onClicked: { root.visible = false; root.burstModeButtonClicked() }
            }
        }
    }

    Item {
        id: content
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: rect.blurWidth
        anchors.leftMargin: rect.blurWidth

        Loader { id: content_loader }
    }
}
