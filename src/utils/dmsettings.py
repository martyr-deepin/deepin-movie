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
from PyQt5.QtCore import QSettings, pyqtProperty, pyqtSignal

class DMSettings(QSettings):
	lastPlayedFileChanged = pyqtSignal(str)
	lastOpenedPathChanged = pyqtSignal(str)
	lastOpenedPlaylistPathChanged = pyqtSignal(str)
	lastWindowWidthChanged = pyqtSignal(int)

	def __init__(self):
		super(DMSettings, self).__init__()

	@pyqtProperty(str, notify=lastPlayedFileChanged)
	def lastPlayedFile(self):
	    return self.value("last_played_file", "")

	@lastPlayedFile.setter
	def lastPlayedFile(self, value):
	    self.setValue("last_played_file", value)
	    self.lastPlayedFileChanged.emit(value)

	@pyqtProperty(str, notify=lastOpenedPathChanged)
	def lastOpenedPath(self):
	    return self.value("last_opened_path", "")

	@lastOpenedPath.setter
	def lastOpenedPath(self, value):
	    value = value.replace("file://", "")
	    value = os.path.dirname(value) if os.path.isfile(value) else value
	    self.setValue("last_opened_path", value)
	    self.lastOpenedPathChanged.emit(value)

	@pyqtProperty(str, notify=lastOpenedPlaylistPathChanged)
	def lastOpenedPlaylistPath(self):
	    return self.value("last_opened_playlist_path", "")

	@lastOpenedPlaylistPath.setter
	def lastOpenedPlaylistPath(self, value):
	    value = value.replace("file://", "")
	    value = os.path.dirname(value) if os.path.isfile(value) else value
	    self.setValue("last_opened_playlist_path", value)
	    self.lastOpenedPlaylistPathChanged.emit(value)

	@pyqtProperty(int, notify=lastWindowWidthChanged)
	def lastWindowWidth(self):
	    return int(self.value("last_window_width", 0))

	@lastWindowWidth.setter
	def lastWindowWidth(self, value):
	    self.setValue("last_window_width", value)
	    self.lastWindowWidthChanged.emit(value)
