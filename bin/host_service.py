#! /usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (C) 2014 Deepin Technology Co., Ltd.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.

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