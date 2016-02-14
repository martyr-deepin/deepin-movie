#! /usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (C) 2014 Deepin Technology Co., Ltd.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.

import os
import sys
import glob

SUPPORTED_FILE_TYPES = ("ass", "srt")

for type in SUPPORTED_FILE_TYPES:
    setattr(sys.modules[__name__],
        "FILE_TYPE_%s" % type.upper(),
        "__%s__" % type)

def get_file_type(file_name):
    if file_name.endswith("ass") or file_name.endswith("saa"):
        return getattr(sys.modules[__name__], "FILE_TYPE_ASS")
    elif file_name.endswith("srt"):
        return getattr(sys.modules[__name__], "FILE_TYPE_SRT")
    return None

def get_subtitle_from_movie( movie_file):
    movie_file = movie_file.replace("file://", "")
    dir_name = os.path.dirname(movie_file)
    name_without_ext = movie_file.rpartition(".")[0]
    if name_without_ext == "": return ("",)

    result = []
    for ext in SUPPORTED_FILE_TYPES:
        try_ext = "%s/*.%s" % (dir_name, ext)
        all_this_ext = glob.glob(try_ext)
        result += filter(lambda x: name_without_ext in x, all_this_ext)
    return result or ("",)