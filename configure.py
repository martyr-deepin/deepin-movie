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

from ConfigParser import ConfigParser

class EqualsSpaceRemover:
    output_file = None
    def __init__( self, new_output_file ):
        self.output_file = new_output_file

    def write( self, what ):
        self.output_file.write( what.replace( " = ", "=", 1 ) )

with open("./src/data/mimetypes") as mimetypes_file:
    mimetypes = map(lambda x: x.strip(), mimetypes_file.readlines())
    mimetype_line = ";".join(mimetypes)

    with open("deepin-movie.desktop", "r+") as desktop_file:
        cp = ConfigParser()
        cp.optionxform = str
        cp.readfp(desktop_file)
        cp.set("Desktop Entry", "MimeType", mimetype_line)
        desktop_file.seek(0)
        desktop_file.truncate()
        cp.write(EqualsSpaceRemover(desktop_file))
