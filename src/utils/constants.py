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

parent_dir = os.path.dirname

_HOME = os.path.expanduser('~')
XDG_CONFIG_HOME = os.environ.get('XDG_CONFIG_HOME') or \
            os.path.join(_HOME, '.config')
PROJECT_NAME = "deepin-movie"
CONFIG_DIR = os.path.join(XDG_CONFIG_HOME, PROJECT_NAME)
MAIN_QML = os.path.join(parent_dir(parent_dir(os.path.abspath(__file__))),
    'views', 'main.qml')
DATABASE_FILE = os.path.join(CONFIG_DIR, "data.db")
PLAYLIST_CACHE_FILE = os.path.join(CONFIG_DIR, "playlist.cache")

if not os.path.exists(CONFIG_DIR): os.makedirs(CONFIG_DIR)

WINDOW_GLOW_RADIUS = 8
DEFAULT_WIDTH = 840
DEFAULT_HEIGHT = 560
MINIMIZE_WIDTH = 320
MINIMIZE_HEIGHT = 180
