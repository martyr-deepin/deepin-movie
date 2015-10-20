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
import json
from contextlib import contextmanager
from peewee import *
from PyQt5.QtCore import QObject, QTimer, pyqtSlot, pyqtSignal
from xml.dom.minidom import (Element, getDOMImplementation, parse)
from utils.constants import DATABASE_FILE, PLAYLIST_CACHE_FILE
from utils.utils import utils
from utils.movieinfo_crawler import CrawlerManager

TAG_CATEGORY = "Category"
TAG_ITEM = "Item"
_database_file = SqliteDatabase(DATABASE_FILE)
_database_file.connect()

# FIXME: a work-around here, if we manually called Database.begin and
# didn't end it with Database.commit, Database.transation and Database.atomic
# will throw an OperationError exception.
_database_in_transaction = False

class DMPlaylistCategory(Element):
    def __init__(self, ownerDocument, name=""):
        Element.__init__(self, TAG_CATEGORY)
        self.name = name
        self.ownerDocument = ownerDocument
        self._items = []

        self.setAttribute("name", self.name)

    def appendItem(self, name, source, played=""):
        item = self._getItemBySource(source)
        if not item:
            item = DMPlaylistItem(self.ownerDocument, name, source, played)
            self.appendChild(item)
            self._items.append(item)
        return item

    def _getItemBySource(self, source):
        for item in self._items:
            if item.source == source:
                return item
        return None

    def getAllItems(self):
        return self._items


class DMPlaylistItem(Element):
    def __init__(self, ownerDocument, name="", source="", played=""):
        Element.__init__(self, TAG_ITEM)
        self.name = name
        self.source = source
        self.played = played
        self.ownerDocument = ownerDocument

        self.setAttribute("source", self.source)
        self.setAttribute("played", self.played)
        self.appendChild(self.ownerDocument.createTextNode(self.name))


class DMPlaylist(object):
    """Each DMPlaylist object represents a playlist file of DMovie"""

    @classmethod
    def readFrom(cls, filename):
        f_exists = os.path.exists(filename)
        return DMPlaylist(filename) if f_exists else DMPlaylist()

    def __init__(self, filename=""):
        super(DMPlaylist, self).__init__()
        self.document = parse(filename) if filename \
                        else getDOMImplementation().createDocument(None,
                                                            "DMPlaylist", None)
        self._categories = []
        self._items = []

        for node in self.document.documentElement.childNodes:
            if hasattr(node, "tagName"):
                if node.tagName == TAG_CATEGORY:
                    category = DMPlaylistCategory(self.document,
                                                node.getAttribute("name"))
                    for child in node.childNodes:
                        if hasattr(child, "tagName"):
                            childName = "".join(map(lambda x: x.data.strip(),
                                child.childNodes))
                            item = DMPlaylistItem(self.document,
                                childName,
                                child.getAttribute("source"),
                                child.getAttribute("played"))
                            category._items.append(item)
                    self._categories.append(category)
                elif node.tagName == TAG_ITEM:
                    childName = "".join(map(lambda x: x.data.strip(),
                        node.childNodes))
                    item = DMPlaylistItem(self.document,
                        childName,
                        node.getAttribute("source"),
                        node.getAttribute("played"))
                    self._items.append(item)


    def appendCategory(self, name):
        category = self._getCategoryByName(name)
        if not category:
            category = DMPlaylistCategory(self.document, name)
            root_ele = self.document.documentElement
            root_ele.appendChild(category)
            self._categories.append(category)
        return category

    def appendItem(self, name, source, played=""):
        item = self._getItemBySource(source)
        if not item:
            item = DMPlaylistItem(self.document, name, source, played)
            root_ele = self.document.documentElement
            root_ele.appendChild(item)
            self._items.append(item)
        return item

    def _getCategoryByName(self, name):
        for cate in self._categories:
            if cate.name == name:
                return cate
        return None

    def _getItemBySource(self, source):
        for item in self._items:
            if item.source == source:
                return item
        return None

    def getAllCategories(self):
        return self._categories

    def getAllItems(self):
        return self._items

    def writeTo(self, filename):
        try:
            with open(filename, 'w') as writer:
                self.document.writexml(writer, '', ' '*4, '\n')
        except Exception, e:
            print "debug", e

class PlaylistCategoryModel(Model):
    name = CharField()
    info = CharField(null=True)

    class Meta:
        database = _database_file

class PlaylistItemModel(Model):
    name = CharField()
    url = CharField()
    info = CharField(null=True)
    category = ForeignKeyField(PlaylistCategoryModel, null=True)

    class Meta:
        database = _database_file

class PlayHistoryItemModel(Model):
    url = CharField()

    class Meta:
        database = _database_file

class Database(QObject):
    playlistItemAdded = pyqtSignal(str, str, str,
        arguments=["name", "url", "category"])
    importDone = pyqtSignal(str, arguments=["filename"])
    itemVInfoGot = pyqtSignal(str, str, arguments=["url", "vinfo"])

    def __init__(self):
        super(Database, self).__init__()
        self._crawlerManager = CrawlerManager()
        self._playHistoryCursor = len(self._getPlayHistory()) - 1

        self._initDelayTimer()
        self._crawlerManager.infoGot.connect(self.crawlerGotInfo)

    def _initDelayTimer(self):
        self._delayCommitTimer = QTimer()
        self._delayCommitTimer.setSingleShot(True)
        self._delayCommitTimer.setInterval(500)
        self._delayCommitTimer.timeout.connect(self._delayCommitOver)

    @contextmanager
    def _delayCommit(self):
        global _database_in_transaction

        _database_file.set_autocommit(False)
        if not _database_in_transaction:
            _database_file.begin()
            _database_in_transaction = True
        yield
        _database_file.set_autocommit(True)
        self._delayCommitTimer.start()

    def _delayCommitOver(self):
        global _database_in_transaction

        _database_file.commit()
        _database_in_transaction = False

    @contextmanager
    def _commitOnSuccess(self):
        global _database_in_transaction

        _database_file.set_autocommit(False)
        if not _database_in_transaction:
            _database_file.begin()
            _database_in_transaction = True
        yield
        _database_file.commit()
        _database_in_transaction = False
        _database_file.set_autocommit(True)

    # internal helper functions
    def _getPlayHistory(self):
        tuples = PlayHistoryItemModel.select(PlayHistoryItemModel.url).order_by(
            PlayHistoryItemModel.id.asc()).tuples()
        return map(lambda x: x[0], tuples) if tuples else []

    def _getOrNewPlaylistCategory(self, categoryName):
        try:
            category = PlaylistCategoryModel.get(
                PlaylistCategoryModel.name == categoryName)
        except DoesNotExist:
            category = PlaylistCategoryModel.create(name=categoryName)

        return category

    def _getOrNewPlaylistItem(self, itemName, itemUrl):
        try:
            item = PlaylistItemModel.get(
                PlaylistItemModel.url == itemUrl)
        except DoesNotExist:
            item = PlaylistItemModel.create(name=itemName, url=itemUrl)

        return item

    @pyqtSlot(str, str)
    def crawlerGotInfo(self, url, result):
        self.itemVInfoGot.emit(url, result)
        self.setPlaylistItemVInfo(url, result)

    # Playlist operations
    @pyqtSlot(result=str)
    def getPlaylistContent(self):
        queryResults = PlaylistItemModel \
        .select(PlaylistItemModel,) \
        .join(PlaylistCategoryModel, JOIN_LEFT_OUTER) \
        .aggregate_rows()

        contentCache = []
        if os.path.exists(PLAYLIST_CACHE_FILE):
            with open(PLAYLIST_CACHE_FILE) as _file:
                _cache = _file.read()
                contentCache = json.loads(_cache)

        if len(contentCache) == queryResults.count():
            return json.dumps(contentCache)
        else:
            content = []
            for result in queryResults:
                category = result.category.name if result.category else ""
                content.append({
                    "category": category,
                    "name": result.name,
                    "url": result.url
                    })
            return json.dumps(content)

    @pyqtSlot(str)
    def setPlaylistContentCache(self, cache):
        with open(PLAYLIST_CACHE_FILE, "w") as _file:
            _file.write(cache.encode("utf-8"))

    @pyqtSlot(str, result=bool)
    def containsPlaylistItem(self, itemUrl):
        try:
            PlaylistItemModel.get(PlaylistItemModel.url == itemUrl)
        except DoesNotExist:
            return False
        return True

    @pyqtSlot(str, result=bool)
    def containsPlaylistCategory(self, categoryName):
        try:
            PlaylistCategoryModel.get(
                PlaylistCategoryModel.name == categoryName)
        except DoesNotExist:
            return False
        return True

    @pyqtSlot(str, str, str)
    def addPlaylistItem(self, itemName, itemUrl, categoryName):
        if not self.containsPlaylistItem(itemUrl):
            item = PlaylistItemModel.create(name=itemName, url=itemUrl)
            if categoryName:
                item.category = self._getOrNewPlaylistCategory(categoryName)
                item.save()
            self.playlistItemAdded.emit(itemName, itemUrl, categoryName)

    @pyqtSlot(str)
    def addPlaylistCategory(self, categoryName):
        self._getOrNewPlaylistCategory(categoryName)

    @pyqtSlot(str)
    def addPlaylistCITuples(self, tuples):
        with self._commitOnSuccess():
            tuples = json.loads(tuples)
            for tuple in tuples:
                category = tuple[0]
                url = tuple[1]
                urlIsNativeFile = utils.urlIsNativeFile(url)

                result = os.path.basename(url)
                itemName =  result if urlIsNativeFile else url

                self.addPlaylistItem(itemName, url, category)

    @pyqtSlot(str)
    def removePlaylistItem(self, itemUrl):
        try:
            target = PlaylistItemModel.get(
                PlaylistItemModel.url == itemUrl)
            target.delete_instance()
            # TODO: remove empty category here
        except DoesNotExist:
            pass

    @pyqtSlot(str)
    def removePlaylistCategory(self, categoryName):
        with self._commitOnSuccess():
            try:
                itemsInCategory = PlaylistItemModel \
                .select(PlaylistItemModel, PlaylistCategoryModel) \
                .join(PlaylistCategoryModel, JOIN_LEFT_OUTER) \
                .where(PlaylistCategoryModel.name == categoryName)
                for item in itemsInCategory:
                    item.delete_instance()

                target = PlaylistCategoryModel.get(
                    PlaylistCategoryModel.name == categoryName)
                target.delete_instance()
            except DoesNotExist:
                pass

    @pyqtSlot()
    def clearPlaylist(self):
        PlaylistCategoryModel.delete().execute()
        PlaylistItemModel.delete().execute()
        PlayHistoryItemModel.delete().execute()

    @pyqtSlot(str)
    def exportPlaylist(self, filename):
        playlist = DMPlaylist()

        queryResults = PlaylistItemModel \
        .select(PlaylistItemModel,) \
        .join(PlaylistCategoryModel, JOIN_LEFT_OUTER) \
        .aggregate_rows()

        for result in queryResults:
            info = json.loads(result.info) if result.info else {}
            played = str(info.get("played")) or ""
            if result.category:
                cate = playlist.appendCategory(
                    result.category.name.encode("utf-8"))
                cate.appendItem(result.name.encode("utf-8"),
                    result.url.encode("utf-8"), played)
            else:
                playlist.appendItem(result.name.encode("utf-8"),
                    result.url.encode("utf-8"), played)

        playlist.writeTo(filename)

    @pyqtSlot(str)
    def importPlaylist(self, filename):
        with self._commitOnSuccess:
            playlist = DMPlaylist.readFrom(filename)
            for category in playlist.getAllCategories():
                for item in category.getAllItems():
                    self.addPlaylistCategory(category.name)
                    self.addPlaylistItem(item.name, item.source, category.name)
                    self.setPlaylistItemPlayed(item.source, item.played)
            for item in playlist.getAllItems():
                self.addPlaylistItem(item.name, item.source, "")
                self.setPlaylistItemPlayed(item.source, item.played)

        self.importDone.emit(filename)

    @pyqtSlot(str, result=int)
    def getPlaylistItemPlayed(self, itemUrl):
        try:
            item = PlaylistItemModel.get(
                PlaylistItemModel.url == itemUrl)
            info = json.loads(item.info) if item.info else {}
            return info.get("played") or 0
        except DoesNotExist:
            return 0

    @pyqtSlot(str, int)
    def setPlaylistItemPlayed(self, itemUrl, itemPlayed):
        try:
            item = PlaylistItemModel.get(
                PlaylistItemModel.url == itemUrl)
            info = json.loads(item.info) if item.info else {}
            info["played"] = itemPlayed
            item.info = json.dumps(info)
            item.save()
        except DoesNotExist:
            pass

    @pyqtSlot(str, result=int)
    def getPlaylistItemRotation(self, itemUrl):
        try:
            item = PlaylistItemModel.get(
                PlaylistItemModel.url == itemUrl)
            info = json.loads(item.info) if item.info else {}
            return info.get("rotation") or 0
        except DoesNotExist:
            return 0

    @pyqtSlot(str, int)
    def setPlaylistItemRotation(self, itemUrl, itemRotation):
        try:
            item = PlaylistItemModel.get(
                PlaylistItemModel.url == itemUrl)
            info = json.loads(item.info) if item.info else {}
            info["rotation"] = itemRotation
            item.info = json.dumps(info)
            item.save()
        except DoesNotExist:
            pass

    @pyqtSlot(str, result=str)
    def getPlaylistItemSubtitle(self, itemUrl):
        try:
            item = PlaylistItemModel.get(
                PlaylistItemModel.url == itemUrl)
            info = json.loads(item.info) if item.info else {}
            subtitle = info.get("subtitle") or ""
            if subtitle.startswith("{") and subtitle.endswith("}"):
                return subtitle
            else:
                return json.dumps({"path": subtitle, "delay": 0})
        except DoesNotExist:
            return ""

    @pyqtSlot(str, str, int)
    def setPlaylistItemSubtitle(self, itemUrl, subtitle, delay):
        try:
            with self._delayCommit():
                item = PlaylistItemModel.get(
                    PlaylistItemModel.url == itemUrl)
                info = json.loads(item.info) if item.info else {}
                info["subtitle"] = json.dumps({"path": subtitle, "delay": delay})
                item.info = json.dumps(info)
                item.save()
        except DoesNotExist:
            pass

    # this getter is asynchronized because there's maybe some items that has no
    # video_info stored, so you need connect to the itemVInfoGot signal to
    # respond to this getter.
    @pyqtSlot(str)
    def getPlaylistItemVInfo(self, itemUrl):
        try:
            item = PlaylistItemModel.get(
                PlaylistItemModel.url == itemUrl)
            info = json.loads(item.info) if item.info else {}
            if info.get("video_info"):
                self.itemVInfoGot.emit(itemUrl, info.get("video_info"))
            else:
                self._crawlerManager.crawl(itemUrl, True)
        except DoesNotExist:
            self._crawlerManager.crawl(itemUrl, True)

    def setPlaylistItemVInfo(self, itemUrl, videoInfo):
        try:
            item = PlaylistItemModel.get(
                PlaylistItemModel.url == itemUrl)
            info = json.loads(item.info) if item.info else {}
            info["video_info"] = videoInfo
            item.info = json.dumps(info)
            item.save()
        except DoesNotExist:
            pass

    # Play history operations
    @pyqtSlot()
    def clearPlayHistory(self):
        PlayHistoryItemModel.delete().execute()
        self._playHistoryCursor = len(self._getPlayHistory()) - 1

    @pyqtSlot(str, bool)
    def appendPlayHistoryItem(self, itemUrl, resetCursor):
        PlayHistoryItemModel.create(url=itemUrl)
        if resetCursor:
            self._playHistoryCursor = len(self._getPlayHistory()) - 1

    @pyqtSlot(result=str)
    def playHistoryGetPrevious(self):
        playHistory = self._getPlayHistory()
        self._playHistoryCursor = max(0, self._playHistoryCursor - 1)
        if playHistory:
            return playHistory[self._playHistoryCursor]
        else:
            return ""

_database_file.create_tables([
    PlaylistCategoryModel,
    PlaylistItemModel,
    PlayHistoryItemModel],
    safe=True)
database = Database()

if __name__ == "__main__":
    helloCategory = PlaylistCategoryModel.create(name="hello")
    worldCategory = PlaylistCategoryModel.create(name="world")
    hello1 = PlaylistItemModel.create(name="hello1", url="/home/hello1")
    hello2 = PlaylistItemModel.create(name="hello2", url="/home/hello2")
    hello3 = PlaylistItemModel.create(name="hello3", url="/home/hello3")
    world1 = PlaylistItemModel.create(name="world1", url="/home/world1")
    world2 = PlaylistItemModel.create(name="world2", url="/home/world2")
    hello1.category = helloCategory
    hello2.category = helloCategory
    hello3.category = helloCategory
    world1.category = worldCategory
    world2.category = worldCategory
    hello1.save()
    hello2.save()
    hello3.save()
    world1.save()
    world2.save()

    historyOne = PlayHistoryItemModel.create(url="12345666666666666")
    historyTwo = PlayHistoryItemModel.create(url="1234566")
    historyThree = PlayHistoryItemModel.create(url="123456xxxxxxxxxxxxx")

    # histOne = PlayHistoryItemModel.get(PlayHistoryItemModel.url=="12345666666666666")
    # maxIndex = PlayHistoryItemModel.select(fn.Max(PlayHistoryItemModel.index)).aggregate()
    # histOne.delete_instance()
    # PlayHistoryItemModel.create(url=histOne.url)
    print database.playHistoryGetPrevious()
    print database.playHistoryGetPrevious()
    database.appendPlayHistoryItem("xxxxxxxxxxxxxxx", True)
    print database.playHistoryGetPrevious()
    print database.playHistoryGetPrevious()
    print database.playHistoryGetPrevious()

    database.getPlaylistContent()
