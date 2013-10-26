#! /usr/bin/python

#
# Qt example for VLC Python bindings
# Copyright (C) 2009-2010 the VideoLAN team
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.

import sys
import vlc
from PyQt5 import QtGui
from PyQt5.QtWidgets import QMainWindow, QApplication, QFrame

class Player(QMainWindow):
    
    def __init__(self):
        QMainWindow.__init__(self)
        self.instance = vlc.Instance()
        self.mediaplayer = self.instance.media_player_new()
        self.videoframe = QFrame()
        self.palette = self.videoframe.palette()
        self.palette.setColor(QtGui.QPalette.Window, QtGui.QColor(0,0,0))
        self.videoframe.setPalette(self.palette)
        self.videoframe.setAutoFillBackground(True)
        self.setCentralWidget(self.videoframe)

    def openFile(self, filename):
        self.media = self.instance.media_new(unicode(filename))
        self.mediaplayer.set_media(self.media)
        self.mediaplayer.set_xwindow(self.videoframe.winId())
        self.mediaplayer.play()
        
if __name__ == "__main__":
    app = QApplication(sys.argv)
    player = Player()
    player.show()
    player.resize(640, 480)
    player.openFile("/space/data/Video/DoctorWho/1.rmvb")
    sys.exit(app.exec_())
