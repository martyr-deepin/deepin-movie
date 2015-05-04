import QtQuick 2.1
import Deepin.Widgets 1.0

DTextInput {
    id: input
    readOnly: true
    text: hotKey || dsTr("None")
    keyboardOperationsEnabled: false

    property string hotKey: "hotkey"

    signal hotkeySet (string key)
    signal hotkeyDisabled

    function hotkeyToText(hotKey) {
        return hotKey ? _utils.getOverrideKeyNames(hotKey) : dsTr("None")
    }

    onHotkeySet: text = hotkeyToText(key)
    // below line is necessary, it will prevent other operations from breaking
    // the binding of hotKey to text
    onHotKeyChanged: text = hotkeyToText(hotKey)
    onActiveFocusChanged: text = activeFocus ? dsTr("Please input a new shortcut") : hotkeyToText(hotKey)

    onKeyPressed: {
        var modifiers = [Qt.Key_Control, Qt.Key_Shift, Qt.Key_Alt, Qt.Key_Meta, Qt.Key_AltGr, Qt.Key_Super_L, Qt.Key_Super_R]
        if (modifiers.indexOf(event.key) == -1) {
            input.focus = false
            if (event.key != Qt.Key_Backspace) {
                input.hotkeySet(_utils.keyEventToQKeySequenceString(event.modifiers, event.key))
            } else {
                input.hotkeyDisabled()
            }
        }
    }
}