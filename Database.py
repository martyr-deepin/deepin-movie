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

from PyQt5.QtCore import pyqtSlot, QObject
from Constant import CONFIG_DIR
import os
import sqlite3
from deepin_utils.file import touch_file

class Database(QObject):
    def __init__(self):
        QObject.__init__(self)
        self.video_db_path = os.path.join(CONFIG_DIR, "video_db")
        touch_file(self.video_db_path)
        self.video_db_connect = sqlite3.connect(self.video_db_path)
        self.video_db_cursor = self.video_db_connect.cursor()
        
        self.video_db_cursor.execute(
            "CREATE TABLE IF NOT EXISTS video_db(video_path PRIMARY KEY NOT NULL, video_position)"
            )
    
    @pyqtSlot(str, int, result=bool)    
    def record_video_position(self, video_path, video_position):
        self.video_db_cursor.execute(
            "INSERT OR REPLACE INTO video_db VALUES(?, ?)", 
            (unicode(video_path), str(video_position))
            )
        self.video_db_connect.commit()
        
        return True
    
    @pyqtSlot(str, result=int)
    def fetch_video_position(self, video_path):
        self.video_db_cursor.execute(
            "SELECT video_position FROM video_db WHERE video_path=?" , [video_path])
        results = self.video_db_cursor.fetchall()
        if len(results) > 0:
            return int(results[0][0])
        else:
            return 0
