import QtQuick 2.0
import QtMultimedia 5.0

Video {
    id: video
    autoPlay: true
	
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
		}
		
		Timer {
			id: hidingTimer
			interval: 2000  // hide after 2s
			repeat: false
			onTriggered: {
				hidingAnimation.restart()
			}
		}
	}

	Rectangle {
		id: playPanel
		color: Qt.rgba(0, 0, 0, 0.9)
		height: 60
		anchors.left: video.left
		anchors.right: video.right
		
		property int showY: video.height - height - 2
		property int hideY: video.height - 2
		
		Component.onCompleted: {
			y = hideY
			opacity = 0
		}
		
		Row {
			anchors.horizontalCenter: parent.horizontalCenter
			anchors.verticalCenter: parent.verticalCenter
			spacing: 5
			
			ImageButton {
				id: playerBackward
				imageName: "image/player_backward"
				anchors.verticalCenter: playerPlay.verticalCenter
				onClicked: {
					backward()
				}
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
				onClicked: {
					forward()
				}
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
			target: playPanel
			property: "y"
			to: playPanel.showY
			duration: 200
			easing.type: Easing.OutBack
		}
		PropertyAnimation { 
			target: playPanel
			property: "opacity"
			to: 0.9
			duration: 200
			easing.type: Easing.OutBack
		}		
	}	

	ParallelAnimation{
		id: hidingAnimation
		alwaysRunToEnd: true
		
		PropertyAnimation { 
			target: playPanel
			property: "opacity"
			to: 0
			duration: 200
			easing.type: Easing.InBack
		}		
		PropertyAnimation {
			target: playPanel
			property: "y"
			to: playPanel.hideY
			duration: 200
			easing.type: Easing.InBack
		}
	}	
}
