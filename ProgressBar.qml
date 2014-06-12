import QtQuick 2.1

Item {
    id: progressbar
    width: 300
    height: 7
    state: "minimal"

    property real percentage: 0.0
    property bool showPointerSwitch: true

    onStateChanged: state == "normal" && became_minimal_timer.restart()
    
    signal mouseOver (int mouseX)
    signal mouseDrag (int mouseX)
    signal mouseExit ()
    signal percentageSet(real percentage)

    Gradient {
        id: background_gradient
        GradientStop { position: 0.0; color: "#444a4a4a"}
        GradientStop { position: 1.0; color: "#443c3c3c"}
    }

    Gradient {
        id: foreground_gradient
        GradientStop { position: 0.0; color: "#2b97dd"}
        GradientStop { position: 1.0; color: "#4fdaff"}
    }

    states: [
        State {
            name: "normal"
            PropertyChanges {
                target: progressbar
                showPointerSwitch: true
            }
            PropertyChanges {
                target: background
                height: 7
                gradient: background_gradient
            }
            PropertyChanges {
                target: background_partner
                visible: true
            }
            PropertyChanges {
                target: foreground
                gradient: foreground_gradient
            }
            PropertyChanges {
                target: foreground_partner
                visible: true
            }
        },
        State {
            name: "minimal"
            PropertyChanges {
                target: progressbar
                showPointerSwitch: false
            }
            PropertyChanges {
                target: background
                height: 2
                gradient: undefined
            }
            PropertyChanges {
                target: background_partner
                visible: false
            }
            PropertyChanges {
                target: foreground
                gradient: undefined
            }
            PropertyChanges {
                target: foreground_partner
                visible: false
            }
        }
    ]

    function update() { pointer.x = progressbar.width * percentage - pointer.width / 2 }

    Timer {
        id: became_minimal_timer
        interval: 500
        onTriggered: mouse_area.containsMouse ? became_minimal_timer.restart() : (progressbar.state = "minimal")
    }
    
    MouseArea {
        id: mouse_area
        hoverEnabled: true
        anchors.fill: parent

        onClicked: {
            progressbar.percentageSet(mouse.x / progressbar.width)
        }

        onPositionChanged: {
            (progressbar.percentage > 0 && progressbar.percentage < 100) && (progressbar.state = "normal")
            progressbar.mouseOver(mouse.x)
        }

        onExited: {
            progressbar.mouseExit()
        }
    }

    onPercentageChanged: {
        if (!drag_area.drag.active) { update() }
    }

    Rectangle {
        id: background
        color: Qt.rgba(1, 1, 1, 0.2)
        width: parent.width

        Rectangle {
            id: background_partner
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 1
            color: Qt.rgba(1, 1, 1, 0.15)
        }

        Rectangle {
            id: foreground
            anchors.left: parent.left
            anchors.top: parent.top
            height: parent.height
            width: pointer.x + pointer.width / 2
            color: "#3a9efe"

            Rectangle {
                id: foreground_partner
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: 1
                color: "#3fa8fe"
            }
        }

        Image {
            id: pointer
            opacity: progressbar.showPointerSwitch && 0 <= x && x <= background.width - width ? 1 : 0 
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
