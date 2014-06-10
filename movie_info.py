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
import glob

from PyQt5.QtCore import pyqtProperty, pyqtSignal, QObject, pyqtSlot

from subtitles import Parser, SUPPORTED_FILE_TYPES
from constant import DEFAULT_WIDTH, DEFAULT_HEIGHT, WINDOW_GLOW_RADIUS
from media_info import parse_info
from logger import logger
from i18n import _

def get_subtitle_from_movie(movie_file):
    '''
    movie_file is like file:///home/user/movie.mp4
    '''
    if movie_file.startswith("file://"): movie_file = movie_file[7:]
    name_without_ext = movie_file.rpartition(".")[0]
    if name_without_ext == "": return ("",)

    result = []
    for ext in SUPPORTED_FILE_TYPES:
        try_sub_name = "%s*.%s" % (name_without_ext, ext)
        result += glob.glob(try_sub_name)
    return result

class MovieInfo(QObject):
    movieSourceChanged = pyqtSignal(str, arguments=["movie_file",])
    movieTitleChanged = pyqtSignal(str, arguments=["movie_title",])
    movieSizeChanged = pyqtSignal(int, arguments=["movie_size",])
    movieTypeChanged = pyqtSignal(str, arguments=["movie_type",])
    movieDurationChanged = pyqtSignal(int, arguments=["movie_duration",])
    movieWidthChanged = pyqtSignal(int, arguments=["movie_width",])
    movieHeightChanged = pyqtSignal(int, arguments=["movie_height",])
    subtitleChanged = pyqtSignal(str, arguments=["subtitle_file",])

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
        
    @pyqtProperty(str,notify=movieTitleChanged)
    def movie_title(self):
        return os.path.basename(self.filepath)

    @pyqtProperty(str,notify=movieTypeChanged)
    def movie_type(self):
        return self.media_type

    @pyqtProperty(int,notify=movieSizeChanged)
    def movie_size(self):
        return self.media_size

    @pyqtProperty(str,notify=subtitleChanged)
    def subtitle_file(self):
        return self._subtitle_file

    @subtitle_file.setter
    def subtitle_file(self, value):
        value = value[7:] if value.startswith("file://") else value
        self._subtitle_file = value
        self.subtitleChanged.emit(value)
        self._parser = Parser(value)
    
    @movie_file.setter
    def movie_file(self, filepath):
        logger.info("set movie_file %s" % filepath)                
        self.filepath = filepath

        self.media_info = parse_info(self.filepath)
        self.media_width = self.media_info["video_width"] or DEFAULT_WIDTH
        self.media_height = self.media_info["video_height"] or DEFAULT_HEIGHT
        self.media_duration = self.media_info["general_duration"] or 0
        self.media_size = int(self.media_info["general_size"] or 0)
        self.media_type = self.media_info["general_format"] or _("unknown")
        self.media_width = int(self.media_width) + 2 * WINDOW_GLOW_RADIUS
        self.media_height = int(self.media_height) + 2 * WINDOW_GLOW_RADIUS
        self.media_duration = int(self.media_duration)

        self.movieSourceChanged.emit(filepath)
        self.movieTitleChanged.emit(os.path.basename(filepath))
        self.movieTypeChanged.emit(self.media_type)
        self.movieSizeChanged.emit(self.media_size)
        self.movieWidthChanged.emit(self.media_width)
        self.movieHeightChanged.emit(self.media_height)
        self.movieDurationChanged.emit(self.media_duration) 

        self.subtitle_file = get_subtitle_from_movie(self.filepath)[0]

    @pyqtSlot(int, result=str)     
    def get_subtitle_at(self, timestamp):
        return self._parser.get_subtitle_at(timestamp)


movie_info = MovieInfo()