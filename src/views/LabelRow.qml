import QtQuick 2.2
import Deepin.Widgets 1.0

Item {
	width: 370
	height: title.implicitHeight

	property alias title: title.text

	Text {
		id: title
		color: "#787878"
		width: parent.width
		wrapMode: Text.Wrap
		font.pixelSize: 12
		anchors.left: parent.left
		anchors.verticalCenter: parent.verticalCenter
	}
}