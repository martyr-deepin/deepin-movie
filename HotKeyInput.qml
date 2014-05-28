import QtQuick 2.1
import Deepin.Widgets 1.0

DTextInput {
	id: input
	readOnly: true
	text: shortcuts

	property string shortcuts: "shortcuts"

	signal shortcutsSet (string key)

	onShortcutsSet: shortcuts = key
	onActiveFocusChanged: text = activeFocus ? "Please input new shortcuts" : shortcuts

	Keys.onPressed: {
		var modifiers = [Qt.Key_Control, Qt.Key_Shift, Qt.Key_Alt, Qt.Key_Meta, Qt.Key_AltGr]
		if (modifiers.indexOf(event.key) == -1) {
			input.shortcutsSet(_utils.keyEventToQKeySequenceString(event.modifiers, event.key))
			input.focus = false
		}
	}
}