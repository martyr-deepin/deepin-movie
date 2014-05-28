import QtQuick 2.1
import Deepin.Widgets 1.0

Item {
	width: 300
	height: Math.max(title.implicitHeight, input.height)

	property alias title: title.text

	DssH1 {
		id: title
		anchors.left: parent.left
		anchors.verticalCenter: parent.verticalCenter
	}
	DComboBox {
		id: input
		width: 200
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
	}
}