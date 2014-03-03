#! /usr/bin/python
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
from PyQt5 import QtCore
from PyQt5.QtCore import QCoreApplication
if os.name == 'posix':
    QCoreApplication.setAttribute(QtCore.Qt.AA_X11InitThreads, True)
    
from PyQt5.QtCore import pyqtSlot, QObject
from PyQt5.QtWidgets import QApplication, qApp
import sys
import os
import signal
from window import Window
from database import Database
from config import Config
from movie_info import MovieInfo
from browser import Browser
from menu_controller import MenuController

class PageManager(QObject):

    def __init__(self, view):
        super(QObject, self).__init__()
        self.main_xid = view.winId().__int__()
        self.movie_store_page = Browser("http://pianku.xmp.kankan.com/moviestore_index.html")
        self.movie_search_page = Browser("http://search.xmp.kankan.com/lndex4xmp.shtml")

    @pyqtSlot(str, int, int, int, int)
    def show_page(self, page_name, x, y, width, height):
        self.hide_page()

        x += 1
        width -= 2
        height -= 1

        if page_name == "movie_store":
            self.movie_store_page.show_with_parent(self.main_xid, x, y, width, height)
        elif page_name == "movie_search":
            self.movie_search_page.show_with_parent(self.main_xid, x, y, width, height)

    @pyqtSlot()
    def hide_page(self):
        self.movie_store_page.hide()
        self.movie_search_page.hide()
        
if __name__ == "__main__":
    movie_file = ""
    if len(sys.argv) >= 2:
        movie_file = sys.argv[1]
    movie_info = MovieInfo(movie_file)

    app = QApplication(sys.argv)
    database = Database()
    config = Config()
    view = Window()
    page_manager = PageManager(view)
    menu_controller = MenuController()

    qml_context = view.rootContext()
    qml_context.setContextProperty("windowView", view)
    qml_context.setContextProperty("qApp", qApp)
    qml_context.setContextProperty("movieInfo", movie_info)
    qml_context.setContextProperty("database", database)
    qml_context.setContextProperty("config", config)
    qml_context.setContextProperty("pageManager", page_manager)
    qml_context.setContextProperty("_menu_controller", menu_controller)

    view.setSource(QtCore.QUrl.fromLocalFile(os.path.join(os.path.dirname(__file__), 'main.qml')))
    view.setX(100)
    view.setY(100)
    view.show()
    
    # view.windowStateChanged.connect(view.rootObject().monitorWindowState)
    # app.lastWindowClosed.connect(view.rootObject().monitorWindowClose)
    app.setQuitOnLastWindowClosed(True)

    signal.signal(signal.SIGINT, signal.SIG_DFL)
    sys.exit(app.exec_())
