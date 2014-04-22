import QtQuick 2.1

// After some digging you will find that this file is somehow twisted with
// main.qml(where some ids are from), because the content of this file is 
// mainly extracted from main.qml :)
Connections {
    target: _menu_controller
    
    onClockwiseRotate: {
        player.orientation -= 90
    }
    onAntiClosewiseRotate: {
        player.orientation += 90
    }
    onToggleFullscreen: {
        main_controller.toggleFullscreen()
    }
    onScreenShot: {
        windowView.screenShot()
    }
    onProportionChanged: {
        root.widthProportion = propWidth / propHeight
    }
    onScaleChanged: {
        root.widthProportion = scale
        root.heightProportion = scale
    }
    onStaysOnTop: {
        windowView.staysOnTop = onTop
    }
    onOpenDialog: {
        if (arguments[0] == "file") {
            open_file_dialog.open()
        } else if (arguments[0] == "dir") {
            open_folder_dialog.open()
        } else {
            var value = _input_dialog.show()
            if (value != "") { movieInfo.movie_file = value }
        }
    }
}
