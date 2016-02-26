#! /usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (C) 2014 Deepin Technology Co., Ltd.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.

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
