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

try:
    from xcb.xproto import PropMode
except ImportError:
    from xcffib.xproto import PropMode
from xpybutil.icccm import State
from xpybutil.ewmh import (c, atom, request_wm_state_checked,
    request_active_window_checked, revent_checked )

from PyQt5.QtCore import Qt, QSize
from PyQt5.QtQuick import QQuickView
from PyQt5.QtCore import pyqtSlot, pyqtProperty, pyqtSignal, QDir
from PyQt5.QtGui import QSurfaceFormat, QColor, QPixmap, QIcon, QCursor
from utils.dbus_interfaces import notificationsInterface
from utils.constants import (DEFAULT_WIDTH, DEFAULT_HEIGHT, WINDOW_GLOW_RADIUS,
    MINIMIZE_WIDTH, MINIMIZE_HEIGHT)
from utils.i18n import _

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

    def __init__(self, center=False):
        QQuickView.__init__(self)
        self._staysOnTop = False
        self._center_request_count = 1 if center else 0

        surface_format = QSurfaceFormat()
        surface_format.setAlphaBufferSize(8)
        self.setFormat(surface_format)
        self.qml_context = self.rootContext()

        self.setColor(QColor(0, 0, 0, 0))
        self.setMinimumSize(QSize(MINIMIZE_WIDTH, MINIMIZE_HEIGHT))
        self.setResizeMode(QQuickView.SizeRootObjectToView)
        self.setFlags(Qt.FramelessWindowHint)
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
        return DEFAULT_WIDTH + 2 * WINDOW_GLOW_RADIUS

    @pyqtProperty(int,constant=True)
    def defaultHeight(self):
        return DEFAULT_HEIGHT + 2 * WINDOW_GLOW_RADIUS

    @pyqtProperty(int,constant=True)
    def minimumWidth(self):
        return MINIMIZE_WIDTH + 2 * WINDOW_GLOW_RADIUS

    @pyqtProperty(int,constant=True)
    def minimumHeight(self):
        return MINIMIZE_HEIGHT + 2 * WINDOW_GLOW_RADIUS

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
        if realPathList: self.rootObject().playPaths(json.dumps(realPathList))

    @pyqtSlot(int)
    def setDeepinWindowShadowHint(self, width):
        width = str(width)
        window = self.winId().__int__()
        return c.core.ChangeProperty(PropMode.Replace, window,
                                     atom('DEEPIN_WINDOW_SHADOW'),
                                     atom('STRING'), 8, len(width), width)

    @pyqtSlot(result=int)
    def getState(self):
        return self.windowState()

    @pyqtSlot()
    def doMinimized(self):
        # # NOTE: This is bug of Qt5 that showMinimized() just can work once after restore window.
        # # I change window state before set it as WindowMinimized to fixed this bug!
        # self.setWindowState(Qt.WindowNoState)

        # # Do minimized.
        # self.setWindowState(Qt.WindowMinimized)
        # self.setVisible(True)

        cookie = revent_checked(self.winId().__int__(), "WM_CHANGE_STATE",
            State.Iconic)
        cookie.check()

    @pyqtSlot()
    def undoMinimized(self):
        # TODO: showNormal() should work here, but actually it doesn't.
        # It's likely a bug of Qt, so I just used the xcb way, which
        # should be relaced in the future with the Qt way.
        cookie = request_active_window_checked(self.winId().__int__())
        cookie.check()

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
        return QCursor.pos()

    @pyqtSlot(bool)
    def setCursorVisible(self, visible):
        self.setCursor(QCursor(Qt.ArrowCursor if visible else Qt.BlankCursor))

    # no need to add this annotation on Qt 5.6 any more, and it causes
    # the application to crash.
    # @pyqtSlot("QVariant")
    def focusWindowChangedSlot(self, win):
        if not win: self.rootObject().hideTransientWindows()

    @pyqtSlot()
    def screenShot(self):
        self.rootObject().hideControls()

        name = "%s-%s" % (self.title(), time.strftime("%y-%m-%d-%H-%M-%S", time.localtime()))
        path = QDir.homePath() +"/%s.jpg" % name
        p = QPixmap.fromImage(self.grabWindow())
        p.save(path, "jpg")

        notificationsInterface.notify(u"截图成功", u"文件已保存到%s" % path)
