#! /usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (C) 2014 Deepin Technology Co., Ltd.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.

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
        self.media_info = parse_info(filepath)

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
        return utils.getFileNameFromUri(self.filepath)

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

        integer = lambda x: int(float(x)) if x else 0

        self.media_width = integer(self.media_info.get("video_width"))
        self.media_height = integer(self.media_info.get("video_height"))
        self.media_duration = integer(self.media_info.get("general_duration"))
        self.media_size = integer(self.media_info.get("general_size"))
        self.media_type = self.media_info.get("general_extension") or _("Unknown")
        self.media_duration = integer(self.media_duration)
