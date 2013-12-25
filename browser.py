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

# from PyQt5.QtCore import QFile, QIODevice, Qt, QTextStream, QUrl
# from PyQt5.QtWidgets import (QAction, QApplication, QLineEdit, QMainWindow,
#         QSizePolicy, QStyle, QTextEdit)
# from PyQt5.QtNetwork import QNetworkProxyFactory, QNetworkRequest
from PyQt5.QtWebKitWidgets import QWebView, QWebPage
from PyQt5.QtWidgets import QMainWindow, QApplication
from PyQt5.QtCore import QUrl, Qt
import sys

class Browser(QMainWindow):
    def __init__(self, url):
        super(Browser, self).__init__()
        self.setWindowFlags(Qt.FramelessWindowHint)
        
        self.view = QWebView(self)
        self.view.load(url)
        self.view.page().setLinkDelegationPolicy(QWebPage.DelegateAllLinks)
        self.view.page().linkClicked.connect(self.link_clicked)
        self.view.page().mainFrame().setScrollBarPolicy(Qt.Vertical, Qt.ScrollBarAlwaysOff)
        self.view.page().mainFrame().setScrollBarPolicy(Qt.Horizontal, Qt.ScrollBarAlwaysOff)
        
        self.setCentralWidget(self.view)
        
    def link_clicked(self, url):
        self.view.load(url)

if __name__ == '__main__':
    app = QApplication(sys.argv)

    if len(sys.argv) > 1:
        url = QUrl(sys.argv[1])
    else:
        url = QUrl('http://www.google.com/ncr')

    browser = Browser(url)
    browser.resize(600, 400)
    browser.show()

    sys.exit(app.exec_())
