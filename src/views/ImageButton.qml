/**
 * Copyright (C) 2014 Deepin Technology Co., Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 **/

import QtQuick 2.1
import Deepin.Widgets 1.0

DImageButton {
	id:  button
    opacity: enabled ? 1.0 : 0.2

    property string tooltip: ""
    property QtObject tooltipItem: null

    Timer {
    	id: show_tooltip_timer
    	interval: 1000
    	onTriggered: {
    		if (button.containsMouse) {
    			tooltipItem.showTip(tooltip)
    		}
    	}
    }

    onEntered: {
    	if (tooltip && tooltipItem) {
    		show_tooltip_timer.restart()
    	}
    }

    onExited: {
    	if (tooltip && tooltipItem) {
    		tooltipItem.hideTip()
    	}
    }
}
