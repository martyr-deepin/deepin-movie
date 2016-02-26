/**
 * Copyright (C) 2014 Deepin Technology Co., Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 **/

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