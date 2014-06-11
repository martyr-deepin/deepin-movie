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

from PyQt5.QtWebKit import QWebSettings
from PyQt5.QtWebKitWidgets import QWebView, QWebPage, QWebInspector
from PyQt5.QtWidgets import QApplication
from PyQt5.QtCore import QUrl, Qt, QFile, QTextStream, QIODevice
from stickwidget import StickWidget
from deepin_utils.file import get_parent_dir
import os

class Browser(StickWidget):
    def __init__(self, url):
        super(Browser, self).__init__()
        
        self.view = QWebView(self)
        self.layout.addWidget(self.view)        
        self.view.settings().setAttribute(QWebSettings.PluginsEnabled, True) # enable plugins
        self.view.settings().setAttribute(QWebSettings.DeveloperExtrasEnabled, True) # enable dev tools
        self.view.settings().setUserStyleSheetUrl(QUrl.fromLocalFile(os.path.join(get_parent_dir(__file__), "scrollbar.css")))
        
        self.view.load(QUrl(url))
        self.view.page().setLinkDelegationPolicy(QWebPage.DelegateAllLinks)
        self.view.page().mainFrame().setScrollBarPolicy(Qt.Horizontal, Qt.ScrollBarAlwaysOff)
        # self.view.page().mainFrame().evaluateJavaScript(self.plugin_public_js)
        self.view.page().mainFrame().evaluateJavaScript(self.plugin_qvod_search_js)
        
        self.view.loadFinished.connect(self.url_load_finished)
        self.view.page().linkClicked.connect(self.link_clicked)        
        
    def url_load_finished(self):
        # self.view.page().mainFrame().evaluateJavaScript("setTimeout(function () {startsearch(document)}, 3000)")
        self.view.page().mainFrame().evaluateJavaScript("setTimeout(function () {search()}, 3000)")
        
    def link_clicked(self, url):
        self.view.load(url)
        
    @property
    def plugin_qvod_search_js(self):
        fd = QFile("qvod/search.js") 
 
        if fd.open(QIODevice.ReadOnly | QFile.Text): 
            result = QTextStream(fd).readAll() 
            fd.close() 
        else: 
            result = '' 
            
        return result
        
if __name__ == '__main__':
    import sys
    import signal
    
    app = QApplication(sys.argv)

    url = QUrl('http://www.9ying.net/play/696368.html')
    # url = QUrl('http://www.baidu.com')

    browser = Browser(url)
    browser.resize(600, 400)
    browser.move(0, 0)
    browser.show()
    
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    sys.exit(app.exec_())
