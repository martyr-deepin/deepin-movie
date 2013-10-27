import QtQuick 2.0
import QtMultimedia 5.0

Video {
    id: video
    autoPlay: true

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (playbackState == MediaPlayer.PlayingState)
                pause()
            else
                play()
				
			console.log("*****************")	
        }
    }

	Rectangle {
		id: playPanel
		color: Qt.rgba(0, 0, 0, 0.9)
		height: 60
		anchors.left: playPage.left
		anchors.right: playPage.right
		anchors.bottom: playPage.bottom
		/* visible: false */
		
		Row {
			anchors.horizontalCenter: parent.horizontalCenter
			anchors.verticalCenter: parent.verticalCenter
			spacing: 5
			
			ImageButton {
				id: playerBackward
				imageName: "image/player_backward"
				anchors.verticalCenter: playerPlay.verticalCenter
			}
			ImageButton {
				id: playerPlay
				imageName: "image/player_play"
			}
			ImageButton {
				id: playerForward
				imageName: "image/player_forward"
				anchors.verticalCenter: playerPlay.verticalCenter
			}
		}
	}
			
    focus: true
    Keys.onSpacePressed: video.paused = !video.paused
    Keys.onLeftPressed: video.position -= 5000
    Keys.onRightPressed: video.position += 5000

    function setSource(s) {
        pause()
        source: s
    }
}