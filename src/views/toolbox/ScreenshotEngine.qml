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

           		var saveName = _utils.getTitleFromUrl(player.sourceString)
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