import QtQuick 2.2

MouseArea {
	width: 60
	height: 60
	state: "normal"
	hoverEnabled: true

	property url normalImage
	property url hoverImage
	property url pressedImage

	property alias text: txt.text

	states: [
		State {
			name: "normal"
			PropertyChanges { target: img; source: normalImage }
		},
		State {
			name: "hover"
			PropertyChanges { target: img; source: hoverImage }
		},
		State {
			name: "pressed"
			PropertyChanges { target: img; source: pressedImage }
		}
	]

	Image {
		id: img
		anchors.top: parent.top
		anchors.topMargin: 12
		anchors.horizontalCenter: parent.horizontalCenter
	}

	Text {
		id: txt
		color: "white"
		font.pixelSize: 12

		anchors.top: img.bottom
		anchors.topMargin: 4
		anchors.horizontalCenter: parent.horizontalCenter
	}

	onEntered: state = "hover"
	onExited: state = "normal"
	onPressed: state = "pressed"
	onReleased: state = containsMouse ? "hover" : "normal"
}