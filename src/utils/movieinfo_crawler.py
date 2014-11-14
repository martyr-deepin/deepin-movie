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
from collections import deque
from PyQt5.QtCore import pyqtSignal, QThread

from models.movie_info import MovieInfo

class _MovieInfoCrawler(QThread):
	died = pyqtSignal(str, str, arguments=["url", "result"])

	def __init__(self, url):
		super(_MovieInfoCrawler, self).__init__()
		self.url = url

	def run(self):
		self._movieInfo = MovieInfo(self.url)
		result = {
		    "movie_title": self._movieInfo.movie_title,
		    "movie_type": self._movieInfo.movie_type,
		    "movie_width": self._movieInfo.movie_width,
		    "movie_height": self._movieInfo.movie_height,
		    "movie_path": self._movieInfo.movie_file,
		    "movie_size": self._movieInfo.movie_size,
		    "movie_duration": self._movieInfo.movie_duration
		}
		self.died.emit(self.url, json.dumps(result))

class CrawlerManager(QThread):
	infoGot = pyqtSignal(str, str, arguments=["url", "result"])

	def __init__(self):
		super(CrawlerManager, self).__init__()
		self._crawlers = []
		self._urls_to_crawl = deque()

	def _tryGetIdleCrawler(self):
		for crawler in self._crawlers:
			if crawler.isFinished():
				return crawler
		return None

	def crawlerDied(self, url, result):
		self.infoGot.emit(url, result)
		if len(self._urls_to_crawl) != 0:
			crawler = self._tryGetIdleCrawler()
			if crawler:
				crawler.url = self._urls_to_crawl.popleft()
				crawler.start()

	def crawl(self, url, highPriority=False):
		if len(self._crawlers) < 5 or highPriority:
			crawler = _MovieInfoCrawler(url)
			crawler.died.connect(self.crawlerDied)
			crawler.start()
			self._crawlers.append(crawler)
		else:
			crawler = self._tryGetIdleCrawler()
			if crawler:
				crawler.url = url
				crawler.start()
			else:
				self._urls_to_crawl.append(url)

	def crawlMany(self, urls):
		for _url in urls:
			self.craw(_url)