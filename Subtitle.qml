import QtQuick 2.1
import QtGraphicalEffects 1.0

Item {
	width: 1000
	height: txt.implicitHeight

	property alias text: txt.text
	property alias fontColor: txt.color
	property alias fontSize: txt.font.pixelSize

	Text {
		id: txt
		width: parent.width
		color: "white"
		horizontalAlignment: Text.AlignHCenter
		wrapMode: Text.WordWrap
		maximumLineCount: 10
		font.pixelSize: 28
	}

	Glow {
		anchors.fill: parent
		radius: 1
		spread: 1
		samples: 16
		color: "black"
		source: txt
	}
}