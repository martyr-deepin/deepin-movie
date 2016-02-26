#! /usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (C) 2014 Deepin Technology Co., Ltd.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.

from ConfigParser import ConfigParser

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
	    cp.write(desktop_file)
