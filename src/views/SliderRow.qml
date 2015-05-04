import QtQuick 2.1
import Deepin.Widgets 1.0

Item {
	width: 370
	height: Math.max(title.implicitHeight, slider.height)

	property alias title: title.text
	property alias min: slider.min
	property alias max: slider.max
	property alias init: slider.init
	property alias displayPercent: slider.displayPercent
	property alias floatNumber: slider.floatNumber
	property alias pressedFlag: slider.pressedFlag

	property string leftRuler
	property string rightRuler

	signal valueChanged (real value)
	signal valueConfirmed(real value)

	function setValue(value) { slider.setValue() }

	Text {
		id: title
		color: "#787878"
		width: 136
		wrapMode: Text.Wrap
		font.pixelSize: 12
		anchors.left: parent.left
		anchors.verticalCenter: parent.verticalCenter
	}

	DSliderEnhanced {
		id: slider
		width: 200
		isBalance: true
		percentFont.pixelSize: 10
		completeColorVisible: false
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter

		onValueChanged: parent.valueChanged(value)
		onValueConfirmed: parent.valueConfirmed(value)

		Component.onCompleted: {
		    parent.leftRuler && addRuler(min, parent.leftRuler)
		    parent.rightRuler && addRuler(max, parent.rightRuler)
		}
	}
}