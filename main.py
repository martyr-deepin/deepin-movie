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
import signal
import weakref

#warning - below code should be deleted while releasing this product
class MultiWriter(object):
    """according to the python documentation, stdout and stderr may not
    be normal files, it just should have one write(str) method, this class is 
    intend to be used as stdout or stderr, which has multiple file like object,
    and each of them will be filled with the content of stdout or stderr. 
    """
    def __init__(self, *fs):
        super(MultiWriter, self).__init__()
        self._fs = fs

    def write(self, s):
        s = s.encode("utf-8")
        map(lambda x: x.write(s) or x.flush(), self._fs)
        

import tempfile
std_out = sys.stdout
log_file = open(os.path.join(tempfile.gettempdir(), "deepin-movie.log"), "w")
multi_writer = MultiWriter(std_out, log_file)
sys.stdout = multi_writer
sys.stderr = multi_writer
#warning end

from PyQt5 import QtCore
from PyQt5.QtCore import QCoreApplication
if os.name == 'posix':
    QCoreApplication.setAttribute(QtCore.Qt.AA_X11InitThreads, True)
 
# from PyQt5.QtGui import QFont   
from PyQt5.QtCore import pyqtSlot, QObject
from PyQt5.QtWidgets import QApplication, QInputDialog
app = QApplication(sys.argv)

from window import Window
from database import database
from config import config
from movie_info import movie_info
from browser import Browser
from utils import utils
from constant import MAIN_QML
from menu_controller import MenuController
from file_monitor import FileMonitor

class PageManager(QObject):

    def __init__(self, view):
        super(QObject, self).__init__()
        self.main_xid = view.winId().__int__()

        self.movie_store_page = Browser("http://dy.yunfan.com")
        self.movie_search_page = Browser("http://www.yunfan.com/qs")

    @pyqtSlot(str, int, int, int, int)
    def show_page(self, page_name, x, y, width, height):
        self.hide_page()

        x += 3
        width -= 2
        height -= 2

        if page_name == "movie_store":
            self.movie_store_page.show_with_parent(self.main_xid,
             x, y, width, height)
        elif page_name == "movie_search":
            self.movie_search_page.show_with_parent(self.main_xid,
             x, y, width, height)

    @pyqtSlot()
    def hide_page(self):
        self.movie_store_page.hide()
        self.movie_search_page.hide()

class InputDialog(QObject):
    def __init__(self, parent):
        super(InputDialog, self).__init__()
        self.parent = parent
        self.title = "Open URL:"
        self.label = "URL to open:"
        self._dialog = QInputDialog()

    @pyqtSlot(result=str)
    def show(self):
        input, ok = self._dialog.getText(self.parent, self.title, self.label)
        return input if ok else ""

if __name__ == "__main__":
    movie_file = os.path.realpath(sys.argv[1]) if len(sys.argv) >= 2 else ""

    from dbus_services import (DeepinMovieServie, check_multiple_instances, 
        DeepinMovieInterface, session_bus, DBUS_PATH)

    result = check_multiple_instances()
    if result: 
        dbus_service = DeepinMovieServie(app)
        session_bus.registerObject(DBUS_PATH, dbus_service)
    if not config.playerMultipleProgramsAllowed:
        if not result:
            if movie_file: 
                dbus_interface = DeepinMovieInterface()
                dbus_interface.play(movie_file)
            os._exit(0)

    windowView = Window(result)
    menu_controller = MenuController(windowView)
    inputDialog = InputDialog(None)
    file_monitor = FileMonitor()
    app._extra_window = weakref.ref(windowView)

    qml_context = windowView.rootContext()

    qml_context.setContextProperty("config", config)
    qml_context.setContextProperty("_utils", utils)
    qml_context.setContextProperty("_file_monitor", file_monitor)
    qml_context.setContextProperty("database", database)
    qml_context.setContextProperty("windowView", windowView)
    qml_context.setContextProperty("movieInfo", movie_info)
    qml_context.setContextProperty("_input_dialog", inputDialog)
    qml_context.setContextProperty("_menu_controller", menu_controller)

    windowView.setSource(QtCore.QUrl.fromLocalFile(MAIN_QML))
    windowView.initWindowSize()
    windowView.show()

    movie_info.movie_file = movie_file
    
    windowView.windowStateChanged.connect(windowView.rootObject().monitorWindowState)
    app.lastWindowClosed.connect(windowView.rootObject().monitorWindowClose)
    app.setQuitOnLastWindowClosed(True)
    
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    sys.exit(app.exec_())
