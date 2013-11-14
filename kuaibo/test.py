#!/usr/bin/env python
#-*- coding:utf-8 -*-

import sip
sip.setapi('QString', 2)
sip.setapi('QVariant', 2)

from PyQt4 import QtCore, QtGui, QtWebKit, QtNetwork

class cookieJar(QtNetwork.QNetworkCookieJar):
    def __init__(self, cookiesKey, parent=None):
        super(cookieJar, self).__init__(parent)

        self.mainWindow = parent
        self.cookiesKey = cookiesKey
        cookiesValue    = self.mainWindow.settings.value(self.cookiesKey)       

        if cookiesValue:
            cookiesList = QtNetwork.QNetworkCookie.parseCookies(cookiesValue)
            self.setAllCookies(cookiesList)

    def setCookiesFromUrl (self, cookieList, url):
        cookiesValue = self.mainWindow.settings.value(self.cookiesKey)
        cookiesArray = cookiesValue if cookiesValue else QtCore.QByteArray()

        for cookie in cookieList:
            cookiesArray.append(cookie.toRawForm() + "\n")

        self.mainWindow.settings.setValue(self.cookiesKey, cookiesArray)

        return super(cookieJar, self).setCookiesFromUrl(cookieList, url)

class webView(QtWebKit.QWebView):
    def __init__(self, cookiesKey, url, parent=None):
        super(webView, self).__init__(parent)

        self.cookieJar = cookieJar(cookiesKey, parent)

        self.page().networkAccessManager().setCookieJar(self.cookieJar)

class myWindow(QtGui.QMainWindow):
    def __init__(self, parent=None):
        super(myWindow, self).__init__(parent)

        self.cookiesKey = "cookies"

        self.centralwidget = QtGui.QWidget(self)

        self.tabWidget = QtGui.QTabWidget(self.centralwidget)
        self.tabWidget.setTabsClosable(True)

        self.verticalLayout = QtGui.QVBoxLayout(self.centralwidget)
        self.verticalLayout.addWidget(self.tabWidget)

        self.actionTabAdd = QtGui.QAction(self)
        self.actionTabAdd.setText("Add Tab")
        self.actionTabAdd.triggered.connect(self.on_actionTabAdd_triggered)

        self.lineEdit = QtGui.QLineEdit(self)
        self.lineEdit.setText("http://www.example.com")

        self.toolBar = QtGui.QToolBar(self)
        self.toolBar.addAction(self.actionTabAdd)
        self.toolBar.addWidget(self.lineEdit)

        self.addToolBar(QtCore.Qt.ToolBarArea(QtCore.Qt.TopToolBarArea), self.toolBar)
        self.setCentralWidget(self.tabWidget)

        self.settings = QtCore.QSettings()

    @QtCore.pyqtSlot()
    def on_actionShowCookies_triggered(self):
        webView = self.tabWidget.currentWidget()
        listCookies = webView.page().networkAccessManager().cookieJar().allCookies()

        for cookie in  listCookies:
            print cookie.toRawForm()

    @QtCore.pyqtSlot()
    def on_actionTabAdd_triggered(self):
        url = self.lineEdit.text()
        self.addNewTab(url if url else 'about:blank')

    def addNewTab(self, url):
        tabName = u"Tab {0}".format(str(self.tabWidget.count()))

        tabWidget= webView(self.cookiesKey, url, self)
        tabWidget.loadFinished.connect(self.on_tabWidget_loadFinished)
        tabWidget.load(QtCore.QUrl(url))

        tabIndex = self.tabWidget.addTab(tabWidget, tabName)

        self.tabWidget.setCurrentIndex(tabIndex)

    @QtCore.pyqtSlot()
    def on_tabWidget_loadFinished(self):
        print self.settings.value(self.cookiesKey)

if __name__ == "__main__":
    import sys

    app = QtGui.QApplication(sys.argv)
    app.setApplicationName('myWindow')

    main = myWindow()
    main.resize(666, 333)
    main.show()

    sys.exit(app.exec_())