#! /usr/bin/python
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

import pysrt
import chardet

FILE_TYPE_ASS = "__ass__"
FILE_TYPE_SRT = "__srt__"

class NotSupportedFileTypeExcpetion(object):
	"""docstring for NotSupportedFileTypeExcpetion"""
	def __init__(self, arg):
		super(NotSupportedFileTypeExcpetion, self).__init__("Not Supported")

class _Parser(object):
	"""docstring for _Parser"""
	def __init__(self):
		super(_Parser, self).__init__()

	def parse(self):
		raise NotImplementedError

	def get_subtitle_at(self, time):
		raise NotImplementedError

class SrtParser(_Parser):
	"""docstring for SrtParser"""
	def __init__(self, file_name):
		super(SrtParser, self).__init__()
		self.parse(file_name)

	def parse(self, file_name):
		self._sub_entries = pysrt.open(file_name)

	def get_subtitle_at(self, timestamp):
		return self._sub_entries.at(timestamp).text if self._sub_entries else ""

class Parser(object):
	"""docstring for Parser"""
	def __init__(self, file_name):
		super(Parser, self).__init__()
		self._file_name = None
		self.file_name = file_name

	@property
	def file_name(self):
	    return self._file_name

	@file_name.setter
	def file_name(self, value):
	    self._file_name = value

	    _file_type = self._get_file_type(self._file_name)
	    _file_encoding = chardet.detect(self._file_name)["encoding"]

	    if _file_type == FILE_TYPE_SRT:
	    	self._parser = SrtParser(self._file_name)

	def _get_file_type(self, file_name):
		if file_name.endswith("ass") or file_name.endswith("saa"):
			return FILE_TYPE_ASS
		elif file_name.endswith("srt"):
			return FILE_TYPE_SRT
		else:
			raise NotSupportedFileTypeExcpetion()

	def get_subtitle_at(self, timestamp):
		hours, timestamp = divmod(timestamp, 1000 * 60 * 60)
		minutes, timestamp = divmod(timestamp, 1000 * 60)
		seconds, timestamp = divmod(timestamp, 1000)
		milliseconds = timestamp

		return self._parser.get_subtitle_at((hours, minutes, 
			seconds, milliseconds),)

if __name__ == '__main__':
	parser = Parser("/home/hualet/Videos/subtitles/movie.srt")
	print parser.get_subtitle_at(1000 * 1)
	print parser.get_subtitle_at(1000 * 20)
	print parser.get_subtitle_at(1000 * 60)
	print parser.get_subtitle_at(1000 * 60 * 6)
	