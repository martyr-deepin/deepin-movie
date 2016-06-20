#!/usr/bin/env python2
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
# this will hopefully fix all the issues about QML interfaces
os.environ["bo_reuse"] = "0"

from OpenGL import GL
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
app.setApplicationVersion("2.2.2")
app.setOrganizationName("Deepin")
app.setApplicationName("Deepin Movie")
app.installTranslator(appTranslator)
app.setQuitOnLastWindowClosed(True)

from views.window import Window
from views.subtitles import Parser
from models.playlist import database
from utils.config import config
from utils.dmsettings import DMSettings
# TODO: utils module structure sucks
from utils.utils import utils, FindVideoThreadManager
from utils.constants import MAIN_QML
from controllers.menu_controller import MenuController
from utils.file_monitor import FileMonitor
from utils.dbus_services import (DeepinMovieServie, check_multiple_instances,
    DeepinMovieInterface, session_bus, DBUS_PATH)

if __name__ == "__main__":
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
    settings = DMSettings()
    app._extra_window = weakref.ref(windowView)

    qml_context = windowView.rootContext()

    qml_context.setContextProperty("config", config)
    qml_context.setContextProperty("_settings", settings)
    qml_context.setContextProperty("_utils", utils)
    qml_context.setContextProperty("_findVideoThreadManager",
        findVideoThreadManager)
    qml_context.setContextProperty("_file_monitor", file_monitor)
    qml_context.setContextProperty("_database", database)
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
