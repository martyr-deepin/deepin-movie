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
from PyQt5.QtQuick import QQuickView, QQuickItem
from PyQt5.QtQml import qmlRegisterType
from PyQt5.QtGui import QSurfaceFormat, QColor
from PyQt5 import QtCore, QtQuick
from PyQt5.QtCore import QSize, pyqtSlot, QObject
import os
import sys
import signal
from ImageCanvas import ImageCanvas
from TopRoundRect import TopRoundRect

class Window(QQuickView):

    def __init__(self):
        QQuickView.__init__(self)
        
    @pyqtSlot(result=int)    
    def getState(self):
        return self.windowState()
    
if __name__ == "__main__":
    movie_file = sys.argv[1]
    
    app = QApplication(sys.argv)
    
    qmlRegisterType(ImageCanvas, "ImageCanvas", 1, 0, "ImageCanvas")
    qmlRegisterType(TopRoundRect, "TopRoundRect", 1, 0, "TopRoundRect")
    
    view = Window()
    
    qml_context = view.rootContext()
    qml_context.setContextProperty("windowView", view)
    qml_context.setContextProperty("qApp", qApp)
    qml_context.setContextProperty("movie_file", movie_file)
    
    view.setResizeMode(QtQuick.QQuickView.SizeRootObjectToView)
    view.setMinimumSize(QSize(900, 518))
    
    surface_format = QSurfaceFormat()
    surface_format.setAlphaBufferSize(8)
    view.setFormat(surface_format)
    
    view.setColor(QColor(0, 0, 0, 0))
    view.setFlags(QtCore.Qt.FramelessWindowHint)
    view.setSource(QtCore.QUrl.fromLocalFile(os.path.join(os.path.dirname(__file__), 'Main.qml')))
    view.show()
    
    # view.windowStateChanged.connect(view.rootObject().monitorWindowState)
    
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    sys.exit(app.exec_())
