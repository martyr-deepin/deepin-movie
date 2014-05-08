#! /usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (C) 2011 Deepin, Inc.
#               2011 Hou Shaohui
#
# Author:     Hou Shaohui <houshao55@gmail.com>
# Maintainer: Hou ShaoHui <houshao55@gmail.com>
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
from PyQt5.QtCore import pyqtSlot, QObject

ADJUST_TYPE_WINDOW_VIDEO = "ADJUST_TYPE_WINDOW_VIDEO"
ADJUST_TYPE_VIDEO_WINDOW = "ADJUST_TYPE_VIDEO_WINDOW"
ADJUST_TYPE_LAST_TIME = "ADJUST_TYPE_LAST_TIME"
ADJUST_TYPE_FULLSCREEN = "ADJUST_TYPE_FULLSCREEN"

DEFAULT_CONFIG = [
    ("Normal", [("volume", "1.0")]),
    ("Normal", [("adjust_type", ADJUST_TYPE_WINDOW_VIDEO)]),
    ]

class Config(QObject):
    def __init__(self):
        QObject.__init__(self)
        self.config_path = os.path.join(CONFIG_DIR, "config.ini")
        
        if not os.path.exists(self.config_path):
            os.makedirs(CONFIG_DIR)
            self.config = config.Config(self.config_path, DEFAULT_CONFIG)
            self.config.write()
        else:
            self.config = config.Config(self.config_path)
            self.config.load()
        
    @pyqtSlot(str, str, result=str)    
    def fetch(self, section, option):
        return self.config.get(section, option)
        
    @pyqtSlot(str, str, str)
    def save(self, section, option, value):  
        self.config.set(section, option, value)
        self.config.write()
