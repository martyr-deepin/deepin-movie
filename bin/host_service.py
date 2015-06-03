#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (C) 2011 ~ 2015 Deepin, Inc.
#               2011 ~ 2015 Wang YaoHua
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

import signal
import prctl
from optparse import OptionParser
from bottle import Bottle, run, static_file

app = Bottle()
movie_path = None

@app.route('/host/<path:path>')
def host(path):
    global movie_path
    movie_path = path

@app.route('/access')
def access():
    return static_file(movie_path, "/")

if __name__ == "__main__":
    usage = "usage: %prog [options] arg"
    parser = OptionParser(usage)
    parser.add_option("-i", "--ip-address", dest="ip_address")
    parser.add_option("-p", "--port", dest="port")
    (options, args) = parser.parse_args()

    prctl.set_pdeathsig(signal.SIGHUP)

    run(app, host=options.ip_address, port=options.port)