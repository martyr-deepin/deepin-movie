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
import json
import sqlite3
from constant import CONFIG_DIR
from deepin_utils.file import touch_file
from PyQt5.QtCore import pyqtSlot, pyqtSignal, pyqtProperty, QObject, QTimer

from playlist import DMPlaylist

class Database(QObject):
    localPlaylistChanged = pyqtSignal(str)
    lastPlayedFileChanged = pyqtSignal(str)
    lastOpenedPathChanged = pyqtSignal(str)
    lastOpenedPlaylistPathChanged = pyqtSignal(str)
    lastWindowWidthChanged = pyqtSignal(int)
    playHistoryChanged = pyqtSignal()

    clearPlaylistItems = pyqtSignal()
    importItemFound = pyqtSignal(str, str, str, str,
        arguments=["categoryName", "itemName", "itemUrl", "itemPlayed"])
    importDone = pyqtSignal(str, arguments=["filename"])

    def __init__(self):
        QObject.__init__(self)
        self.video_db_path = os.path.join(CONFIG_DIR, "video_db")
        touch_file(self.video_db_path)
        self.video_db_connect = sqlite3.connect(self.video_db_path)
        self.video_db_cursor = self.video_db_connect.cursor()

        self.video_db_cursor.execute(
            "CREATE TABLE IF NOT EXISTS settings(key PRIMARY KEY NOT NULL, value)"
        )

        self._commit_timer = QTimer()
        self._commit_timer.setInterval(500)
        self._commit_timer.setSingleShot(True)
        self._commit_timer.timeout.connect(lambda: self.video_db_connect.commit())

    @pyqtSlot()
    def forceCommit(self):
        self.video_db_connect.commit()

    @pyqtSlot(str, int)
    def record_video_position(self, video_path, video_position):
        movieInfo = json.loads(self.getMovieInfo(video_path))
        movieInfo["position"] = video_position
        self.updateMovieInfo(video_path, json.dumps(movieInfo))

    @pyqtSlot(str, result=int)
    def fetch_video_position(self, video_path):
        movieInfo = json.loads(self.getMovieInfo(video_path))
        return int(movieInfo.get("position", 0))

    @pyqtSlot(str, int)
    def record_video_rotation(self, video_path, video_rotation):
        movieInfo = json.loads(self.getMovieInfo(video_path))
        movieInfo["rotation"] = video_rotation
        self.updateMovieInfo(video_path, json.dumps(movieInfo))

    @pyqtSlot(str, result=int)
    def fetch_video_rotation(self, video_path):
        movieInfo = json.loads(self.getMovieInfo(video_path))
        return int(movieInfo.get("rotation", 0))

    def getValue(self, key):
        self.video_db_cursor.execute(
            "SELECT value FROM settings WHERE key=?", (key,)
        )
        result = self.video_db_cursor.fetchone()

        return result[0] if result else ""

    def setValue(self, key, value):
        self.video_db_cursor.execute(
            "INSERT OR REPLACE INTO settings VALUES(?, ?)", (key, value)
        )
        self._commit_timer.start()

    @pyqtSlot(str,result=str)
    def getMovieInfo(self, video_path):
        value = self.getValue(video_path)
        return value if (value.startswith("{") and value.endswith("}")) else "{}"

    @pyqtSlot(str,str,result=str)
    def updateMovieInfo(self, video_path, info):
        self.setValue(video_path, info)

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
        if not value in self.playHistory:
            playHistory = self.playHistory
            playHistory.append(value)
            self.setValue("play_history", json.dumps(playHistory))

    @pyqtProperty("QVariant",notify=playHistoryChanged)
    def playHistory(self):
        historyStr = self.getValue("play_history") or "[]"
        return json.loads(historyStr)

    @playHistory.setter
    def playHistory(self, value):
        self.setValue("play_history", json.dumps(value))
        self.playHistoryChanged.emit()

    @pyqtProperty(str,notify=lastOpenedPathChanged)
    def lastOpenedPath(self):
        return self.getValue("last_opened_path") or ""

    @lastOpenedPath.setter
    def lastOpenedPath(self, value):
        value = value[7:] if value.startswith("file://") else value
        value = os.path.dirname(value) if os.path.isfile(value) else value
        self.setValue("last_opened_path", value)
        self.lastOpenedPathChanged.emit(value)

    @pyqtProperty(str,notify=lastOpenedPlaylistPathChanged)
    def lastOpenedPlaylistPath(self):
        return self.getValue("last_opened_playlist_path") or ""

    @lastOpenedPlaylistPath.setter
    def lastOpenedPlaylistPath(self, value):
        value = value[7:] if value.startswith("file://") else value
        value = os.path.dirname(value) if os.path.isfile(value) else value
        self.setValue("last_opened_playlist_path", value)
        self.lastOpenedPlaylistPathChanged.emit(value)

    @pyqtProperty(int,notify=lastWindowWidthChanged)
    def lastWindowWidth(self):
        return int(self.getValue("last_window_width") or 0)

    @lastWindowWidth.setter
    def lastWindowWidth(self, value):
        self.setValue("last_window_width", value)
        self.lastWindowWidthChanged.emit(value)

    @pyqtSlot(str)
    def exportPlaylist(self, filename):
        playlist = DMPlaylist()
        playlistItems = json.loads(self.playlist_local)

        for item in playlistItems:
            try:
                itemChild = json.loads(item["itemChild"])
                if len(itemChild) != 0 and item["itemUrl"] == "":
                    cate = playlist.appendCategory(
                        item["itemName"].encode("utf-8"))
                    for child in itemChild:
                        cate.appendItem(child["itemName"].encode("utf-8"),
                            child["itemUrl"].encode("utf-8"),
                            str(self.fetch_video_position(child["itemUrl"])))
                else:
                    playlist.appendItem(item["itemName"].encode("utf-8"),
                        item["itemUrl"].encode("utf-8"),
                        str(self.fetch_video_position(item["itemUrl"])))
            except Exception, e:
                print e

        playlist.writeTo(filename)

    @pyqtSlot(str)
    def importPlaylist(self, filename):
        self.clearPlaylistItems.emit()

        playlist = DMPlaylist.readFrom(filename)
        for category in playlist.getAllCategories():
            for item in category.getAllItems():
                self.importItemFound.emit(category.name, item.name,
                    item.source, item.played)
        for item in playlist.getAllItems():
            self.importItemFound.emit(None, item.name, item.source, item.played)

        self.importDone.emit(filename)

database = Database()
