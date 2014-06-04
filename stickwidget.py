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

from PyQt5.QtWidgets import QWidget, QVBoxLayout
from PyQt5.QtCore import Qt
from deepin_utils.xutils import xlib_display, init_xlib, get_window_by_id

class StickWidget(QWidget):

    def __init__(self):
        super(StickWidget, self).__init__()
        self.xid = self.winId().__int__()        
        self.xwindow = get_window_by_id(self.xid)
        
        self.setWindowFlags(Qt.FramelessWindowHint)
        self.setAttribute(Qt.WA_TranslucentBackground, True)
        
        self.setContentsMargins(0, 0, 0, 0)
        self.layout = QVBoxLayout(self)
        self.layout.setContentsMargins(0, 0, 0, 0)
        self.setLayout(self.layout)
        
    @init_xlib    
    def show_with_parent(self, parent_xid, x, y, width, height):    
        self.resize(width, height)
        
        parent_xwindow = get_window_by_id(parent_xid)
        self.xwindow.reparent(parent_xwindow, x, y)
        xlib_display.sync()
        
        self.show()
