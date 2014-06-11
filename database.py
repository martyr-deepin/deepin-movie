#!/usr/bin/python
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
import sqlite3
from constant import CONFIG_DIR
from deepin_utils.file import touch_file
from PyQt5.QtCore import pyqtSlot, pyqtSignal, pyqtProperty, QObject


class Database(QObject):
    localPlaylistChanged = pyqtSignal(str)
    lastPlayedFileChanged = pyqtSignal(str)
    lastOpenedPathChanged = pyqtSignal(str)
    lastWindowWidthChanged = pyqtSignal(int)

    def __init__(self):
        QObject.__init__(self)
        self.video_db_path = os.path.join(CONFIG_DIR, "video_db")
        touch_file(self.video_db_path)
        self.video_db_connect = sqlite3.connect(self.video_db_path)
        self.video_db_cursor = self.video_db_connect.cursor()
        
        self.video_db_cursor.execute(
            "CREATE TABLE IF NOT EXISTS settings(key PRIMARY KEY NOT NULL, value)"
        )
    
    @pyqtSlot(str, int)    
    def record_video_position(self, video_path, video_position):
        self.video_db_cursor.execute(
            "INSERT OR REPLACE INTO settings VALUES(?, ?)", 
            (unicode(video_path), str(video_position))
        )
        self.video_db_connect.commit()
        
    @pyqtSlot(str, result=int)
    def fetch_video_position(self, video_path):
        self.video_db_cursor.execute(
            "SELECT value FROM settings WHERE key=?" , [video_path]
        )
        results = self.video_db_cursor.fetchall()
        if len(results) > 0:
            return int(results[0][0])
        else:
            return 0
            
    def getValue(self, key):
        self.video_db_cursor.execute(
            "SELECT value FROM settings WHERE key=?", (key,)
        )
        result = self.video_db_cursor.fetchone()
        
        return result and result[0]
        
    def setValue(self, key, value):
        self.video_db_cursor.execute(
            "INSERT OR REPLACE INTO settings VALUES(?, ?)", (key, value)
        )
        self.video_db_connect.commit()
        
    @pyqtProperty(str,notify=localPlaylistChanged)
    def playlist_local(self):
        return self.getValue("playlist_local") or ""
        
    @playlist_local.setter
    def playlist_local(self, value):
        self.setValue("playlist_local", value)
        self.localPlaylistChanged.emit(value)

    @pyqtProperty(str,notify=lastPlayedFileChanged)
    def lastPlayedFile(self):
        return self.getValue("last_played_file") or ""

    @lastPlayedFile.setter
    def lastPlayedFile(self, value):
        self.setValue("last_played_file", value)
        self.lastPlayedFileChanged.emit(value)

    @pyqtProperty(str,notify=lastOpenedPathChanged)
    def lastOpenedPath(self):
        return self.getValue("last_opened_path") or ""

    @lastOpenedPath.setter
    def lastOpenedPath(self, value):
        value = value[7:] if value.startswith("file://") else value
        value = os.path.dirname(value) if os.path.isfile(value) else value
        self.setValue("last_opened_path", value)
        self.lastOpenedPathChanged.emit(value)

    @pyqtProperty(int,notify=lastWindowWidthChanged)
    def lastWindowWidth(self):
        return int(self.getValue("last_window_width") or 0)

    @lastWindowWidth.setter
    def lastWindowWidth(self, value):
        self.setValue("last_window_width", value)
        self.lastWindowWidthChanged.emit(value)

database = Database()
