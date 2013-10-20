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

from PyQt5.QtWidgets import QApplication, qApp
from PyQt5.QtQuick import QQuickView
from PyQt5.QtQml import qmlRegisterType
from PyQt5.QtGui import QSurfaceFormat, QImage, QPainter, QPainterPath
from PyQt5 import QtCore, QtQuick
from PyQt5.QtCore import QSize, pyqtProperty, pyqtSignal
from PyQt5.Qt import QColor
from PyQt5.QtQuick import QQuickPaintedItem
import os
import sys
import signal
from contextlib import contextmanager 
import traceback

@contextmanager
def painter_state(painter):
    painter.save()
    try:  
        yield  
    except Exception, e:  
        print 'function cairo_state got error: %s' % e  
        traceback.print_exc(file=sys.stdout)
    else:  
        painter.restore()

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
                path = QPainterPath()
                if self._radius > 0:
                    path.addRoundedRect(0, 0, self.width(), self.height(), self._radius, self._radius)
                    painter.setRenderHint(QPainter.Antialiasing)
                    painter.setClipPath(path)
                painter.drawImage(0, 0, self._image)

if __name__ == "__main__":
    app = QApplication(sys.argv)
    
    qmlRegisterType(ImageCanvas, "ImageCanvas", 1, 0, "ImageCanvas")
    
    view = QQuickView()
    
    qml_context = view.rootContext()
    qml_context.setContextProperty("windowView", view)
    qml_context.setContextProperty("qApp", qApp)
    
    view.setResizeMode(QtQuick.QQuickView.SizeRootObjectToView)
    view.setMinimumSize(QSize(600, 400))
    
    surface_format = QSurfaceFormat()
    surface_format.setAlphaBufferSize(8)
    view.setFormat(surface_format)
    
    view.setColor(QColor(0, 0, 0, 0))
    view.setFlags(QtCore.Qt.FramelessWindowHint)
    view.setSource(QtCore.QUrl.fromLocalFile(os.path.join(os.path.dirname(__file__), 'main.qml')))
    view.show()
    
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    sys.exit(app.exec_())
