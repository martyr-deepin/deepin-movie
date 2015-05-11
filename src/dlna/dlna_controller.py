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

import subprocess
from uuid import uuid4

from PyQt5.QtCore import QObject, pyqtSlot
from PyQt5.QtWidgets import QApplication
from PyQt5.QtDBus import QDBusConnection

from utils.i18n import _
from dbus_services import DeepinMoviePrivateServie, DBUS_PATH

class DLNAController(QObject):
    def __init__(self, asRenderer=False):
        super(DLNAController, self).__init__()
        self._dbus_name = None
        self._dbus_service = None
        self._daemon_pid = None

        self.setAsRenderer(asRenderer)

    def _initDaemon(self):
        if self._asRenderer:
            if not self._dbus_service:
                if not self._dbus_name:
                    uuid = str(uuid4()).replace("-", "_")
                    self._dbus_name = "com.deepin.private.DeepinMovie_%s" % uuid
                app = QApplication.instance()
                self._dbus_service = DeepinMoviePrivateServie(app)

                bus = QDBusConnection.sessionBus()
                bus.registerService(self._dbus_name)
                bus.registerObject(DBUS_PATH, self._dbus_service)

            self._daemon_pid = subprocess.Popen(["deepin-dlna-renderer",
                "-f", _("Deepin Movie"),
                "--service-name", self._dbus_name])

    @pyqtSlot(bool)
    def setAsRenderer(self, asRenderer):
        self._asRenderer = asRenderer
        if asRenderer:
            if not self._daemon_pid:
                self._initDaemon()
        else:
            if self._daemon_pid:
                self._daemon_pid.kill()