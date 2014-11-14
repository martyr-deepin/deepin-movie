import QtQuick 2.1
import Deepin.Widgets 1.0

DImageButton {
	id:  button
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
