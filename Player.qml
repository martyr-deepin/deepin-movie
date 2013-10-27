import QtQuick 2.0
import QtMultimedia 5.0

Video {
    id: video
    autoPlay: true
	anchors.leftMargin: 1
	anchors.rightMargin: 1
	
	/* width: 800 */
	/* height: 400 */
	/* source: "/space/data/Video/DoctorWho/1.rmvb" */

	function toggle() {
		video.playbackState == MediaPlayer.PlayingState ? video.pause() : video.play()
	}
	
	function forward() {
		video.seek(video.position + 5000)
	}
	
	function backward() {
		video.seek(video.position - 5000)
	}
	
    MouseArea {
		id: videoArea
		anchors.fill: parent
		hoverEnabled: true
		
		onClicked: {
			toggle()
		}
		
		onPositionChanged: {
			showingAnimation.restart()
			hidingTimer.restart()

			videoArea.cursorShape = Qt.ArrowCursor
		}
		
		onExited: {
			videoArea.cursorShape = Qt.ArrowCursor
		}
		
		Timer {
			id: hidingTimer
			interval: 2000  // hide after 2s
			repeat: false
			onTriggered: {
				hidingAnimation.restart()
				videoArea.cursorShape = Qt.BlankCursor
			}
		}
	}

	Rectangle {
		id: bottomPanel
		color: Qt.rgba(0, 0, 0, 0.9)
		height: 60
		anchors.left: video.left
		anchors.right: video.right
		y: video.height - height - 2
		opacity: hideOpacity
		
		property double showOpacity: 0.9
		property double hideOpacity: 0
		
		Row {
			id: leftButtonArea
			anchors.left: parent.left
			anchors.leftMargin: 10
			anchors.verticalCenter: parent.verticalCenter
			spacing: 5
			
			ImageButton {
				id: playerList
				imageName: "image/player_list"
				anchors.verticalCenter: parent.verticalCenter
			}
		}
		
		Row {
			id: middleButtonArea
			anchors.horizontalCenter: parent.horizontalCenter
			anchors.verticalCenter: parent.verticalCenter
			spacing: 5
			
			ImageButton {
				id: playerStop
				imageName: "image/player_stop"
				anchors.verticalCenter: playerPlay.verticalCenter
				onClicked: {
					video.stop()
				}
			}
			ImageButton {
				id: playerBackward
				imageName: "image/player_backward"
				anchors.verticalCenter: playerPlay.verticalCenter
			}
			ImageButton {
				id: playerPlay
				imageName: video.playbackState == MediaPlayer.PlayingState ? "image/player_pause" : "image/player_play"
				onClicked: {
					toggle()
				}
			}
			ImageButton {
				id: playerForward
				imageName: "image/player_forward"
				anchors.verticalCenter: playerPlay.verticalCenter
			}
		}

		Row {
			id: rightButtonArea
			anchors.right: parent.right
			anchors.rightMargin: 10
			anchors.verticalCenter: parent.verticalCenter
			spacing: 5
			
			ImageButton {
				id: playerVolume
				imageName: "image/player_volume"
				anchors.verticalCenter: parent.verticalCenter
			}
		}
	}
			
    focus: true
    Keys.onSpacePressed: toggle()
    Keys.onLeftPressed: backward()
    Keys.onRightPressed: forward()

	ParallelAnimation{
		id: showingAnimation
		alwaysRunToEnd: true
		
		PropertyAnimation { 
			target: bottomPanel
			property: "opacity"
			to: bottomPanel.showOpacity
			duration: 200
			easing.type: Easing.OutBack
		}		
	}	

	ParallelAnimation{
		id: hidingAnimation
		alwaysRunToEnd: true
		
		PropertyAnimation { 
			target: bottomPanel
			property: "opacity"
			to: bottomPanel.hideOpacity
			duration: 200
			easing.type: Easing.InBack
		}		
	}	
}
