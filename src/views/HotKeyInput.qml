import QtQuick 2.1
import Deepin.Widgets 1.0

DTextInput {
	id: input
	readOnly: true
	text: hotKey
	keyboardOperationsEnabled: false

	property string hotKey: "hotkey"

	signal hotkeySet (string key)
	signal hotkeyDisabled

	onHotkeySet: { text = key || dsTr("Disabled"); focus = false }
	onActiveFocusChanged: text = activeFocus ? dsTr("Please input a new shortcut") : hotKey

	onKeyPressed: {
		var modifiers = [Qt.Key_Control, Qt.Key_Shift, Qt.Key_Alt, Qt.Key_Meta, Qt.Key_AltGr]
		if (modifiers.indexOf(event.key) == -1) {
			if (event.key != Qt.Key_Backspace) {
				input.focus = false
				input.hotkeySet(_utils.keyEventToQKeySequenceString(event.modifiers, event.key))	
			} else {
				input.hotkeyDisabled()
			}
		}
	}
}