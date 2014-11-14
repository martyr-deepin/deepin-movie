#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (C) 2014 Deepin, Inc.
#               2014 Wang Yaohua
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

import unittest

from playlist import DMPlaylist

class TestDMPlaylist(unittest.TestCase):
	def setUp(self):
		self.playlist = DMPlaylist()
		cate_game = self.playlist.appendCategory("The Game of Thorn")
		cate_game.appendItem("001", "file:///videos/001.rm", "645")
		cate_game.appendItem("002", "file:///videos/002.rm")
		self.playlist.appendItem("The Big Bang Theory",
			"file:///videos/tbbt001.mkv");
		self.playlist.appendItem("The game of thorn 002");

	def tearDown(self):
		pass

	def testWriteTo(self):
		self.playlist.writeTo("testWriteTo.dmpl")
		with open("testWriteTo.dmpl") as writeTo:
			with open("testReadFrom.dmpl") as readFrom:
				self.assertEqual(writeTo.read(), readFrom.read())

	def testReadFrom(self):
		playlist = DMPlaylist.readFrom("testReadFrom.dmpl")
		playlist.writeTo("testReadFrom2.dmpl")
		with open("testReadFrom.dmpl") as readFrom:
			with open("testReadFrom2.dmpl") as readFrom2:
				self.assertEqual(readFrom.read(), readFrom2.read())


if __name__ == "__main__":
	unittest.main()