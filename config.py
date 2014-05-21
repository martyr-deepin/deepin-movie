#! /usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (C) 2011 Deepin, Inc.
#               2011 Hou Shaohui
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

YES = "yes"
NO = "no"

ADJUST_TYPE_WINDOW_VIDEO = "ADJUST_TYPE_WINDOW_VIDEO"
ADJUST_TYPE_VIDEO_WINDOW = "ADJUST_TYPE_VIDEO_WINDOW"
ADJUST_TYPE_LAST_TIME = "ADJUST_TYPE_LAST_TIME"
ADJUST_TYPE_FULLSCREEN = "ADJUST_TYPE_FULLSCREEN"

DEFAULT_CONFIG = [
("Player", [("volume", "1.0"), 
    ("muted", NO),
    ("subtitleHide", NO),
    ("adjustType", ADJUST_TYPE_WINDOW_VIDEO),
    ("cleanPlaylistOnOpenNewFile", NO),
    ("autoPlayFromLast", YES),
    ("autoPlaySeries", YES),
    ("showPreview", YES),
    ("multipleProgramsAllowed", NO),
    ("stopOnMinimized", YES),]),
("HotkeysPlay", [("hotkey_enabled", YES),
    ("openFile", "Ctrl+O"), 
    ("openDir", "Ctrl+F"),
    ("togglePlay", "Space"),
    ("forward", "Right"),
    ("backward", "Left"),
    ("toggleFullscreen", "Return"),
    ("playPrevious", "PgUp"),
    ("playNext", "PgDown"),
    ("increaseVolume", "Up"),
    ("decreaseVolume", "Down"),
    ("toggleMute", "M"),]),
("HotkeysOthers", [("hotkey_enabled", YES),
    ("rotateClockwise", "W"),
    ("rotateAnticlockwise", "E"),
    ("screenshot", "Alt+A"),]),
("Subtitle", [("auto_load", YES),
    ("fontSize", "16"),
    ("fontColor", "#ffffff")]),
]

class Config(QObject):
    subtitleFontSizeChanged = pyqtSignal(int)
    subtitleFontColorChanged = pyqtSignal(str)
    configChanged = pyqtSignal(str, "QVariant")

    def __init__(self):
        QObject.__init__(self)
        self.config_path = os.path.join(CONFIG_DIR, "config.ini")
        
        if not os.path.exists(self.config_path):
            os.makedirs(CONFIG_DIR)
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
    def hotKeysOthers(self):
        result = []
        for item in self.config.items("HotkeysOthers"):
            result.append({"command": item[0], "key": item[1]})
        return result

    @pyqtProperty(int, notify=subtitleFontSizeChanged)
    def fontSize(self):
        return self.fetchfloat("Subtitle", "font_size")

    @fontSize.setter
    def fontSize(self, value):
        self.save("Subtitle", "font_size", value)

    @pyqtProperty(str, notify=subtitleFontColorChanged)
    def fontColor(self):
        return self.fetch("Subtitle", "font_color")

    @fontColor.setter
    def fontColor(self, value):
        self.save("Subtitle", "font_color", value)

    @pyqtSlot(str, str, result=str)    
    def fetch(self, section, option):
        return self.config.get(section, option)

    @pyqtSlot(str, str, result=float)
    def fetchfloat(self, section, option):
        return self.config.getfloat(section, option)

    @pyqtSlot(str,str,result=bool)
    def fetchBool(self, section, option):
        return self.config.getboolean(section, option)      
        
    @pyqtSlot(str, str, str)
    def save(self, section, option, value):  
        self.config.set(section, option, value)
        self.config.write()

config = Config()