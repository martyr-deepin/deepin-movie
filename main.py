#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright (C) 2011 ~ 2012 Deepin, Inc.
#               2011 ~ 2012 Wang Yong
#
# Author:     Wang Yong <lazycat.manatee@gmail.com>
# Maintainer: Wang Yong <lazycat.manatee@gmail.com>
#             Wang Yaohua <mr.asianwang@gmail.com>
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

# DON'T DELETE BELOW CODE!
# Calls XInitThreads() as part of the QApplication construction in order to make Xlib calls thread-safe.
# This attribute must be set before QApplication is constructed.
# Otherwise, you will got error:
#     "python: ../../src/xcb_conn.c:180: write_vec: Assertion `!c->out.queue_len' failed."
#
# Qt5 application hitting the race condition when resize and move controlling for a frameless window.
# Race condition happened while Qt was using xcb to read event and request window position movements from two threads.
# Same time rendering thread was drawing scene with opengl.
# Opengl driver (mesa) is using Xlib for buffer management. Result is assert failure in libxcb in different threads.
#
import os
import sys
import json
import signal
import weakref

from PyQt5 import QtCore
from PyQt5.QtCore import QCoreApplication
if os.name == 'posix':
    QCoreApplication.setAttribute(QtCore.Qt.AA_X11InitThreads, True)

# from PyQt5.QtGui import QFont
from PyQt5.QtCore import QTranslator, QLocale, QLibraryInfo
from PyQt5.QtWidgets import QApplication
appTranslator = QTranslator()
translationsPath = "qt_" + QLocale.system().name()
appTranslator.load("qt_zh_CN.qm", QLibraryInfo.location(QLibraryInfo.TranslationsPath))
app = QApplication(sys.argv)
app.setApplicationVersion("2.1")
app.installTranslator(appTranslator)
app.setQuitOnLastWindowClosed(True)

from window import Window
from database import database
from config import config
from utils import utils, FindVideoThreadManager
from constant import MAIN_QML
from menu_controller import MenuController
from file_monitor import FileMonitor
from subtitles import Parser

if __name__ == "__main__":
    from dbus_services import (DeepinMovieServie, check_multiple_instances,
        DeepinMovieInterface, session_bus, DBUS_PATH)

    result = check_multiple_instances()
    if result:
        dbus_service = DeepinMovieServie(app)
        session_bus.registerObject(DBUS_PATH, dbus_service)
    else:
        if not config.playerMultipleProgramsAllowed:
            dbus_interface = DeepinMovieInterface()
            dbus_interface.play(json.dumps(sys.argv[1:]))
            os._exit(0)

    windowView = Window(result or len(sys.argv) > 1)
    menu_controller = MenuController()
    file_monitor = FileMonitor()
    findVideoThreadManager = FindVideoThreadManager()
    subtitleParser = Parser()
    app._extra_window = weakref.ref(windowView)

    qml_context = windowView.rootContext()

    qml_context.setContextProperty("config", config)
    qml_context.setContextProperty("_utils", utils)
    qml_context.setContextProperty("_findVideoThreadManager",
        findVideoThreadManager)
    qml_context.setContextProperty("_file_monitor", file_monitor)
    qml_context.setContextProperty("database", database)
    qml_context.setContextProperty("windowView", windowView)
    qml_context.setContextProperty("_subtitle_parser", subtitleParser)
    qml_context.setContextProperty("_menu_controller", menu_controller)

    windowView.setSource(QtCore.QUrl.fromLocalFile(MAIN_QML))
    windowView.initWindowSize()
    windowView.show()
    windowView.play(json.dumps(sys.argv[1:]))

    windowView.windowStateChanged.connect(windowView.rootObject().monitorWindowState)
    app.lastWindowClosed.connect(windowView.rootObject().monitorWindowClose)
    app.focusWindowChanged.connect(windowView.focusWindowChangedSlot)

    signal.signal(signal.SIGINT, signal.SIG_DFL)
    sys.exit(app.exec_())
