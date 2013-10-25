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

from PyQt5.QtQuick import QQuickPaintedItem
from PyQt5.QtCore import pyqtProperty, pyqtSignal
from PyQt5.QtGui import QImage, QPainter, QPainterPath
from Utils import painter_state

class ImageCanvas(QQuickPaintedItem):
    @pyqtProperty(str)
    def imageFile(self):
        return self._imageFile
    
    @imageFile.setter
    def imageFile(self, imageFile):
        self._imageFile = imageFile
        self._image = QImage(self._imageFile)
        
    radiusChanged = pyqtSignal()    
        
    @pyqtProperty(float, notify=radiusChanged)
    def radius(self):
        return self._radius
    
    @radius.setter
    def radius(self, radius):
        self._radius = radius
        self.update()
        self.radiusChanged.emit()
        
    def __init__(self, parent=None):
        super(ImageCanvas, self).__init__(parent)
        
        self._imageFile = ''
        self._image = None
        self._radius = 0
        
    def paint(self, painter):
        if self._image:
            with painter_state(painter):
                painter.setRenderHint(QPainter.Antialiasing, True)
                if self._radius > 0:
                    path = QPainterPath()
                    path.addRoundedRect(0, 0, self.width(), self.height(), self._radius, self._radius)
                    painter.setClipPath(path)
                painter.drawImage(0, 0, self._image)

