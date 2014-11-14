#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (C) 2011 ~ 2014 Deepin, Inc.
#               2011 ~ 2014 Wang YaoHua
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


from PyQt5.QtCore import QVariant
from PyQt5.QtDBus import QDBusAbstractInterface, QDBusConnection, QDBusReply

class ScreenSaverInterface(QDBusAbstractInterface):
    def __init__(self):
        super(ScreenSaverInterface, self).__init__("org.freedesktop.ScreenSaver",
                                                   "/org/freedesktop/ScreenSaver",
                                                   "org.freedesktop.ScreenSaver",
                                                   QDBusConnection.sessionBus(), 
                                                   None)
        self._inhibit_cookie = None

    def inhibit(self):
        msg = self.call("Inhibit", "DMovie", "Video Playing!")
        reply = QDBusReply(msg)
        self._inhibit_cookie = reply.value()
        return self._inhibit_cookie

    def uninhibit(self, cookie=None):
        if self._inhibit_cookie:
            arg = QVariant(cookie or self._inhibit_cookie)
            arg.convert(QVariant.UInt)
            self.call('UnInhibit', arg)

screenSaverInterface = ScreenSaverInterface()