#! /usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (C) 2014 Deepin Technology Co., Ltd.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.

import os

from PyQt5.QtCore import QStandardPaths

from i18n import _

parent_dir = os.path.dirname

_HOME = os.path.expanduser('~')
XDG_CONFIG_HOME = os.environ.get('XDG_CONFIG_HOME') or \
            os.path.join(_HOME, '.config')
PROJECT_NAME = "deepin-movie"
CONFIG_DIR = os.path.join(XDG_CONFIG_HOME, PROJECT_NAME)
PROGRAM_DIR = parent_dir(parent_dir(os.path.abspath(__file__)))
DEFAULT_SCREENSHOT_DIR = os.path.join(
    QStandardPaths.writableLocation(QStandardPaths.PicturesLocation),
    _("Deepin Movie"))
MAIN_QML = os.path.join(PROGRAM_DIR, 'views', 'main.qml')
DATABASE_FILE = os.path.join(CONFIG_DIR, "data.db")
PLAYLIST_CACHE_FILE = os.path.join(CONFIG_DIR, "playlist.cache")

if not os.path.exists(CONFIG_DIR):
    os.makedirs(CONFIG_DIR)
if not os.path.exists(DEFAULT_SCREENSHOT_DIR):
    os.makedirs(DEFAULT_SCREENSHOT_DIR)

WINDOW_GLOW_RADIUS = 8
DEFAULT_WIDTH = 840
DEFAULT_HEIGHT = 560
MINIMIZE_WIDTH = 320
MINIMIZE_HEIGHT = 180
