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
import time
from PyQt5.QtCore import QFileSystemWatcher, QFile, pyqtSignal, pyqtSlot

def longest_path_exist_matches_path(path):
    if os.path.exists(path) or path == "/":
        return path
    else:
        return longest_path_exist_matches_path(os.path.dirname(path))

# Note: the FileMonitor class is solely used by the Playlist module, so if
# you have any concern about its function, please consider the use case first.
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
                if QFile(file).exists():
                    self.fileBack.emit(file)
                else:
                    self.fileMissing.emit(file)

    # this function is used to monitor the existence a uri item in the playlist,
    # there's 3 things I'd like to explain here:
    # 1, the return value here has nothing to do with failure or success, it's
    #    just tell the caller that the file exists or not.
    # 2, I don't monitor files here, but folders instead, otherwise we would
    #    lose the monitoring state if the file's gone.
    # 3, the prefix check in this method just intends to filter urls out of
    #    monitoring.
    @pyqtSlot(str, result=bool)
    def addFile(self, file):
        if file.startswith("file://") or file.startswith("/"):
            file = file.replace("file://", "")
            self._monitored_files.append(file)
            if file: self.addPath(longest_path_exist_matches_path(
                os.path.dirname(file)))

            return os.path.exists(file)
        else:
            return True