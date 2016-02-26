#! /usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (C) 2014 Deepin Technology Co., Ltd.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.

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