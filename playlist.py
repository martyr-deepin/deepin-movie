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

import os
from xml.dom.minidom import (Element, getDOMImplementation, parse)

TAG_CATEGORY = "Category"
TAG_ITEM = "Item"

class DMPlaylistCategory(Element):
	def __init__(self, ownerDocument, name=""):
		Element.__init__(self, TAG_CATEGORY)
		self.name = name
		self.ownerDocument = ownerDocument
		self._items = []

		self.setAttribute("name", self.name)

	def appendItem(self, name, source, played=""):
		item = self._getItemBySource(source)
		if not item:
			item = DMPlaylistItem(self.ownerDocument, name, source, played)
			self.appendChild(item)
			self._items.append(item)
		return item

	def _getItemBySource(self, source):
		for item in self._items:
			if item.source == source:
				return item
		return None

	def getAllItems(self):
		return self._items


class DMPlaylistItem(Element):
	def __init__(self, ownerDocument, name="", source="", played=""):
		Element.__init__(self, TAG_ITEM)
		self.name = name
		self.source = source
		self.played = played
		self.ownerDocument = ownerDocument

		self.setAttribute("source", self.source)
		self.setAttribute("played", self.played)
		self.appendChild(self.ownerDocument.createTextNode(self.name))


class DMPlaylist(object):
	"""Each DMPlaylist object represents a playlist file of DMovie"""

	@classmethod
	def readFrom(cls, filename):
		f_exists = os.path.exists(filename)
		return DMPlaylist(filename) if f_exists else DMPlaylist()

	def __init__(self, filename=""):
		super(DMPlaylist, self).__init__()
		self.document = parse(filename) if filename \
						else getDOMImplementation().createDocument(None,
															"DMPlaylist", None)
		self._categories = []
		self._items = []

		for node in self.document.documentElement.childNodes:
			if hasattr(node, "tagName"):
				if node.tagName == TAG_CATEGORY:
					category = DMPlaylistCategory(self.document,
												node.getAttribute("name"))
					for child in node.childNodes:
						if hasattr(child, "tagName"):
							childName = "".join(map(lambda x: x.data.strip(),
								child.childNodes))
							item = DMPlaylistItem(self.document,
								childName,
								child.getAttribute("source"),
								child.getAttribute("played"))
							category._items.append(item)
					self._categories.append(category)
				elif node.tagName == TAG_ITEM:
					childName = "".join(map(lambda x: x.data.strip(),
						node.childNodes))
					item = DMPlaylistItem(self.document,
						childName,
						node.getAttribute("source"),
						node.getAttribute("played"))
					self._items.append(item)


	def appendCategory(self, name):
		category = self._getCategoryByName(name)
		if not category:
			category = DMPlaylistCategory(self.document, name)
			root_ele = self.document.documentElement
			root_ele.appendChild(category)
			self._categories.append(category)
		return category

	def appendItem(self, name, source, played=""):
		item = self._getItemBySource(source)
		if not item:
			item = DMPlaylistItem(self.document, name, source, played)
			root_ele = self.document.documentElement
			root_ele.appendChild(item)
			self._items.append(item)
		return item

	def _getCategoryByName(self, name):
		for cate in self._categories:
			if cate.name == name:
				return cate
		return None

	def _getItemBySource(self, source):
		for item in self._items:
			if item.source == source:
				return item
		return None

	def getAllCategories(self):
		return self._categories

	def getAllItems(self):
		return self._items

	def writeTo(self, filename):
		try:
			with open(filename, 'w') as writer:
				self.document.writexml(writer, '', ' '*4, '\n')
		except Exception, e:
			print "debug", e
