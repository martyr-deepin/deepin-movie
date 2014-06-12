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
import time
from PyQt5 import QtGui, QtCore, QtQuick
from PyQt5.QtCore import QSize
from PyQt5.QtQuick import QQuickView
from PyQt5.QtCore import pyqtSlot, pyqtProperty, QDir
from PyQt5.QtGui import QSurfaceFormat, QColor, QPixmap, QIcon
from notification import notify
from constant import (DEFAULT_WIDTH, DEFAULT_HEIGHT, WINDOW_GLOW_RADIUS,
    MINIMIZE_WIDTH, MINIMIZE_HEIGHT)
from i18n import _

HOME_DIR = os.path.expanduser("~")
def icon_from_theme(theme_name, icon_name):
    QIcon.setThemeSearchPaths([os.path.join(HOME_DIR, ".icons"), 
        os.path.join(HOME_DIR, ".local/share/icons"),
        "/usr/local/share/icons", 
        "/usr/share/icons", 
        ":/icons"])
    QIcon.setThemeName(theme_name)
    return QIcon.fromTheme(icon_name)

class Window(QQuickView):

    def __init__(self):
        QQuickView.__init__(self)
        surface_format = QSurfaceFormat()
        surface_format.setAlphaBufferSize(8)
        
        self.setColor(QColor(0, 0, 0, 0))
        self.setMinimumSize(QSize(MINIMIZE_WIDTH, MINIMIZE_HEIGHT))
        self.setResizeMode(QtQuick.QQuickView.SizeRootObjectToView)
        self.setFormat(surface_format)
        
        self.staysOnTop = False
        self.qml_context = self.rootContext()
        self.setTitle(_("Deepin Movie"))
        self.setIcon(icon_from_theme("Deepin", "deepin-movie"))

    def initWindowSize(self):
        self.rootObject().initWindowSize()
        self.moveToCenter()

    @pyqtProperty(int,constant=True)
    def defaultWidth(self):
        return DEFAULT_WIDTH

    @pyqtProperty(int,constant=True)
    def defaultHeight(self):
        return DEFAULT_HEIGHT

    @pyqtProperty(int,constant=True)
    def minimumWidth(self):
        return MINIMIZE_WIDTH

    @pyqtProperty(int,constant=True)
    def minimumHeight(self):
        return MINIMIZE_HEIGHT

    @pyqtProperty(int,constant=True)
    def windowGlowRadius(self):
        return WINDOW_GLOW_RADIUS
        
    @pyqtSlot(result=int)    
    def getState(self):
        return self.windowState()
    
    @pyqtSlot()
    def doMinimized(self):
        # NOTE: This is bug of Qt5 that showMinimized() just can work once after restore window.
        # I change window state before set it as WindowMinimized to fixed this bug!
        self.setWindowState(QtCore.Qt.WindowNoState)
        
        # Do minimized.
        self.setWindowState(QtCore.Qt.WindowMinimized)
        self.setVisible(True)
        
    @pyqtProperty(bool)
    def staysOnTop(self):
        return self._staysOnTop

    @staysOnTop.setter
    def staysOnTop(self, onTop):
        self._staysOnTop = onTop
        flags = QtCore.Qt.FramelessWindowHint
        if onTop: flags = flags | QtCore.Qt.WindowStaysOnTopHint
        self.setFlags(flags)
        self.hide()
        self.show()

    @pyqtSlot()
    def moveToCenter(self):
        distance = self.screen().geometry().center() - self.geometry().center()
        self.setX(self.x() + distance.x())
        self.setY(self.y() + distance.y())

    @pyqtSlot(result="QVariant")    
    def getCursorPos(self):
        return QtGui.QCursor.pos()        
        
    @pyqtSlot()
    def screenShot(self):
        self.rootObject().hideControls()
        
        name = "%s-%s" % (self.title(), time.strftime("%y-%m-%d-%H-%M-%S", time.localtime()))
        path = QDir.homePath() +"/%s.jpg" % name
        p = QPixmap.fromImage(self.grabWindow())
        p.save(path, "jpg")
        
        notify(u"截图成功", u"文件已保存到%s" % path)
