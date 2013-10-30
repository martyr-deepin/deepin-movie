import QtQuick 2.1
import QtMultimedia 5.0
import QtGraphicalEffects 1.0

Video {
    id: video
    autoPlay: true
	anchors.leftMargin: 1
	anchors.rightMargin: 1
	
	/* width: 800 */
	/* height: 400 */
	/* source: "/space/data/Video/DoctorWho/1.rmvb" */
	
	property string timeTotal: ""
	property string timeCurrent: ""
	property double timePosition: 0
	
	property bool showBottomPanel: false
	
	property alias videoPreview: videoPreview
	
	Component.onCompleted: {
		timeTotal = formatTime(video.duration)
	}
	
	onPositionChanged: {
		timeCurrent = formatTime(video.position)
		timePosition = video.position / video.duration
	}
	
	function formatTime(millseconds) {
		var secs = Math.floor(millseconds / 1000)
        var hr = Math.floor(secs / 3600);
        var min = Math.floor((secs - (hr * 3600))/60);
        var sec = secs - (hr * 3600) - (min * 60);
 		 
        if (hr < 10) {hr = "0" + hr; }
        if (min < 10) {min = "0" + min;}
        if (sec < 10) {sec = "0" + sec;}
        if (hr) {hr = "00";}
        return hr + ':' + min + ':' + sec;
    }

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
			/* video.seek(1700000) */
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
			interval: 2000
			repeat: false
			onTriggered: {
				hidingAnimation.restart()
				videoArea.cursorShape = Qt.BlankCursor
			}
		}
	}

	Rectangle {
		id: bottomPanel
		color: Qt.rgba(0, 0, 0, 0.95)
		height: hideHeight
		anchors.left: video.left
		anchors.right: video.right
		y: video.height - height
		/* opacity: hideOpacity */
		opacity: 1
		
		property double showHeight: 60
		property double hideHeight: 0
		
		property double showOpacity: 0.9
		property double hideOpacity: 0
		
		MouseArea {
			id: bottomPanelArea
			anchors.fill: parent
			hoverEnabled: true
			
			onPositionChanged: {
				hidingTimer.stop()
			}
			
			onExited: {
				hidingTimer.restart()
			}
		}
		
		Column {
			anchors.fill: parent
			
			Item {
				id: progressbar
				anchors.top: parent.top
				anchors.left: parent.left
				anchors.right: parent.right

				Rectangle {
					id: progressbarBackground
					anchors.top: parent.top
					anchors.left: parent.left
					anchors.right: parent.right
					/* height: 3 */
					height: 10
					color: Qt.rgba(100, 100, 100, 0.2)
					visible: showBottomPanel ? 1 : 0
					
					Text {
						id: playTime
						anchors.left: parent.left
						anchors.top: progressbarBackground.bottom
						anchors.leftMargin: 10
						text: timeCurrent + " / " + timeTotal
						color: Qt.rgba(100, 100, 100, 1)
						font.pixelSize: 10
						visible: showBottomPanel ? 1 : 0
					}
					
					MouseArea {
						id: progressbarArea
						anchors.fill: parent
						hoverEnabled: true
						
						onClicked: {
							video.seek(video.duration * mouseX / (progressbarBackground.width - progressbarBackground.x))
						}
						
						onPositionChanged: {
							hidingTimer.stop()
							
							videoPreview.visible = true
							videoPreview.x = Math.max(Math.min(mouseX - videoPreview.width / 2, progressbarArea.width - videoPreview.width), 0)
							videoPreview.y = progressbarArea.y - videoPreview.height
							
							var videoPosition = video.duration * mouseX / (progressbarBackground.width - progressbarBackground.x)
							videoPreview.video.seek(videoPosition)
							videoPreview.video.pause()
							
							videoPreview.videoTime.text = formatTime(videoPosition)
							
							/* if (mouseX < videoPreview.width / 2) { */
							/* 	videoPreview.triangleArea.anchors.leftMargin = mouseX */
							/* 	videoPreview.triangleArea.anchors.rightMargin = videoPreview.previewRectangle.width - videoPreview.triangleWidth - mouseX */
							/* } else { */
							/* 	videoPreview.triangleArea.anchors.leftMargin = mouseX */
							/* 	videoPreview.triangleArea.anchors.rightMargin = videoPreview.previewRectangle.width - videoPreview.triangleWidth - mouseX */
							/* } */
						}
						
						onExited: {
							videoPreview.visible = false
						}
					}
					
					Preview {
						id: videoPreview
						visible: false
					}
					
					LinearGradient {
						id: progressbarForeground
						anchors.left: parent.left
						anchors.top: parent.top
						height: parent.height
						width: timePosition * parent.width
						start: Qt.point(0, 0)
						end: Qt.point(width, 0)
						gradient: Gradient {
							GradientStop { position: 0.0; color: Qt.rgba(19 / 255.0, 48 / 255.0, 104 / 255.0, 0.5)}
							GradientStop { position: 0.95; color: Qt.rgba(33 / 255.0, 91 / 255.0, 210 / 255.0, 0.8)}
							GradientStop { position: 1.0; color: Qt.rgba(33 / 255.0, 91 / 255.0, 210 / 255.0, 0.5)}
						}
						visible: showBottomPanel ? 1 : 0
					}
				}
			}
			
			Item {
				id: buttonArea
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter
				
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
						visible: showBottomPanel ? 1 : 0
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
						visible: showBottomPanel ? 1 : 0
					}
					ImageButton {
						id: playerBackward
						imageName: "image/player_backward"
						anchors.verticalCenter: playerPlay.verticalCenter
						visible: showBottomPanel ? 1 : 0
					}
					ImageButton {
						id: playerPlay
						imageName: video.playbackState == MediaPlayer.PlayingState ? "image/player_pause" : "image/player_play"
						onClicked: {
							toggle()
						}
						visible: showBottomPanel ? 1 : 0
					}
					ImageButton {
						id: playerForward
						imageName: "image/player_forward"
						anchors.verticalCenter: playerPlay.verticalCenter
						visible: showBottomPanel ? 1 : 0
					}
					ImageButton {
						id: playerOpen
						imageName: "image/player_open"
						anchors.verticalCenter: playerPlay.verticalCenter
						visible: showBottomPanel ? 1 : 0
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
						visible: showBottomPanel ? 1 : 0
					}

					ImageButton {
						id: playerConfig
						imageName: "image/player_config"
						anchors.verticalCenter: parent.verticalCenter
						visible: showBottomPanel ? 1 : 0
					}
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
			target: bottomPanel
			property: "height"
			to: bottomPanel.showHeight
			duration: 100
			easing.type: Easing.OutBack
		}

		onRunningChanged: {
			if (!showingAnimation.running) {
				showBottomPanel = true
			}
		}
	}	

	ParallelAnimation{
		id: hidingAnimation
		alwaysRunToEnd: true
		
		PropertyAnimation {
			target: bottomPanel
			property: "height"
			to: bottomPanel.hideHeight
			duration: 100
			easing.type: Easing.OutBack
		}
		
		onRunningChanged: {
			if (!showingAnimation.running) {
				showBottomPanel = false
			}
		}
	}	
}
