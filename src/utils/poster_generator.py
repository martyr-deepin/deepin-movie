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

from tempfile import mktemp
from PyQt5.QtCore import Qt, QObject, QSize, QPoint, QRect
from PyQt5.QtCore import pyqtSlot, pyqtProperty
from PyQt5.QtGui import QPixmap, QPainter, QColor, QLinearGradient

from i18n import _
from pic_utils import icon_from_theme

class PosterGenerator(QObject):
    def __init__(self, parent):
        super(PosterGenerator, self).__init__(parent)
        self._info = {}

        self._stickersHSpacing = 11
        self._stickersVSpacing = 28
        self._stickersLeftMargin = 22
        self._stickersBottomMargin = 40
        self._infoAreaHeight = 114
        self._timestampRightMargin = 6
        self._timestampBottomMargin = 6

        self._iconPos = QPoint(16, 28)
        self._iconSize = QSize(64, 64)

        _titlePosX = self._iconPos.x() + self._iconSize.width() + 18
        self._titlePos = QPoint(_titlePosX, 28)
        self._titleSize = QSize(380, 50)
        self._titleFontColor = Qt.white
        self._titleFontSize = 20

        self._durationPos = QPoint(self._titlePos.x(), 70)
        self._durationSize = QSize(200, 50)
        self._durationFontColor = QColor(255, 255, 255, 204)
        self._durationFontSize = 14

        self._resolutionPos = None # depends on the pos of duration
        self._resolutionSize = QSize(200, 50)
        self._resolutionFontColor = QColor(255, 255, 255, 204)
        self._resolutionFontSize = 14

        self._sizePos = None # depends on the pos of resolution
        self._sizeSize = QSize(200, 50)
        self._sizeFontColor = QColor(255, 255, 255, 204)
        self._sizeFontSize = 14

    @pyqtProperty(str)
    def title(self):
        return self._info.get("title", "")

    @title.setter
    def title(self, value):
        self._info["title"] = value

    @pyqtProperty(str)
    def duration(self):
        return self._info.get("duration", "")

    @duration.setter
    def duration(self, value):
        self._info["duration"] = value

    @pyqtProperty(str)
    def resolution(self):
        return self._info.get("resolution", "")

    @resolution.setter
    def resolution(self, value):
        self._info["resolution"] = value

    @pyqtProperty(str)
    def size(self):
        return self._info.get("size", "")

    @size.setter
    def size(self, value):
        self._info["size"] = value

    def _calculateResolution(self):
        _resolution = self.resolution.split("x")

        return QSize(int(_resolution[0]), int(_resolution[1]))

    # sticker size with its border
    def _calculateStickerSize(self):
        _resolution = self._calculateResolution()
        _widthHeightRation = _resolution.width() * 1.0 / _resolution.height()
        _width = 176
        _height = 176 / _widthHeightRation

        return QSize(_width + 2, _height + 2)

    def _calculateStickerRects(self):
        result = []
        _stickerSize = self._calculateStickerSize()

        for i in range(15):
            _x = i % 3 * (_stickerSize.width() + self._stickersHSpacing) \
                 + self._stickersLeftMargin
            _y = i / 3 * (_stickerSize.height() + self._stickersVSpacing) \
                 + self._infoAreaHeight
            rect = QRect(QPoint(_x, _y), _stickerSize)
            result.append(rect)

        return result

    def _calculateSize(self):
        _stickerSize = self._calculateStickerSize()
        _width = 600
        _height = self._infoAreaHeight \
                  + _stickerSize.height() * 5 \
                  + self._stickersVSpacing * 4 \
                  + self._stickersBottomMargin

        return QSize(_width, _height)

    def _drawText(self, painter, text, rect, fontColor, fontSize):
        _font = painter.font()
        _font.setPixelSize(fontSize)
        _align = Qt.AlignTop | Qt.AlignLeft
        painter.setPen(fontColor)
        painter.setFont(_font)
        painter.drawText(rect, _align, text)

        fm = painter.fontMetrics()

        return fm.boundingRect(rect, _align, text)

    def _drawSticker(self, painter, rect, sticker):
        # border
        painter.fillRect(rect, QColor(255, 255, 255, 50))

        # draw screenshot
        _timestamp, _path = sticker
        _pixmap = QPixmap(_path)
        _pixmap = _pixmap.scaled(QSize(rect.width() - 2, rect.height() - 2))
        painter.drawPixmap(rect.x() + 1, rect.y() + 1, _pixmap)

        # draw timestamp
        _font = painter.font()
        _font.setPixelSize(12)
        painter.setPen(QColor(255, 255, 255, 102))
        painter.setFont(_font)

        fm = painter.fontMetrics()
        _rect = fm.boundingRect(rect, Qt.AlignTop | Qt.AlignLeft, _timestamp)
        x = rect.x() \
            + rect.width() \
            - self._timestampRightMargin \
            - _rect.width()
        y = rect.y() \
            + rect.height() \
            - self._timestampBottomMargin \
            - _rect.height()
        painter.drawText(QPoint(x, y), _timestamp)

    @pyqtSlot("QVariant", result=str)
    def generate(self, stickers):
        size = self._calculateSize()

        pixmap = QPixmap(size)
        pixmap.fill(Qt.black)

        painter = QPainter(pixmap)

        # draw background
        gradientRect = QRect(0, 0, size.width(), 646)
        gradient = QLinearGradient(gradientRect.topLeft(),
                                   gradientRect.bottomLeft())
        gradient.setColorAt(0.0, QColor(23, 66, 134, 43.35))
        gradient.setColorAt(1.0, QColor(0, 0, 0, 0))

        painter.fillRect(gradientRect, gradient)

        # draw icon
        icon = icon_from_theme("Deepin", "deepin-movie")
        icon.paint(painter,
            self._iconPos.x(),
            self._iconPos.y(),
            self._iconSize.width(),
            self._iconSize.height())

        # draw title
        titleRect = QRect(self._titlePos.x(),
            self._titlePos.y(),
            self._titleSize.width(),
            self._titleSize.height())
        titleRect = self._drawText(painter, self.title, titleRect,
            self._titleFontColor, self._titleFontSize)

        # draw duration
        durationRect = QRect(self._durationPos.x(),
            self._durationPos.y(),
            self._durationSize.width(),
            self._durationSize.height())
        durationText = _("Duration") + _(":") \
                       + self.duration.encode("utf-8")
        durationRect = self._drawText(painter, durationText, durationRect,
            self._durationFontColor, self._durationFontSize)

        # draw resolution
        resolutionRect = QRect(durationRect.x() + durationRect.width() + 40,
            durationRect.y(),
            self._resolutionSize.width(),
            self._resolutionSize.height())
        resolutionText = _("Resolution") + _(":") \
                         + self.resolution.encode("utf-8")
        resolutionRect = self._drawText(painter, resolutionText, resolutionRect,
            self._resolutionFontColor, self._resolutionFontSize)

        # draw size
        sizeRect = QRect(resolutionRect.x() + resolutionRect.width() + 40,
            resolutionRect.y(),
            self._sizeSize.width(),
            self._sizeSize.height())
        sizeText = _("Size") + _(":") \
                   + self.size.encode("utf-8")
        sizeRect = self._drawText(painter, sizeText, sizeRect,
            self._sizeFontColor, self._sizeFontSize)

        # draw stickers
        rects = self._calculateStickerRects()
        for _index, _rect in enumerate(rects):
            self._drawSticker(painter, _rect, stickers[_index])

        painter.end()

        fileName = "%s.png" % mktemp()
        pixmap.save(fileName)

        return fileName