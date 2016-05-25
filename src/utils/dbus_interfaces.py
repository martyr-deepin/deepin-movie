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

SCREEN_SAVER_SERVICE = "org.freedesktop.ScreenSaver"
SCREEN_SAVER_PATH = "/org/freedesktop/ScreenSaver"
SCREEN_SAVER_INTERFACE = "org.freedesktop.ScreenSaver"

NOTIFICATIONS_SERVICE = "org.freedesktop.Notifications"
NOTIFICATIONS_PATH = "/org/freedesktop/Notifications"
NOTIFICATIONS_INTERFACE = "org.freedesktop.Notifications"

class ScreenSaverInterface(QDBusAbstractInterface):
    def __init__(self):
        super(ScreenSaverInterface, self).__init__(
            SCREEN_SAVER_SERVICE,
            SCREEN_SAVER_PATH,
            SCREEN_SAVER_INTERFACE,
            QDBusConnection.sessionBus(),
            None)

        self._inhibit_cookie = None

    def inhibit(self):
        msg = self.call("Inhibit", "DMovie", "Video Playing!")
        reply = QDBusReply(msg)

        if reply.isValid():
            self._inhibit_cookie = reply.value()
            return self._inhibit_cookie
        else:
            return None

    def uninhibit(self, cookie=None):
        if cookie or self._inhibit_cookie:
            arg = QVariant(cookie or self._inhibit_cookie)
            arg.convert(QVariant.UInt)
            self.call('UnInhibit', arg)

class NotificationsInterface(QDBusAbstractInterface):
    def __init__(self):
        super(NotificationsInterface, self).__init__(
            NOTIFICATIONS_SERVICE,
            NOTIFICATIONS_PATH,
            NOTIFICATIONS_INTERFACE,
            QDBusConnection.sessionBus(),
            None)

    def notify(self, summary, body):
        replaceId = QVariant(0)
        replaceId.convert(QVariant.UInt)
        actions = QVariant([])
        actions.convert(QVariant.StringList)

        msg = self.call(
            "Notify",
            "Deepin Movie",
            replaceId,
            "deepin-movie",
            summary, body,
            actions, {}, -1)

        reply = QDBusReply(msg)
        return reply.value if reply.isValid() else None

notificationsInterface = NotificationsInterface()
screenSaverInterface = ScreenSaverInterface()