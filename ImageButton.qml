import QtQuick 2.1

Image {
	id: maxButton
	property string imageName: ""
	source: imageName + "_normal.png"

	MouseArea {
		anchors.fill: parent
		onEntered: {parent.source = imageName + "_hover.png"}
		onPressed: {parent.source = imageName + "_press.png"}
		onReleased: {parent.source = imageName + "_hover.png"}
		onExited: {parent.source = imageName + "_normal.png"}
	}
}
