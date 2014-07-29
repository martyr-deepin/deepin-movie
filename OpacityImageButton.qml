import QtQuick 2.1

MouseArea {
    id: button
    state: "normal"
    hoverEnabled: true
    width: image.implicitWidth
    height: image.implicitHeight
    property alias imageName: image.source

    property string tooltip: ""
    property QtObject tooltipItem: null

    states: [
        State { name: "normal"; PropertyChanges { target: image; opacity: 0.6 } },
        State { name: "hover"; PropertyChanges { target: image; opacity: 1.0 } },
        State { name: "press"; PropertyChanges { target: image; opacity: 0.4 } }
    ]

    Timer {
        id: show_tooltip_timer
        interval: 1000
        onTriggered: {
            if (button.containsMouse) {
                tooltipItem.showTip(tooltip)
            }
        }
    }

    Image { id: image }

    onEntered: {
        state = "hover"
        if (tooltip && tooltipItem) {
            show_tooltip_timer.restart()
        }
    }
    onExited: {
        state = "normal"
        if (tooltip && tooltipItem) {
            tooltipItem.hideTip()
        }
    }
    onPressed: { state = "press" }
    onReleased: { state = "hover" }
}