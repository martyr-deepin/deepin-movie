/**
 * Copyright (C) 2014 Deepin Technology Co., Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 **/

import QtQuick 2.1
import Deepin.Widgets 1.0

Item {
    id: hotkey_input_row
    width: 370
    height: warning_dialog.visible ? top_row.height + warning_dialog.height
                                    : top_row.height

    property alias title: title.text
    property alias text: input.text
    property alias hotKey: input.shortcut
    property alias inputEnabled: input.enabled

    property var actualSettingEntry

    signal hotkeySet
    signal hotkeyReplaced
    signal hotkeyCancelled

    function disableShortcut() { setShortcut("") }

    function setShortcut(shortcut) {
        hotKey = Qt.binding(function() { return config[actualSettingEntry]+"" || dsTr("None") })
        config[actualSettingEntry] = shortcut
        text = Qt.binding(function() { return KeysUtils.getOverriddenShortcut(shortcut) || dsTr("None") })
    }

    function warning(shortcutsEntry, shortcutsCategory) {
        warning_msg.text = dsTr("The shortcut you set ")
                            + dsTr("conflicts with the one used for \"%2\" in the \"%1\" category. ").arg(shortcutsCategory).arg(shortcutsEntry)
                            + dsTr("Do you want to replace it?")
        warning_dialog.visible = true
    }

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

        DShortcutInput {
            id: input
            width: 200
            noneString: dsTr("None")
            promoteString: dsTr("Please input a new shortcut")
            text: KeysUtils.getOverriddenShortcut(shortcut) || dsTr("None")
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            onShortcutSet: hotkey_input_row.hotkeySet()
            onShortcutDisabled: hotkey_input_row.disableShortcut()
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