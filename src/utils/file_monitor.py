#! /usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (C) 2014 Deepin Technology Co., Ltd.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.

import os
from PyQt5.QtCore import QFileSystemWatcher, QFile, pyqtSignal, pyqtSlot

def longest_path_exist_matches_path(path):
    if os.path.exists(path) or path == "/":
        return path
    else:
        return longest_path_exist_matches_path(os.path.dirname(path))

# Note: the FileMonitor class is solely used by the Playlist module, so if
# you have any concern about its function, please consider the use case first.
class FileMonitor(QFileSystemWatcher):
    fileExistenceChanged = pyqtSignal(str, bool, arguments=["file", "existence"])

    def __init__(self):
        super(FileMonitor, self).__init__()
        self._monitored_files = {}
        self.directoryChanged.connect(self.directoryChangedCallback)

    def directoryChangedCallback(self, changedDir):
        for file in self._monitored_files:
            if file.startswith(changedDir):
                fileExistence = QFile(file).exists()
                if fileExistence != self._monitored_files[file]:
                    self._monitored_files[file] = fileExistence
                    self.fileExistenceChanged.emit(file, fileExistence)

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
        result = True
        file = file.replace("file://", "")

        if file.startswith("/"):
            if file: self.addPath(longest_path_exist_matches_path(
                os.path.dirname(file)))
            result = os.path.exists(file)
            self._monitored_files.setdefault(file, result)

        return result