/**
 * Copyright (C) 2014 Deepin Technology Co., Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 **/

import QtQuick 2.2
import Com.Deepin.DeepinMovie 1.0

import "../sources/ui_utils.js" as UIUtils

Item {
    id: root

    property string saveDir: _utils.homeDir
    property int pieceCount: 15

    property bool __running: false
    property int __lastPiece: 0
    property int __lastPieceIndex: -1
    property var __stickers: []
    property int __startPosition: 0

    property string stickersDir: "/tmp/deepin-movie-poster"

    function _getPiece(index) {
        var durationAva = player.duration / pieceCount
        var start = index * durationAva

        return start + durationAva * Math.random()
    }

    function _takeShot() {
        player.videoCapture.captureDir = stickersDir
        player.videoCapture.capture()
    }

    function reset() {
        __running = false
        __lastPiece = 0
        __lastPieceIndex = -1
        __stickers = []
    }

    function start() {
        hideControls()
        notifybar.showPermanently(dsTr("Plot burst shooting, please wait..."))

        __running = true
        __startPosition = player.position
        player.pause()
        _next()
    }

    function _next() {
        __lastPieceIndex++
        if (__lastPieceIndex < pieceCount) {
            var piece = _getPiece(__lastPieceIndex)
            __lastPiece = piece
            player.seek(piece)
        } else {
            if (notifybar.text == dsTr("Plot burst shooting, please wait...")) {
                notifybar.hide()
            }

            var saveName = _utils.getVideoTitleFromUri(player.sourceString)
                           + " " + dsTr("Plot Burst Shooting")
                           + " " + Qt.formatDateTime(new Date(), "yyyyMMddhhmmss")
                           + ".png"

            var savePath = saveDir + "/" + saveName

            poster_generator.title = _utils.getFileNameFromUri(player.sourceString)
            poster_generator.duration = UIUtils.formatTime(player.duration)
            poster_generator.resolution = "%1x%2".arg(player.resolution.width).arg(player.resolution.height)
            poster_generator.size = UIUtils.formatSize(player.storageSize)

            poster_generator.generate(__stickers, savePath)
            picture_preview.showPicture(savePath,
                poster_generator.imageWidth,
                poster_generator.imageHeight)


            root.reset()
            player.seek(__startPosition)
        }
    }

    PosterGenerator { id: poster_generator }

    Connections {
        target: player
        onSeekFinished: {
            if (__running) {
                root._takeShot()
            }
        }
    }

    Connections {
        target: player.videoCapture
        onSaved: {
            if (__running) {
                __stickers.push([UIUtils.formatTime(__lastPiece), path])
                root._next()
            }
        }
    }
}