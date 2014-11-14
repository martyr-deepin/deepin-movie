#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright (C) 2011 ~ 2012 Deepin, Inc.
#               2011 ~ 2012 Wang Yong
#               2013 ~ 2014 Wang Yaohua
#
# Author:     Wang Yong <lazycat.manatee@gmail.com>
# Maintainer: Wang Yong <lazycat.manatee@gmail.com>
#             Wang Yaohua <mr.asianwang@gmail.com>
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
from utils.constants import DEFAULT_WIDTH, DEFAULT_HEIGHT, WINDOW_GLOW_RADIUS
from utils.media_info import parse_info
from utils.i18n import _
from utils.utils import utils

class MovieInfo(object):
    def __init__(self, filepath=""):
        super(MovieInfo, self).__init__()
        self.media_info = None
        self.movie_file = filepath

    def parseFile(self, filepath):
        filepath = filepath.replace("file://", "")
        if os.path.exists(filepath):
            self.media_info = parse_info(filepath)
        else:
            self.media_info = {}

    @property
    def movie_duration(self):
        return int(self.media_duration)

    @property
    def movie_width(self):
        return int(self.media_width)

    @property
    def movie_height(self):
        return int(self.media_height)

    @property
    def movie_file(self):
        return self.filepath

    @property
    def movie_title(self):
        return utils.getTitleFromUrl(self.filepath)

    @property
    def movie_type(self):
        return self.media_type

    @property
    def movie_size(self):
        return self.media_size

    @movie_file.setter
    def movie_file(self, filepath):
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