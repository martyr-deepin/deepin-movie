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
from PyQt5.QtGui import QPainter, QPainterPath
from PyQt5.QtGui import QColor, QRadialGradient
from Utils import painter_state

class TopRoundRect(QQuickPaintedItem):
    
    radiusChanged = pyqtSignal()    
        
    @pyqtProperty(float, notify=radiusChanged)
    def radius(self):
        return self._radius
    
    @radius.setter
    def radius(self, radius):
        self._radius = radius
        self.update()
        self.radiusChanged.emit()
        
    radialRadiusChanged = pyqtSignal()    
        
    @pyqtProperty(float, notify=radialRadiusChanged)
    def radialRadius(self):
        return self._radialRadius
    
    @radialRadius.setter
    def radialRadius(self, radialRadius):
        self._radialRadius = radialRadius
        self.update()
        self.radialRadiusChanged.emit()
        
    vOffsetChanged = pyqtSignal()    
        
    @pyqtProperty(float, notify=vOffsetChanged)
    def vOffset(self):
        return self._vOffset
    
    @vOffset.setter
    def vOffset(self, vOffset):
        self._vOffset = vOffset
        self.update()
        self.vOffsetChanged.emit()
        
    startColorChanged = pyqtSignal()    
        
    @pyqtProperty(str, notify=startColorChanged)
    def startColor(self):
        return self._startColor
    
    @startColor.setter
    def startColor(self, startColor):
        self._startColor = startColor
        self.update()
        self.startColorChanged.emit()

    endColorChanged = pyqtSignal()    
        
    @pyqtProperty(str, notify=endColorChanged)
    def endColor(self):
        return self._endColor
    
    @endColor.setter
    def endColor(self, endColor):
        self._endColor = endColor
        self.update()
        self.endColorChanged.emit()
        
    def __init__(self, parent=None):
        super(TopRoundRect, self).__init__(parent)
        
        self._radius = 0
        self._radialRadius = 0
        self._vOffset = 0
        self._startColor = None
        self._endColor = None
        
    def paint(self, painter):
        with painter_state(painter):
            painter.setRenderHints(QPainter.Antialiasing, True)
            
            if self._radius > 0:
                path = QPainterPath()
                path.addRoundedRect(0, 0, self.width(), self._radius, self._radius, self._radius)
                path.addRoundedRect(0, self._radius, self.width(), self.height() - self._radius, 0, 0)
                painter.setClipPath(path)
                
            radialGrad = QRadialGradient(self.width() / 2, self._vOffset, self._radialRadius)
            radialGrad.setColorAt(0, QColor(self._startColor))
            radialGrad.setColorAt(0.55, QColor(self._endColor))
            
            painter.setBrush(radialGrad)
            painter.drawRoundedRect(0, 0, self.width(), self.height(), self._radius, self._radius)
        
