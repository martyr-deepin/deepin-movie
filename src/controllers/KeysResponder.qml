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
    function respondKey(event) {
        if (KeysUtils.isKeyEventEqualToString(event.modifiers, event.key, "F1")) {
            main_controller.showManual()
        }
        if (KeysUtils.isKeyEventEqualToString(event.modifiers, event.key, "Ctrl+Shift+?")) {
            shortcuts_viewer.show(); return
        }
        if (event.key == Qt.Key_Escape) { main_controller.quitFullscreen(); return }
        if (config.hotkeysPlayHotkeyEnabled) {
            for(var i = 0; i < config.hotKeysPlay.length; i++) {
                if (KeysUtils.isKeyEventEqualToString(event.modifiers, event.key,
                    config.hotKeysPlay[i].key))
                {
                    eval("main_controller." + config.hotKeysPlay[i].command + "()")
                    return
                }
            }
        }
        if (config.hotkeysFrameSoundHotkeyEnabled) {
            for(var i = 0; i < config.hotkeysFrameSound.length; i++) {
                if (KeysUtils.isKeyEventEqualToString(event.modifiers, event.key,
                    config.hotkeysFrameSound[i].key))
                {
                    eval("main_controller." + config.hotkeysFrameSound[i].command + "()")
                    return
                }
            }
        }
        if (config.hotkeysFilesHotkeyEnabled) {
            for(var i = 0; i < config.hotkeysFiles.length; i++) {
                if (KeysUtils.isKeyEventEqualToString(event.modifiers, event.key,
                    config.hotkeysFiles[i].key))
                {
                    eval("main_controller." + config.hotkeysFiles[i].command + "()")
                    return
                }
            }
        }
        if (config.hotkeysSubtitlesHotkeyEnabled) {
            for(var i = 0; i < config.hotkeysSubtitles.length; i++) {
                if (KeysUtils.isKeyEventEqualToString(event.modifiers, event.key,
                    config.hotkeysSubtitles[i].key))
                {
                    if ((config.hotkeysSubtitles[i].command == "subtitleForward"
                         || config.hotkeysSubtitles[i].command == "subtitleBackward")
                        && event.isAutoRepeat)
                    {
                        return
                    }

                    eval("main_controller." + config.hotkeysSubtitles[i].command + "()")
                    return
                }
            }
        }
        if (config.hotkeysScreenshotHotkeyEnabled) {
            for(var i = 0; i < config.hotkeysScreenshot.length; i++) {
                if (KeysUtils.isKeyEventEqualToString(event.modifiers, event.key,
                    config.hotkeysScreenshot[i].key))
                {
                    eval("main_controller." + config.hotkeysScreenshot[i].command + "()")
                    return
                }
            }
        }
    }
}