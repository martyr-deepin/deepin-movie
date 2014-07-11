import QtQuick 2.1
import Deepin.Widgets 1.0

DTextInput {
	id: input
	readOnly: true
	text: hotKey

	property string hotKey: "hotkey"

	signal hotkeySet (string key)

	onHotkeySet: { hotKey = key; focus = false }
	onActiveFocusChanged: text = activeFocus ? dsTr("Please input new shortcut") : hotKey

	Keys.onPressed: {
		var modifiers = [Qt.Key_Control, Qt.Key_Shift, Qt.Key_Alt, Qt.Key_Meta, Qt.Key_AltGr]
		if (modifiers.indexOf(event.key) == -1) {
			input.hotkeySet(_utils.keyEventToQKeySequenceString(event.modifiers, event.key))
			input.focus = false
		}
	}
}