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

_HOME = os.path.expanduser('~')
XDG_CONFIG_HOME = os.environ.get('XDG_CONFIG_HOME') or \
            os.path.join(_HOME, '.config')
PROJECT_NAME = "deepin-movie"
CONFIG_DIR = os.path.join(XDG_CONFIG_HOME, PROJECT_NAME)
MAIN_QML = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'main.qml')

DEFAULT_WIDTH = 840
DEFAULT_HEIGHT = 560
MINIMIZE_WIDTH = 320
MINIMIZE_HEIGHT = 180
WINDOW_GLOW_RADIUS = 8
