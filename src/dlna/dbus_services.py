#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (C) 2014 ~ 2015 Deepin, Inc.
#               2014 ~ 2015 Wang YaoHua
#
# Author:     Wang YaoHua <mr.asianwang@gmail.com>
# Maintainer: Wang YaoHua <mr.asianwang@gmail.com>
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

from PyQt5.QtCore import QObject, Q_CLASSINFO, pyqtSlot, pyqtProperty
from PyQt5.QtDBus import QDBusAbstractAdaptor

DBUS_PATH = "/com/deepin/private/DeepinMovie"
DBUS_IFAC = "com.deepin.private.DeepinMovie"

class DeepinMoviePrivateServie(QObject):
    def __init__(self, application):
        super(DeepinMoviePrivateServie, self).__init__()
        self.__app = application
        self.__dbusAdaptor = DeepinMoviePrivateServiceAdaptor(self)

    def setUri(self, uri):
        self.__app._extra_window().rootObject().setUri(uri)

    def setNextUri(self, uri):
        self.__app._extra_window().rootObject().setNextUri(uri)

    def play(self):
        self.__app._extra_window().rootObject().play()

    def pause(self):
        self.__app._extra_window().rootObject().pause()

    def stop(self):
        self.__app._extra_window().rootObject().stop()

    def seek(self, value):
        self.__app._extra_window().rootObject().setPosition(value)

    def duration(self):
        return self.__app._extra_window().rootObject().getDuration()

    def position(self):
        return self.__app._extra_window().rootObject().getPosition()

    def volume(self):
        return self.__app._extra_window().rootObject().getVolume()

    def setVolume(self, value):
        self.__app._extra_window().rootObject().setVolume(value)

    def mute(self):
        return self.__app._extra_window().rootObject().getMute()

    def setMute(self, value):
        self.__app._extra_window().rootObject().setMute(value)


class DeepinMoviePrivateServiceAdaptor(QDBusAbstractAdaptor):

    Q_CLASSINFO("D-Bus Interface", DBUS_IFAC)
    Q_CLASSINFO("D-Bus Introspection",
                '  <interface name="com.deepin.private.DeepinMovie">\n'
                '    <property name="Volume" type="d" access="readwrite"/> \n'
                '    <property name="Mute" type="b" access="readwrite"/> \n'
                '    <property name="Duration" type="x" access="read"/> \n'
                '    <property name="Position" type="x" access="read"/> \n'
                '    <method name="Play">\n'
                '    </method>\n'
                '    <method name="Pause">\n'
                '    </method>\n'
                '    <method name="Stop">\n'
                '    </method>\n'
                '    <method name="SetUri">\n'
                '      <arg direction="in" type="s" name="uri"/>\n'
                '    </method>\n'
                '    <method name="Seek">\n'
                '      <arg direction="in" type="x" name="position"/>\n'
                '    </method>\n'
                '  </interface>\n')

    def __init__(self, parent):
        super(DeepinMoviePrivateServiceAdaptor, self).__init__(parent)
        self.parent = parent

    @pyqtSlot(str)
    def SetUri(self, uri):
        self.parent.setUri(uri)

    @pyqtSlot()
    def Play(self):
        self.parent.play()

    @pyqtSlot()
    def Pause(self):
        self.parent.pause()

    @pyqtSlot()
    def Stop(self):
        self.parent.stop()

    @pyqtSlot('qint64')
    def Seek(self, pos):
        self.parent.seek(pos)

    @pyqtProperty('qint64')
    def Duration(self):
        return self.parent.duration()

    @pyqtProperty('qint64')
    def Position(self):
        return self.parent.position()

    @pyqtProperty(float)
    def Volume(self):
        return self.parent.volume()

    @Volume.setter
    def Volume(self, volume):
        self.parent.setVolume(volume)

    @pyqtProperty(bool)
    def Mute(self):
        return self.parent.mute()

    @Mute.setter
    def Mute(self, mute):
        self.parent.setMute(mute)