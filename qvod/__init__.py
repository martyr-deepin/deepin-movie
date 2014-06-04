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

import thread
import SocketServer
import manager

class MyTCPHandler(SocketServer.BaseRequestHandler):
    cache = ""
    def handle(self):
        data = self.request.recv(1024).strip()
        data = [l for l in data.split('\n') if l.startswith('qvod:')]
        
        if len(data) > 0 and data[0] != self.cache:
            self.cache = data[0]
            self.downloader = manager.Downloader(self.cache)         
            self.downloader.start()
        
def listenURL():
    HOST, PORT = "localhost", 62351
    
    server = SocketServer.TCPServer((HOST, PORT), MyTCPHandler)
    server.serve_forever()

thread.start_new_thread(listenURL, ())