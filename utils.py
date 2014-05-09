#! /usr/bin/python
# -*- coding: utf-8 -*-

# Copyright (C) 2011 ~ 2012 Deepin, Inc.
#               2011 ~ 2012 Wang Yong
# 
# Author:     Wang Yong <lazycat.manatee@gmail.com>
# Maintainer: Wang Yong <lazycat.manatee@gmail.com>
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
from PyQt5.QtGui import QKeySequence
from PyQt5.QtCore import QObject, pyqtSlot, pyqtProperty

class Utils(QObject):
	"""docstring for Utils"""
	def __init__(self):
		super(Utils, self).__init__()


	@pyqtProperty(str, constant=True)
	def homeDir(self):
	    return os.path.expanduser("~")

	@pyqtSlot(str,result="QVariant")
	def getAllFilesInDir(self, dir):
		dir = dir[7:]
		result = []
		for entry in os.listdir(dir):
			file_abs_path = os.path.join(dir, entry)
			if os.path.isfile(file_abs_path):
				result.append(file_abs_path)
		return result

	@pyqtSlot(int, int, str, result=bool)
	def checkKeySequenceEqual(self, modifier, key, targetKeySequence):
		return QKeySequence(modifier + key) == QKeySequence(targetKeySequence)

	@pyqtSlot(int, int, result=str)
	def keyEventToQKeySequenceString(self, modifier, key):
		return QKeySequence(modifier + key).toString()