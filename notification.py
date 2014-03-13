#! /usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (C) 2011 ~ 2013 Deepin, Inc.
#               2011 ~ 2013 Hou ShaoHui
#
# Author:     Hou ShaoHui <houshao55@gmail.com>
# Maintainer: Hou ShaoHui <houshao55@gmail.com>
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

import dbus

NOTIFICATIONS_SERVICE = "org.freedesktop.Notifications"
NOTIFICATIONS_PATH = "/org/freedesktop/Notifications"
NOTIFICATIONS_INTERFACE = "org.freedesktop.Notifications"

bus = dbus.SessionBus()

def notify(summary, body):
    proxy = bus.get_object(NOTIFICATIONS_SERVICE,
                           NOTIFICATIONS_PATH)
    notify_interface = dbus.Interface(proxy, NOTIFICATIONS_INTERFACE)
    notify_interface.Notify("Deepin Movie", 
                            0, 
                            "/usr/share/icons/Deepin/apps/48/deepin-media-player.png", 
                            summary, 
                            body,
                            [], 
                            {}, 
                            -1)

if __name__ == "__main__":
    notify("hello", "world")