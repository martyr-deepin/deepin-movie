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

from PyQt5.QtWebKitWidgets import QWebView, QWebPage
from PyQt5.QtWidgets import QApplication
from PyQt5.QtCore import QUrl, Qt
from stickwidget import StickWidget
from deepin_utils.file import get_parent_dir
import os

class Browser(StickWidget):
    def __init__(self, url):
        super(Browser, self).__init__()
        
        self.view = QWebView(self)
        self.view.load(QUrl(url))
        self.view.page().setLinkDelegationPolicy(QWebPage.DelegateAllLinks)
        self.view.page().linkClicked.connect(self.link_clicked)
        self.view.page().mainFrame().setScrollBarPolicy(Qt.Horizontal, Qt.ScrollBarAlwaysOff)
            
        self.view.settings().setUserStyleSheetUrl(QUrl.fromLocalFile(os.path.join(get_parent_dir(__file__), "scrollbar.css")))
        
        self.layout.addWidget(self.view)
        
    def link_clicked(self, url):
        self.view.load(url)
        
if __name__ == '__main__':
    import sys
    import signal
    
    app = QApplication(sys.argv)

    url = QUrl('http://pianku.xmp.kankan.com/moviestore_index.html')

    browser = Browser(url)
    browser.resize(600, 400)
    browser.move(0, 0)
    browser.show()
    
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    sys.exit(app.exec_())
