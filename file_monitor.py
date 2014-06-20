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
from PyQt5.QtCore import QFileSystemWatcher, pyqtSignal, pyqtSlot

class FileMonitor(QFileSystemWatcher):
	fileMissing = pyqtSignal(str, arguments=["file",])
	fileBack = pyqtSignal(str, arguments=["file",])

	def __init__(self):
		super(FileMonitor, self).__init__()
		self._monitored_files = []
		self.directoryChanged.connect(self.directoryChangedCallback)

	def directoryChangedCallback(self, changedDir):
		for file in self._monitored_files:
			if file.startswith(changedDir):
				if os.path.exists(file):
					self.fileBack.emit(file)
				else:
					self.fileMissing.emit(file)

	@pyqtSlot(str, result=bool)
	def addFile(self, file):
		file = file[7:] if file.startswith("file://") else file
		self._monitored_files.append(file)

		if os.path.exists(file):
			self.addPath(os.path.dirname(file))
			return True
		else:
			return False