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
from PyQt5.QtGui import QSurfaceFormat, QColor, QCloseEvent
from PyQt5 import QtCore, QtQuick
from PyQt5.QtCore import QSize
import os
import sys
import signal
from ImageCanvas import ImageCanvas
from TopRoundRect import TopRoundRect
from Player import Player

if __name__ == "__main__":
    app = QApplication(sys.argv)
    
    qmlRegisterType(ImageCanvas, "ImageCanvas", 1, 0, "ImageCanvas")
    qmlRegisterType(TopRoundRect, "TopRoundRect", 1, 0, "TopRoundRect")
    
    view = QQuickView()
    
    player = Player()
    player.setWindowFlags(QtCore.Qt.FramelessWindowHint)
    player.openFile("/space/data/Video/DoctorWho/1.rmvb")
    player.resize(900, 600)
    
    qml_context = view.rootContext()
    qml_context.setContextProperty("windowView", view)
    qml_context.setContextProperty("qApp", qApp)
    
    def adjustPlayer():
        pages = view.rootObject().findChild(QQuickItem, "pages")
        player.move(
            view.x() + pages.x() + 1,
            view.y() + pages.y(),
            )
        player.resize(
            pages.width() - 2,
            pages.height() - 1,
            )
        
    def quitApp(*args):
        qApp.quit()
        
    def viewEvent(event):
        super(QQuickView, view).event(event)
        
        if event.type() == QCloseEvent().type():
            quitApp()
        
        return False
        
    view.xChanged.connect(lambda x: adjustPlayer())    
    view.yChanged.connect(lambda y: adjustPlayer())
    view.destroyed.connect(quitApp)
    view.event = viewEvent
    
    player.show()
    view.setResizeMode(QtQuick.QQuickView.SizeRootObjectToView)
    view.setMinimumSize(QSize(900, 600))
    
    surface_format = QSurfaceFormat()
    surface_format.setAlphaBufferSize(8)
    view.setFormat(surface_format)
    
    print "***: ", app.allWidgets(), type(app.allWidgets())
    view.setColor(QColor(0, 0, 0, 0))
    view.setFlags(QtCore.Qt.FramelessWindowHint)
    view.setSource(QtCore.QUrl.fromLocalFile(os.path.join(os.path.dirname(__file__), 'Main.qml')))
    view.show()
    
    
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    sys.exit(app.exec_())
