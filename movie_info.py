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
import json

from PyQt5.QtCore import QObject, QThread, pyqtProperty, pyqtSignal, pyqtSlot

from subtitles import Parser, SUPPORTED_FILE_TYPES
from constant import DEFAULT_WIDTH, DEFAULT_HEIGHT, WINDOW_GLOW_RADIUS
from media_info import parse_info
from logger import logger
from i18n import _
from utils import utils

def get_subtitle_from_movie(movie_file):
    '''
    movie_file is like file:///home/user/movie.mp4
    '''
    if movie_file.startswith("file://"): movie_file = movie_file[7:]
    dir_name = os.path.dirname(movie_file)
    name_without_ext = movie_file.rpartition(".")[0]
    if name_without_ext == "": return ("",)

    result = []
    for ext in SUPPORTED_FILE_TYPES:
        try_ext = "%s/*.%s" % (dir_name, ext)
        all_this_ext = glob.glob(try_ext)
        result += filter(lambda x: name_without_ext in x, all_this_ext)
    return result or ("",)

class GetMovieInfoThread(QThread):
    infoGotten = pyqtSignal(str)

    def __init__(self, filePath):
        super(GetMovieInfoThread, self).__init__()
        self._filePath = filePath

    def run(self):
        movie_info = MovieInfo(self._filePath)
        result = {
            "movie_title": movie_info.movie_title,
            "movie_type": movie_info.movie_type,
            "movie_width": movie_info.movie_width,
            "movie_height": movie_info.movie_height,
            "movie_path": movie_info.movie_file,
            "movie_size": movie_info.movie_size,
            "movie_duration": movie_info.movie_duration
        }
        self.infoGotten.emit(json.dumps(result))

class MovieInfo(QObject):
    movieSourceChanged = pyqtSignal(str, arguments=["movie_file",])
    movieTitleChanged = pyqtSignal(str, arguments=["movie_title",])
    movieSizeChanged = pyqtSignal(int, arguments=["movie_size",])
    movieTypeChanged = pyqtSignal(str, arguments=["movie_type",])
    movieDurationChanged = pyqtSignal(int, arguments=["movie_duration",])
    movieWidthChanged = pyqtSignal(int, arguments=["movie_width",])
    movieHeightChanged = pyqtSignal(int, arguments=["movie_height",])
    subtitleChanged = pyqtSignal(str, arguments=["subtitle_file",])

    fileInvalid = pyqtSignal()
    infoGotten = pyqtSignal(str, arguments=["movie_info",])

    def __init__(self, filepath=""):
        QObject.__init__(self)

        self.media_info = None
        self.movie_file = filepath

    def parseFile(self, filepath):
        filepath = filepath.replace("file://", "")
        if os.path.exists(filepath):
            self.media_info = parse_info(filepath)
        else:
            self.media_info = {}

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
        return os.path.basename(self.filepath) \
            if utils.urlIsNativeFile(self.filepath) else self.filepath

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

        self.parseFile(filepath)
        self.media_width = self.media_info.get("video_width") or DEFAULT_WIDTH
        self.media_height = self.media_info.get("video_height") or DEFAULT_HEIGHT
        self.media_duration = self.media_info.get("general_duration") or 0
        self.media_size = int(self.media_info.get("general_size") or 0)
        self.media_type = self.media_info.get("general_extension") or  _("Unknown")
        self.media_width = int(self.media_width) + 2 * WINDOW_GLOW_RADIUS
        self.media_height = int(self.media_height) + 2 * WINDOW_GLOW_RADIUS
        self.media_duration = int(self.media_duration)
        self.subtitle_file = get_subtitle_from_movie(self.filepath)[0]

        self.movieTitleChanged.emit(os.path.basename(filepath))
        self.movieTypeChanged.emit(self.media_type)
        self.movieSizeChanged.emit(self.media_size)
        self.movieWidthChanged.emit(self.media_width)
        self.movieHeightChanged.emit(self.media_height)
        self.movieDurationChanged.emit(self.media_duration)
        self.movieSourceChanged.emit(filepath)

        if not (filepath == ""
            or self.media_info == {}
            or utils.fileIsValidVideo(filepath)):
            self.fileInvalid.emit()

    @pyqtSlot(int, result=str)
    def get_subtitle_at(self, timestamp):
        return self._parser.get_subtitle_at(timestamp)

    @pyqtSlot(str)
    def getMovieInfo(self, file_path):
        if file_path == self.movie_file:
            result = {
                "movie_title": movie_info.movie_title,
                "movie_type": movie_info.movie_type,
                "movie_width": movie_info.movie_width,
                "movie_height": movie_info.movie_height,
                "movie_path": movie_info.movie_file,
                "movie_size": movie_info.movie_size,
                "movie_duration": movie_info.movie_duration
            }
            self.infoGotten.emit(json.dumps(result))
        else:
            self._thread = GetMovieInfoThread(file_path)
            self._thread.infoGotten.connect(lambda x: self.infoGotten.emit(x))
            self._thread.start()

    @pyqtSlot()
    def rotate(self):
        self.media_width, self.media_height = self.media_height, self.media_width
        self.movieWidthChanged.emit(self.media_width)
        self.movieHeightChanged.emit(self.media_height)

movie_info = MovieInfo()

if __name__ == '__main__':
    print movie_info.getMovieInfo("/home/hualet/Desktop/HD2.mkv")