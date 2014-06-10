import QtQuick 2.1

// After some digging you will find that this file is somehow twisted with
// main.qml(where some ids are from), because the content of this file is 
// mainly extracted from main.qml :)
Connections {
    target: _menu_controller
    
    onClockwiseRotate: {
        main_controller.rotateClockwise()
    }
    onAntiClosewiseRotate: {
        main_controller.rotateAnticlockwise()
    }
    onFlipHorizontal: {
        main_controller.flipHorizontal()
    }
    onFlipVertical: {
        main_controller.flipVertical()
    }
    onToggleFullscreen: {
        main_controller.toggleFullscreen()
    }
    onScreenShot: {
        windowView.screenShot()
    }
    onProportionChanged: {
        var widthHeightScale = propWidth / propHeight
        if (root.height * widthHeightScale > primaryRect.width) {
            windowView.setHeight((primaryRect.width) / widthHeightScale)
            windowView.setWidth(primaryRect.width)
        }
        root.widthHeightScale = widthHeightScale
        windowView.setWidth(root.height * widthHeightScale)
    }
    onScaleChanged: {
        if (primaryRect.width / primaryRect.height > movieInfo.movie_width / movieInfo.movie_height) {
            if (movieInfo.movie_width * scale > primaryRect.width) {
                windowView.setWidth(primaryRect.width)
                windowView.setHeight(primaryRect.width / root.widthHeightScale)
            } else {
                windowView.setWidth(movieInfo.movie_width * scale)
                windowView.setHeight(movieInfo.movie_width * scale / root.widthHeightScale)
            }
        } else {
            if (movieInfo.movie_height * scale > primaryRect.height) {
                windowView.setHeight(primaryRect.height)
                windowView.setWidth(primaryRect.height * root.widthHeightScale)
            } else {
                windowView.setHeight(movieInfo.movie_height * scale)
                windowView.setWidth(movieInfo.movie_height * scale * root.widthHeightScale)
            }
        }
    }
    onStaysOnTop: {
        windowView.staysOnTop = onTop
    }
    onOpenDialog: {
        if (arguments[0] == "file") {
            main_controller.openFile()
        } else if (arguments[0] == "dir") {
            main_controller.openDir()
        } else {
            var value = _input_dialog.show()
            if (value != "") { movieInfo.movie_file = value }
        }
    }

    onOpenSubtitleFile: { open_file_dialog.purpose = purposes.openSubtitleFile; open_file_dialog.open() }

    onSubtitleSelected: movieInfo.subtitle_file = subtitle

    onShowPreference: { preference_window.show() }

    onShowMovieInformation: { player.source && player.hasVideo && info_window.show() }
}
