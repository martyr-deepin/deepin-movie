/**
 * Copyright (C) 2014 Deepin Technology Co., Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 **/

import QtQuick 2.2

import "../sources/ui_utils.js" as UIUtils

Item {
    property string saveDir: _utils.homeDir

    property bool __running: false
    property int __timestamp: 0
    property string __tmpDir: "/tmp/deepin-movie-screenshots"

    function start() {
        __running = true
        __timestamp = player.position
        player.videoCapture.captureDir = __tmpDir
        player.videoCapture.capture()
    }

    Connections {
        target: player.videoCapture
        onSaved: {
            if (__running) {
                __running = false

                var saveName = _utils.getVideoTitleFromUri(player.sourceString)
                               + " " + dsTr("Movie Screenshot")
                               + " " + UIUtils.formatTime2(__timestamp)
                               + ".png"

                var savePath = saveDir + "/" + saveName

                _utils.rotatePicture(path, player.orientation, path)
                _utils.flipPicture(path, player.horizontallyFlipped, player.verticallyFlipped, savePath)
                _utils.notify(dsTr("Deepin Movie"), dsTr("Your screenshot has been saved to %1").arg(savePath))
            }
        }
    }
}