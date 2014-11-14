#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright (C) 2013 ~ 2014 Deepin, Inc.
#               2013 ~ 2014 Wang Yaohua
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

import json
from PyQt5.QtCore import pyqtSignal, QThread

from movie_info import MovieInfo

class _MovieInfoCrawler(QThread):
	infoGotten = pyqtSignal(str, str)

	def __init__(self, movieFile):
		super(_MovieInfoCrawler, self).__init__()
		self.movieFile = movieFile

	def run(self):
		movieFile = self.movieFile.replace("file://", "")
		self._movieInfo = MovieInfo(movieFile)
		result = {
		    "movie_title": self._movieInfo.movie_title,
		    "movie_type": self._movieInfo.movie_type,
		    "movie_width": self._movieInfo.movie_width,
		    "movie_height": self._movieInfo.movie_height,
		    "movie_path": self._movieInfo.movie_file,
		    "movie_size": self._movieInfo.movie_size,
		    "movie_duration": self._movieInfo.movie_duration
		}
		self.infoGotten.emit(self.movieFile, json.dumps(result))

class CrawlerManager(QThread):
	infoGotten = pyqtSignal(str, str)

	def __init__(self):
		super(CrawlerManager, self).__init__()
		self._crawlers = []

	def crawlerDied(self, movieFile, movieInfo):
		self.infoGotten.emit(movieFile, movieInfo)
		for crawler in self._crawlers:
			if crawler.movieFile == movieFile:
				self._crawlers.remove(crawler)

	def craw(self, file):
		crawler = _MovieInfoCrawler(file)
		crawler.infoGotten.connect(self.crawlerDied)
		crawler.start()
		self._crawlers.append(crawler)

	def crawMany(self, files):
		for _file in files:
			self.craw(_file)