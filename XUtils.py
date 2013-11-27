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

from PyQt5.QtCore import pyqtSlot, QObject
import xcb
import xcb.xproto

class XObject(QObject):

    def __init__(self):
        QObject.__init__(self)
        self.conn = xcb.connect()
        self.screen = self.conn.get_setup().roots[0]
        self.root = self.screen.root
        self.screen_width = self.screen.width_in_pixels
        self.screen_height = self.screen.height_in_pixels
            
    @pyqtSlot(result="QVariant")
    def get_pointer_coordiante(self):
        pointer = self.conn.core.QueryPointer(self.root).reply()
        return [pointer.root_x, pointer.root_y]
