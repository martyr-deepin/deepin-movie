#! /usr/bin/env python
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

import re

class Parser(object):
    __slots__ = ("qvod_uri_pattern", "_uri", "_file_name", "_file_size", "_file_hash")    
    
    qvod_uri_pattern = "^qvod://([0-9]+)\|([A-Za-z0-9]+)\|(.+)\|$"
    
    def __init__(self, uri):
        self.uri = uri

    @property
    def uri(self):
        return self._uri
        
    @uri.setter
    def uri(self, uri):
        self._uri = uri
        match_obj = re.search(self.qvod_uri_pattern, str(self._uri))
        self._file_size, self._file_hash, self._file_name = match_obj.groups() if match_obj else ("",) * 3
        
    @property
    def file_name(self):
        return self._file_name
        
    @property
    def file_size(self):
        return self._file_size
        
    @property
    def file_hash(self):
        return self._file_hash
        
class Downloader(object):
    def __init__(self):
        pass
        
if __name__ == "__main__":
    # test for parser
    for uri in ["qvod://91165120|35F781CA0EC405D29FF1FD10DFF9044636519FFB|171.rmvb|", "qvod://91165120|35F781CA0EC4"]:
        parser = Parser(None)
        parser.uri = uri
        print parser.file_name
        print parser.file_size
        print parser.file_hash