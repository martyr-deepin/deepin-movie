#! /usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (C) 2014 Deepin Technology Co., Ltd.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.

from PyQt5.QtCore import pyqtSignal
from PyQt5.QtDBus import QDBusInterface, QDBusConnection, QDBusReply
from PyQt5.QtDBus import QDBusObjectPath

RENDERER_SERVICE = "com.intel.dleyna-renderer"
RENDERER_PATH = "/com/intel/dLeynaRenderer"
RENDERER_MANAGER_INTERFACE = "com.intel.dLeynaRenderer.Manager"
RENDERER_PUSH_HOST_INTERFACE = "com.intel.dLeynaRenderer.PushHost"
RENDERER_RENDERER_DEVICE_INTERFACE = "com.intel.dLeynaRenderer.RendererDevice"
RENDERER_MEDIAPLAYER_INTERFACE = "org.mpris.MediaPlayer2"
RENDERER_MEDIAPLAYER_PLAYER_INTERFACE = "org.mpris.MediaPlayer2.Player"

PROPERTY_INTERFACE = "org.freedesktop.DBus.Properties"

class RendererManagerInterface(QDBusInterface):
    FoundRenderer = pyqtSignal(QDBusObjectPath, arguments=["path"])
    LostRenderer = pyqtSignal(QDBusObjectPath, arguments=["path"])

    def __init__(self):
        super(RendererManagerInterface, self).__init__(
            RENDERER_SERVICE,
            RENDERER_PATH,
            RENDERER_MANAGER_INTERFACE,
            QDBusConnection.sessionBus(),
            None)

    def getRenderers(self):
        msg = self.call("GetRenderers")
        reply = QDBusReply(msg)
        return reply.value() if reply.isValid() else []

    def getVersion(self):
        msg = self.call("GetVersion")
        reply = QDBusReply(msg)
        return reply.value() if reply.isValid() else ""

class RendererPushHostInterface(QDBusInterface):
    def __init__(self, path):
        super(RendererPushHostInterface, self).__init__(
            RENDERER_SERVICE,
            path,
            RENDERER_PUSH_HOST_INTERFACE,
            QDBusConnection.sessionBus(),
            None)

    def hostFile(self, path):
        msg = self.call("HostFile", path)
        reply = QDBusReply(msg)
        return reply.value() if reply.isValid() else ""

    def removeFile(self, path):
        self.call("RemoveFile", path)

class RendererRendererDeviceInterface(QDBusInterface):
    def __init__(self, path):
        super(RendererRendererDeviceInterface, self).__init__(
            RENDERER_SERVICE,
            path,
            RENDERER_RENDERER_DEVICE_INTERFACE,
            QDBusConnection.sessionBus(),
            None)

        self._propIface = QDBusInterface(RENDERER_SERVICE,
            path, PROPERTY_INTERFACE)

    def __getattr__(self, name):
        try:
            _name = name[0].upper() + name[1:]
            msg = self._propIface.call("Get",
                RENDERER_RENDERER_DEVICE_INTERFACE, _name)
            reply = QDBusReply(msg)
            return reply.value() if reply.isValid() else None
        except:
            return None


class RendererMediaPlayerInterface(QDBusInterface):
    def __init__(self, path):
        super(RendererMediaPlayerInterface, self).__init__(
            RENDERER_SERVICE,
            path,
            RENDERER_MEDIAPLAYER_INTERFACE,
            QDBusConnection.sessionBus(),
            None)

class RendererMediaPlayerPlayerInterface(QDBusInterface):
    def __init__(self, path):
        super(RendererMediaPlayerPlayerInterface, self).__init__(
            RENDERER_SERVICE,
            path,
            RENDERER_MEDIAPLAYER_PLAYER_INTERFACE,
            QDBusConnection.sessionBus(),
            None)

    def openUri(self, uri):
        self.call("OpenUri", uri)

    def play(self):
        self.call("Play")

    def pause(self):
        self.call("Pause")

    def playPause(self):
        self.call("PlayPause")

    def stop(self):
        self.call("Stop")