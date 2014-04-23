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

from PyQt5.QtCore import pyqtProperty, pyqtSignal, QObject
from constant import DEFAULT_WIDTH, DEFAULT_HEIGHT
from media_info import parse_info
from logger import logger

class MovieInfo(QObject):
    movieSourceChanged = pyqtSignal(str)
    movieDurationChanged = pyqtSignal(int)
    movieWidthChanged = pyqtSignal(int)
    movieHeightChanged = pyqtSignal(int)

    def __init__(self, filepath=""):
        QObject.__init__(self)

        self.media_info = None
        self.movie_file = filepath
        
    @pyqtProperty(int,notify=movieDurationChanged)
    def movie_duration(self):
        return int(self.media_duration)

    @pyqtProperty(int,notify=movieWidthChanged)
    def movie_width(self):
        return int(self.media_width)

    @pyqtProperty(int,notify=movieHeightChanged)
    def movie_height(self):
        return int(self.media_height)

    @pyqtProperty(str,notify=movieSourceChanged)
    def movie_file(self):
        return self.filepath

    @movie_file.setter
    def movie_file(self, filepath):
        logger.info("set movie_file %s" % filepath)                
        self.filepath = filepath

        self.media_info = parse_info(self.filepath)
        self.media_width = self.media_info["video_width"] or DEFAULT_WIDTH
        self.media_height = self.media_info["video_height"] or DEFAULT_HEIGHT
        self.media_duration = self.media_info["general_duration"] or 0
        
        self.movieSourceChanged.emit(filepath)
        self.movieWidthChanged.emit(self.media_width)
        self.movieHeightChanged.emit(self.media_height)
        self.movieDurationChanged.emit(self.media_duration)        
