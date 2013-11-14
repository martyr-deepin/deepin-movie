#! /usr/bin/env python
# -*- coding: utf-8 -*-

import signal
import os
signal.signal(signal.SIGINT, signal.SIG_DFL)

from cooks import CookieManager
from PyQt5 import QtCore, QtWidgets, QtQuick, QtGui, QtNetwork



if __name__ == "__main__":
    import sys
    app = QtWidgets.QApplication(sys.argv)
    
    view = QtQuick.QQuickView()
    c = CookieManager(view)
    c.setCookie("/home/evilbeast/.cache/deepin-movie-plugins/a83677f5fcc7fc9f8360aed4387999fd")
    
    surface_format = QtGui.QSurfaceFormat()
    surface_format.setAlphaBufferSize(8)
        
    view.setColor(QtGui.QColor(0, 0, 0, 0))
    view.setFlags(QtCore.Qt.FramelessWindowHint)
    view.setResizeMode(QtQuick.QQuickView.SizeRootObjectToView)
    view.setFormat(surface_format)

    view.setSource(QtCore.QUrl.fromLocalFile(os.path.join(os.path.dirname(__file__), 'player.qml')))
    view.setMinimumSize(QtCore.QSize(900, 518))
    view.show()

    sys.exit(app.exec_())
