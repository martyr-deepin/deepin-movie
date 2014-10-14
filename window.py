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
import json
from random import randint

import xcb
from xpybutil.ewmh import c, atom, request_wm_state_checked

from PyQt5 import QtGui, QtCore, QtQuick
from PyQt5.QtCore import Qt, QSize
from PyQt5.QtQuick import QQuickView
from PyQt5.QtCore import pyqtSlot, pyqtProperty, pyqtSignal, QDir
from PyQt5.QtGui import QSurfaceFormat, QColor, QPixmap, QIcon, QCursor
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

    staysOnTopChanged = pyqtSignal()
    centerRequestCountChanged = pyqtSignal()
    subtitleVisibleChanged = pyqtSignal()

    def __init__(self, center=False):
        QQuickView.__init__(self)
        self._center_request_count = 1 if center else 0
        surface_format = QSurfaceFormat()
        surface_format.setAlphaBufferSize(8)

        self.setColor(QColor(0, 0, 0, 0))
        self.setMinimumSize(QSize(MINIMIZE_WIDTH, MINIMIZE_HEIGHT))
        self.setResizeMode(QtQuick.QQuickView.SizeRootObjectToView)
        self.setFormat(surface_format)
        self.setFlags(QtCore.Qt.FramelessWindowHint)

        self.staysOnTop = False
        self.qml_context = self.rootContext()
        self.setTitle(_("Deepin Movie"))
        self.setIcon(icon_from_theme("Deepin", "deepin-movie"))

        self.setDeepinWindowShadowHint(self.windowGlowRadius)

    def initWindowSize(self):
        self.centerRequestCount -= 1
        self.rootObject().initWindowSize()
        if self.centerRequestCount < 0:
            self.moveToRandomPos()
        else:
            self.moveToCenter()

    @pyqtProperty(int,centerRequestCountChanged)
    def centerRequestCount(self):
        return self._center_request_count

    @centerRequestCount.setter
    def centerRequestCount(self, count):
        self._center_request_count = count

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

    @pyqtSlot(str)
    def play(self, pathList):
        paths = json.loads(pathList)
        realPathList = []
        for path in paths:
            realpath = os.path.realpath(path)
            if os.path.exists(realpath):
                realPathList.append(realpath)
            else:
                realPathList.append(path)
        self.rootObject().playPaths(json.dumps(realPathList))

    @pyqtSlot(int)
    def setDeepinWindowShadowHint(self, width):
        width = str(width)
        window = self.winId().__int__()
        return c.core.ChangeProperty(xcb.xproto.PropMode.Replace, window,
                                     atom('DEEPIN_WINDOW_SHADOW'),
                                     atom('STRING'), 8, len(width), width)

    @pyqtSlot(result=int)
    def getState(self):
        return self.windowState()

    @pyqtSlot(result=bool)
    def miniModeState(self):
        return self.rootObject().miniModeState()

    @pyqtSlot()
    def doMinimized(self):
        # NOTE: This is bug of Qt5 that showMinimized() just can work once after restore window.
        # I change window state before set it as WindowMinimized to fixed this bug!
        self.setWindowState(QtCore.Qt.WindowNoState)

        # Do minimized.
        self.setWindowState(QtCore.Qt.WindowMinimized)
        self.setVisible(True)

    @pyqtProperty(bool,notify=staysOnTopChanged)
    def staysOnTop(self):
        return self._staysOnTop

    @staysOnTop.setter
    def staysOnTop(self, onTop):
        self._staysOnTop = onTop
        action = 1 if onTop else 0
        request_wm_state_checked(self.winId().__int__(),
            action, atom("_NET_WM_STATE_ABOVE")).check()
        self.staysOnTopChanged.emit()

    @pyqtSlot()
    def moveToCenter(self):
        distance = self.screen().geometry().center() - self.geometry().center()
        self.setX(self.x() + distance.x())
        self.setY(self.y() + distance.y())

    @pyqtSlot()
    def moveToRandomPos(self):
        widthSpare = int(self.screen().geometry().width() - self.geometry().width())
        heightSpare = int(self.screen().geometry().height() - self.geometry().height())
        randX = randint(0, max(0, widthSpare))
        randY = randint(0, max(0, heightSpare))
        self.setX(randX)
        self.setY(randY)

    @pyqtSlot(result="QVariant")
    def getCursorPos(self):
        return QtGui.QCursor.pos()

    @pyqtSlot(bool)
    def setCursorVisible(self, visible):
        self.setCursor(QCursor(Qt.ArrowCursor if visible else Qt.BlankCursor))

    @pyqtProperty(bool,notify=subtitleVisibleChanged)
    def subtitleVisible(self):
        return self.rootObject().subtitleVisible()

    @subtitleVisible.setter
    def subtitleVisible(self, visible):
        self.rootObject().setSubtitleVisible(visible)
        self.subtitleVisibleChanged.emit()

    @pyqtSlot("QVariant")
    def focusWindowChangedSlot(self, win):
        if not win: self.rootObject().hideTransientWindows()

    @pyqtSlot()
    def screenShot(self):
        self.rootObject().hideControls()

        name = "%s-%s" % (self.title(), time.strftime("%y-%m-%d-%H-%M-%S", time.localtime()))
        path = QDir.homePath() +"/%s.jpg" % name
        p = QPixmap.fromImage(self.grabWindow())
        p.save(path, "jpg")

        notify(u"截图成功", u"文件已保存到%s" % path)
