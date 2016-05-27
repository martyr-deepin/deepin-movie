#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright (C) 2011 ~ 2012 Deepin, Inc.
#               2011 ~ 2012 Wang Yong
#
# Author:     Wang Yaohua <mr.asianwang@gmail.com>
# Maintainer: Wang Yaohua <mr.asianwang@gmail.com>
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

import os
import sys
import glob
import codecs
import ass
import pysrt
import tempfile
from datetime import timedelta
from chardet.universaldetector import UniversalDetector
from utils.misc import get_command_output_first_line

from PyQt5.QtCore import QObject, pyqtProperty, pyqtSlot, pyqtSignal

SUPPORTED_FILE_TYPES = ("ass", "srt")

for type in SUPPORTED_FILE_TYPES:
    setattr(sys.modules[__name__],
        "FILE_TYPE_%s" % type.upper(),
        "__%s__" % type)

def get_file_type(file_name):
    if file_name.endswith("ass") or file_name.endswith("saa"):
        return getattr(sys.modules[__name__], "FILE_TYPE_ASS")
    elif file_name.endswith("srt"):
        return getattr(sys.modules[__name__], "FILE_TYPE_SRT")
    return None

def get_file_encoding(file_name):
    if not os.path.isfile(file_name): return ""
    u = UniversalDetector()
    with open(file_name, "rb") as f:
        for index, line in enumerate(f):
            u.feed(line)
            if index > 500: break
        u.close()
    if u.result["encoding"].lower() == "gb2312":
        try:
            _file = codecs.open(file_name, encoding="gb2312")
            _file.readlines()
            result = "gb2312"
        except Exception, e:
            print e
            try:
                _file = codecs.open(file_name, encoding="gbk")
                _file.readlines()
                result = "gbk"
            except Exception, e:
                print e
                result = "gb18030"
    else: result = u.result["encoding"]
    return result

    # if file_name != "":
    #   return get_command_output_first_line(["enca", "-i", file_name]).rstrip()
    # else:
    #   return ""

def get_utf_8_version(file_name, origin_encoding):
    fp, tmp_name = tempfile.mkstemp(text=True)
    get_command_output_first_line(["iconv", "--from-code", origin_encoding,
        "--to-code", "UTF-8", "-o", tmp_name, file_name])
    return tmp_name

def get_subtitle_from_movie( movie_file):
    movie_file = movie_file.replace("file://", "")
    dir_name = os.path.dirname(movie_file)
    name_without_ext = movie_file.rpartition(".")[0]
    if name_without_ext == "": return ("",)

    result = []
    for ext in SUPPORTED_FILE_TYPES:
        try_ext = "%s/*.%s" % (dir_name, ext)
        all_this_ext = glob.glob(try_ext)
        result += filter(lambda x: name_without_ext in x, all_this_ext)
    return result or ("",)

class NotSupportedFileTypeExcpetion(Exception):
    """docstring for NotSupportedFileTypeExcpetion"""
    def __init__(self):
        super(NotSupportedFileTypeExcpetion, self).__init__("Not Supported")

class _Parser(object):
    """docstring for _Parser"""
    def __init__(self):
        super(_Parser, self).__init__()

    def parse(self, file_type, file_encoding):
        raise NotImplementedError

    def get_subtitle_at(self, timestamp):
        raise NotImplementedError

class EmptyParser(_Parser):
    """docstring for EmptyParser"""
    def __init__(self):
        super(EmptyParser, self).__init__()

    def parse(self, file_type, file_encoding):
        pass

    def get_subtitle_at(self, timestamp):
        return ""

class AssParser(_Parser):
    """docstring for AssParser"""
    def __init__(self, file_name, file_encoding):
        super(AssParser, self).__init__()
        self.parse(file_name, file_encoding)

    def parse(self, file_name, file_encoding):
        if file_encoding.lower() != "utf-8":
            file_name = get_utf_8_version(file_name, file_encoding)
        with open(file_name) as f:
            self._events = ass.parse(f).events

    def get_subtitle_at(self, timestamp):
        delta = timedelta(milliseconds=timestamp)
        for event in self._events:
            if event.start < delta < event.end:
                return event.text
        return ""

class SrtParser(_Parser):
    """docstring for SrtParser"""
    def __init__(self, file_name, file_encoding):
        super(SrtParser, self).__init__()
        self.parse(file_name, file_encoding)

    def parse(self, file_name, file_encoding):
        self._sub_entries = pysrt.open(file_name, file_encoding)

    def get_subtitle_at(self, timestamp):
        hours, timestamp = divmod(timestamp, 1000 * 60 * 60)
        minutes, timestamp = divmod(timestamp, 1000 * 60)
        seconds, timestamp = divmod(timestamp, 1000)
        milliseconds = timestamp

        timestamp = (hours, minutes, seconds, milliseconds)

        return self._sub_entries.at(timestamp).text if self._sub_entries else ""

class Parser(QObject):
    """docstring for Parser"""
    fileNameChanged = pyqtSignal(str, arguments=["fileName"])
    delayChanged = pyqtSignal(int, arguments=["delay"])

    def __init__(self, file_name=None, delay=0):
        super(Parser, self).__init__()
        self.delay = delay
        self.file_name = file_name

    @pyqtProperty(int, notify=delayChanged)
    def delay(self):
        return self._delay

    @delay.setter
    def delay(self, value):
        self._delay = value
        self.delayChanged.emit(value)

    @pyqtProperty(str)
    def file_name(self):
        return self._file_name

    @file_name.setter
    def file_name(self, value):
        self._file_name = value
        self.fileNameChanged.emit(self._file_name)

        if self._file_name and os.path.exists(self._file_name):
            _file_type = get_file_type(self._file_name)
            _file_encoding = get_file_encoding(self._file_name)

            if _file_type == getattr(sys.modules[__name__], "FILE_TYPE_SRT"):
                self._parser = SrtParser(self._file_name, _file_encoding)
            elif _file_type == getattr(sys.modules[__name__], "FILE_TYPE_ASS"):
                self._parser = AssParser(self._file_name, _file_encoding)
            else:
                self._parser = EmptyParser()
        else:
            self._parser = EmptyParser()

    @pyqtSlot(str)
    def set_subtitle_from_movie(self, movie_file):
        self.file_name = get_subtitle_from_movie(movie_file)[0]
        self.delay = 0

    @pyqtSlot(int, result=str)
    def get_subtitle_at(self, timestamp):
        return self._parser.get_subtitle_at(timestamp - self.delay)

if __name__ == '__main__':
    parser = Parser("")
    parser = Parser("/home/hualet/Videos/Test.srt")
    print parser.get_subtitle_at(1000 * 1)
    print parser.get_subtitle_at(1000 * 20)
    print parser.get_subtitle_at(1000 * 60)
    print parser.get_subtitle_at(1000 * 60 * 6)
