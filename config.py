#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (C) 2014 Deepin, Inc.
#               2014 Wang Yaohua
#
# Author:     Wang Yaohua <mr.asianwang@gmail.com>
# Maintainer: Wang Yaohua <mr.asianwang@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import os
from deepin_utils import config
from constant import CONFIG_DIR
from PyQt5.QtCore import pyqtSlot, pyqtProperty, pyqtSignal, QObject

# ADJUST_TYPE_WINDOW_VIDEO = "ADJUST_TYPE_WINDOW_VIDEO"
# ADJUST_TYPE_VIDEO_WINDOW = "ADJUST_TYPE_VIDEO_WINDOW"
# ADJUST_TYPE_LAST_TIME = "ADJUST_TYPE_LAST_TIME"
# ADJUST_TYPE_FULLSCREEN = "ADJUST_TYPE_FULLSCREEN"

ORDER_TYPE_RANDOM = "ORDER_TYPE_RANDOM"
ORDER_TYPE_IN_ORDER = "ORDER_TYPE_IN_ORDER"
ORDER_TYPE_SINGLE = "ORDER_TYPE_SINGLE"
ORDER_TYPE_SINGLE_CYCLE = "ORDER_TYPE_SINGLE_CYCLE"
ORDER_TYPE_PLAYLIST_CYCLE = "ORDER_TYPE_PLAYLIST_CYCLE"

DEFAULT_CONFIG = [
("Player", [("volume", 1.0),
    ("muted", False),
    ("subtitleHide", False),
    # ("adjustType", ADJUST_TYPE_WINDOW_VIDEO),
    ("applyLastClosedSize", False),
    ("fullscreenOnOpenFile", False),
    ("playOrderType", ORDER_TYPE_PLAYLIST_CYCLE),
    ("cleanPlaylistOnOpenNewFile", False),
    ("autoPlayFromLast", True),
    ("autoPlaySeries", True),
    ("showPreview", True),
    ("forwardRewindStep", 5.0),
    ("multipleProgramsAllowed", False),
    ("notificationsEnabled", True),
    ("pauseOnMinimized", True),]),
("HotkeysPlay", [("hotkeyEnabled", True),
    ("togglePlay", "Space"),
    ("forward", "Right"),
    ("backward", "Left"),
    ("toggleFullscreen", "Return"),
    ("togglePlaylist", "F3"),
    ("speedUp", "Ctrl+Right"),
    ("slowDown", "Ctrl+Left"),
    ("restoreSpeed", "R")]),
("HotkeysFrameSound", [("hotkeyEnabled", True),
    ("toggleMiniMode", "F2"),
    ("rotateClockwise", "W"),
    ("rotateAnticlockwise", "E"),
    ("increaseVolume", "Up"),
    ("decreaseVolume", "Down"),
    ("toggleMute", "M"),]),
("HotkeysSubtitles", [("hotkeyEnabled", True),
    ("subtitleForward", "Shift+Right"),
    ("subtitleBackward", "Shitft+Left"),
    ("subtitleMoveUp", "Shift+Up"),
    ("subtitleMoveDown", "Shift+Down"),]),
("HotkeysFiles", [("hotkeyEnabled", True),
    ("openFile", "Ctrl+O"),
    ("playPrevious", "PgUp"),
    ("playNext", "PgDown"),]),
("Subtitle", [("autoLoad", True),
    ("fontSize", 20),
    ("fontFamily", ""),
    ("fontColor", "#ffffff"),
    ("fontBorderSize", 1.0),
    ("fontBorderColor", "black"),
    ("verticalPosition", 0.05)]),
("Others", [("leftClick", True),
    ("doubleClick", True),
    ("wheel", True)]),
]

property_name_func = lambda section, key: "%s%s" % (
    section[0].lower() + section[1:],
    key[0].upper() + key[1:])

class Config(QObject):
    def __init__(self):
        super(QObject, self).__init__()
        self.config_path = os.path.join(CONFIG_DIR, "config.ini")

        if not os.path.exists(self.config_path):
            if not os.path.exists(CONFIG_DIR): os.makedirs(CONFIG_DIR)
            self.config = config.Config(self.config_path)
            self.config.config_parser.optionxform=str
            self.config.default_config = DEFAULT_CONFIG
            self.config.load_default()
            self.config.write()
        else:
            self.config = config.Config(self.config_path)
            self.config.config_parser.optionxform=str
            self.config.load()

    @pyqtProperty("QVariant")
    def hotKeysPlay(self):
        result = []
        for item in self.config.items("HotkeysPlay"):
            result.append({"command": item[0], "key": item[1]})
        return result

    @pyqtProperty("QVariant")
    def hotkeysFrameSound(self):
        result = []
        for item in self.config.items("HotkeysFrameSound"):
            result.append({"command": item[0], "key": item[1]})
        return result

    @pyqtProperty("QVariant")
    def hotkeysFiles(self):
        result = []
        for item in self.config.items("HotkeysFiles"):
            result.append({"command": item[0], "key": item[1]})
        return result

    @pyqtProperty("QVariant")
    def hotkeysSubtitles(self):
        result = []
        for item in self.config.items("HotkeysSubtitles"):
            result.append({"command": item[0], "key": item[1]})
        return result

    @pyqtProperty("QVariant")
    def hotKeysOthers(self):
        result = []
        for item in self.config.items("HotkeysOthers"):
            result.append({"command": item[0], "key": item[1]})
        return result

    @pyqtSlot(str, str, result=str)
    def fetch(self, section, option):
        return self.config.get(section, option)

    @pyqtSlot(str, str, result=float)
    def fetchFloat(self, section, option):
        return self.config.getfloat(section, option)

    @pyqtSlot(str,str,result=bool)
    def fetchBool(self, section, option):
        return self.config.getboolean(section, option)

    @pyqtSlot(str, str, str)
    def save(self, section, option, value):
        self.config.set(section, option, value)
        self.config.write()

    @pyqtSlot()
    def resetHotkeys(self):
        for section, items in DEFAULT_CONFIG:
            if not section.startswith("Hotkeys"): continue
            for key, value in items:
                itemName = property_name_func(section, key)

                setattr(config, itemName, value)

    # automatically make config entries accessable as qt properties.
    for section, items in DEFAULT_CONFIG:
        for key, value in items:
            itemName = property_name_func(section, key)
            itemNotify = "%sChanged" % itemName

            nfy = locals()[itemNotify] = pyqtSignal()

            def _get(section, key):
                def f(self):
                    result = self.fetch(section, key)
                    if result in ("True", "False"):
                        return eval(result)
                    else:
                        try:
                            return self.fetchFloat(section, key)
                        except Exception:
                            return self.fetch(section, key)
                return f

            def _set(section ,key, itemNotify):
                def f(self, value):
                    self.save(section, key, value)
                    getattr(self, itemNotify).emit()
                return f

            set = locals()['_set_'+key] = _set(section, key, itemNotify)
            get = locals()['_get_'+key] = _get(section, key)

            locals()[itemName] = pyqtProperty("QVariant", get, set, notify=nfy)

config = Config()

if __name__ == '__main__':
    for section, items in DEFAULT_CONFIG:
        for key, value in items:
            itemName = "%s%s" % (section[0].lower() + section[1:], key[0].upper() + key[1:])
            itemNotify = "%sChanged" % itemName

            print itemName
            print getattr(config, itemName)
