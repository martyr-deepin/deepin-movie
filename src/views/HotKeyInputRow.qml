import QtQuick 2.1
import Deepin.Widgets 1.0

Item {
    id: hotkey_input_row
    width: 370
    height: warning_dialog.visible ? top_row.height + warning_dialog.height
                                    : top_row.height

    property alias title: title.text
    property alias text: input.text
    property alias hotKey: input.hotKey
    property alias inputEnabled: input.enabled

    property var actualSettingEntry

    signal hotkeySet
    signal hotkeyReplaced
    signal hotkeyCancelled

    function disableShortcut() { setShortcut("") }

    function setShortcut(shortcut) {
        hotKey = Qt.binding(function() { return config[actualSettingEntry]+"" || dsTr("None") })
        config[actualSettingEntry] = shortcut
        text = Qt.binding(function() { return _utils.getOverrideKeyNames(shortcut) || dsTr("None") })
    }

    function warning(shortcutsEntry, shortcutsCategory) {
        warning_msg.text = dsTr("The shortcut you set ")
                            + dsTr("conflicts with the one used for \"%2\" in the \"%1\" category. ").arg(shortcutsCategory).arg(shortcutsEntry)
                            + dsTr("Do you want to replace it?")
        warning_dialog.visible = true
    }

    DConstants { id: dconstants }

    Item {
        id: top_row
        width: parent.width
        height: Math.max(title.implicitHeight, input.height)

        Text {
            id: title
            color: "#787878"
            width: 136
            wrapMode: Text.Wrap
            font.pixelSize: 12
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
        }

        HotKeyInput {
            id: input
            width: 200
            text: _utils.getOverrideKeyNames(hotKey) || dsTr("None")
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            onHotkeySet: hotkey_input_row.hotkeySet()
            onHotkeyDisabled: hotkey_input_row.disableShortcut()
        }
    }

    ArrowRect {
        id: warning_dialog
        visible: false
        radius: 0
        lineWidth: 0
        arrowPosition: 0.75
        strokeStyle: "#313131"
        stroke: true
        fillStyle: "#1d1e1e"

        contentTopMargin: 5
        contentBottomMargin: 5
        contentLeftMargin: 5
        contentRightMargin: 5

        anchors.top: top_row.bottom
        anchors.topMargin: 5

        Column {
            spacing: 10
            width: top_row.width - warning_dialog.contentLeftMargin - warning_dialog.contentRightMargin

            DssH2 {
                id: warning_msg
                width: parent.width - warning_dialog.contentLeftMargin - warning_dialog.contentRightMargin
                wrapMode: Text.WordWrap
            }

            Item {
                width: parent.width
                height: warning_cancel.height

                DTextButton {
                    id: warning_cancel
                    text: dsTr("Cancel")
                    anchors.right: warning_accept.left
                    anchors.rightMargin: 10

                    onClicked: {
                        warning_dialog.visible = false
                        hotkey_input_row.hotkeyCancelled()
                    }
                }
                DTextButton {
                    id: warning_accept
                    text: dsTr("Replace")
                    anchors.right: parent.right
                    anchors.rightMargin: 10

                    onClicked: {
                        warning_dialog.visible = false
                        hotkey_input_row.hotkeyReplaced()
                    }
                }
            }
        }
    }
}