import QtQuick 2.1
import Deepin.Widgets 1.0

Item {
	width: 370
	height: Math.max(title.implicitHeight, input.height)

	property alias title: title.text
	property alias hotKey: input.hotKey

	signal hotkeySet (string hotkey)

	Text {
		id: title
		color: "#787878"
		anchors.left: parent.left
		anchors.verticalCenter: parent.verticalCenter
	}
    
	HotKeyInput {
		id: input
		width: 200
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter

		onHotkeySet: parent.hotkeySet(key)
	}
}