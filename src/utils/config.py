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
import pickle
import misc
from constants import CONFIG_DIR
from PyQt5.QtCore import pyqtSlot, pyqtProperty, pyqtSignal, QObject
from ConfigParser import ConfigParser

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
("Player", [("volume", 1.0, float),
    ("muted", False, bool),
    ("subtitleHide", False, bool),
    # ("adjustType", ADJUST_TYPE_WINDOW_VIDEO),
    ("applyLastClosedSize", False, bool),
    ("fullscreenOnOpenFile", False, bool),
    ("playOrderType", ORDER_TYPE_PLAYLIST_CYCLE, str),
    ("cleanPlaylistOnOpenNewFile", False, bool),
    ("autoPlayFromLast", True, bool),
    ("autoPlaySeries", True, bool),
    ("showPreview", True, bool),
    ("forwardRewindStep", 5.0, float),
    ("multipleProgramsAllowed", False, bool),
    ("notificationsEnabled", True, bool),
    ("pauseOnMinimized", True, bool),]),
("HotkeysPlay", [("hotkeyEnabled", True, bool),
    ("togglePlay", "Space", str),
    ("forward", "Right", str),
    ("backward", "Left", str),
    ("toggleFullscreen", "Return", str),
    ("togglePlaylist", "F3", str),
    ("speedUp", "Ctrl+Right", str),
    ("slowDown", "Ctrl+Left", str),
    ("restoreSpeed", "R", str)]),
("HotkeysFrameSound", [("hotkeyEnabled", True, bool),
    ("toggleMiniMode", "F2", str),
    ("rotateClockwise", "W", str),
    ("rotateAnticlockwise", "E", str),
    ("increaseVolume", "Up", str),
    ("decreaseVolume", "Down", str),
    ("toggleMute", "M", str),]),
("HotkeysSubtitles", [("hotkeyEnabled", True, bool),
    ("subtitleForward", "Shift+Right", str),
    ("subtitleBackward", "Shift+Left", str),
    ("subtitleMoveUp", "Shift+Up", str),
    ("subtitleMoveDown", "Shift+Down", str),]),
("HotkeysFiles", [("hotkeyEnabled", True, bool),
    ("openFile", "Ctrl+O", str),
    ("playPrevious", "PgUp", str),
    ("playNext", "PgDown", str),]),
("Subtitle", [("autoLoad", True, bool),
    ("fontSize", 20, float),
    ("fontFamily", "", str),
    ("fontColor", "#ffffff", str),
    ("fontBorderSize", 1.0, float),
    ("fontBorderColor", "black", str),
    ("verticalPosition", 0.05, float),
    ("delayStep", 0.5, float)]),
("Others", [("leftClick", True, bool),
    ("doubleClick", True, bool),
    ("wheel", True, bool)]),
]



def getDefault(section, key):
    for _section, _items in DEFAULT_CONFIG:
        if _section == section:
            for _key, _value, _type in _items:
                if _key == key:
                    return _value
            return None
        else:
            return None
    return None


property_name_func = lambda section, key: "%s%s" % (
    section[0].lower() + section[1:],
    key[0].upper() + key[1:])

class Config(QObject):
    LoadDefault = 0
    LoadConfig = 1
    LoadBackup = 2

    canResetHotkeysChanged = pyqtSignal()
    canResetSubtitleSettingsChanged = pyqtSignal()

    def __init__(self):
        super(QObject, self).__init__()
        self.config_path = os.path.join(CONFIG_DIR, "config.ini")
        self.backup_path = os.path.join(CONFIG_DIR, "config.bak")

        if not os.path.exists(self.config_path):
            if not os.path.exists(CONFIG_DIR): os.makedirs(CONFIG_DIR)
            self._initContent(initMode=Config.LoadDefault)
        else:
            # there are cases that the config file's corrupted,
            # we should take care of this situation.
            if self._checkFileIntegerity(self.config_path):
                self._initContent(initMode=Config.LoadConfig)
            elif self._checkFileIntegerity(self.backup_path):
                self._initContent(initMode=Config.LoadBackup)
            else:
                self._initContent(initMode=Config.LoadDefault)

    def _initContent(self, initMode=LoadDefault):
        self.config = misc.Config(self.config_path)
        self.config.config_parser.optionxform=str
        self.backup = misc.Config(self.backup_path)
        self.backup.config_parser = self.config.config_parser
        if initMode == Config.LoadDefault:
            self.config.default_config = self._getConfigDefaults()
            self.config.load_default()
            self.config.write()
        elif initMode == Config.LoadConfig:
            self.config.load()
            self.backup.write()
        elif initMode == Config.LoadBackup:
            self.backup.load()
            self.config.write()

        volume = self.fetchFloat("Player", "volume")
        self.save("Player", "volume", min(1.0, volume))

        # add new keys here
        subtitleDelayStep = self.fetch("Subtitle", "delayStep")
        if not subtitleDelayStep:
            self.save("Subtitle", "delayStep", \
                      getDefault("Subtitle", "delayStep"))

    def _getConfigDefaults(self):
        result = []
        for section, items in DEFAULT_CONFIG:
            _items = []
            result.append((section, _items))
            for option, value, type in items:
                _items.append((option, value))
        return result

    def _checkFileIntegerity(self, configFile):
        try:
            with open(configFile) as _file:
                config = ConfigParser()
                config.optionxform=str
                config.readfp(_file)

                for section, items in DEFAULT_CONFIG:
                    for option, value, type in items:
                        if not config.has_option(section, option):
                            return False
        except Exception:
            # errors like file doesn't exist or parse error
            # will be handled here.
            return False

        return True

    def _isShortcutsDefault(self):
        for section, items in DEFAULT_CONFIG:
            if section.startswith("Hotkeys") or section.startswith("Others"):
                for key, value, type in items:
                    itemName = property_name_func(section, key)
                    currentValue = getattr(self, itemName, value)

                    if type(value) != currentValue:
                        return True
        return False

    def _isSubtitleSettingsDefault(self):
        for section, items in DEFAULT_CONFIG:
            if section.startswith("Subtitle"):
                for key, value, type in items:
                    itemName = property_name_func(section, key)
                    currentValue = getattr(self, itemName, value)
                    if type(value) != currentValue:
                        return True
        return False

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

    @pyqtProperty(bool)
    def canResetHotkeys(self):
        return self._isShortcutsDefault()

    @pyqtProperty(bool)
    def canResetSubtitleSettings(self):
        return self._isSubtitleSettingsDefault()

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
        self.backup.write()

    @pyqtSlot()
    def resetHotkeys(self):
        for section, items in DEFAULT_CONFIG:
            if section.startswith("Hotkeys") or section.startswith("Others"):
                for key, value, type in items:
                    itemName = property_name_func(section, key)

                    setattr(self, itemName, value)

    @pyqtSlot()
    def resetSubtitleSettings(self):
        for section, items in DEFAULT_CONFIG:
            if section.startswith("Subtitle"):
                for key, value, type in items:
                    itemName = property_name_func(section, key)

                    setattr(self, itemName, value)

    # automatically make config entries accessable as qt properties.
    for section, items in DEFAULT_CONFIG:
        for key, value, type in items:
            itemName = property_name_func(section, key)
            itemNotify = "%sChanged" % itemName

            nfy = locals()[itemNotify] = pyqtSignal()

            def _get(section, key, type):
                def f(self):
                    result = self.fetch(section, key)
                    # take care of the entries that takes unicode as their
                    # values
                    if section == "Subtitle" \
                    and key == "fontFamily" \
                    and result:
                        return pickle.loads(result)

                    if type == bool:
                        if result in ("true", "True", "1.0", "1", True, 1):
                            return True
                        else:
                            return False
                    elif type == float:
                        return float(result)
                    else:
                        return result
                return f

            def _set(section ,key, itemNotify):
                def f(self, value):
                    # take care of the entries that takes unicode as their
                    # values
                    if section == "Subtitle" \
                    and key == "fontFamily"\
                    and value:
                        value = pickle.dumps(value)
                    self.save(section, key, value)
                    getattr(self, itemNotify).emit()

                    if section.startswith("Hotkeys") \
                    or section.startswith("Others"):
                        self.canResetHotkeysChanged.emit()

                    if section.startswith("Subtitle"):
                        self.canResetSubtitleSettingsChanged.emit()
                return f

            set = locals()['_set_'+key] = _set(section, key, itemNotify)
            get = locals()['_get_'+key] = _get(section, key, type)

            locals()[itemName] = pyqtProperty("QVariant", get, set, notify=nfy)

config = Config()

if __name__ == '__main__':
    for section, items in DEFAULT_CONFIG:
        for key, value, type in items:
            itemName = "%s%s" % (section[0].lower() + section[1:], key[0].upper() + key[1:])
            itemNotify = "%sChanged" % itemName

            print itemName
            print getattr(config, itemName)
