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
			/* toggle() */
			video.seek(1700000)
		}
		
		onPositionChanged: {
			showingAnimation.restart()
			hidingTimer.restart()

			videoArea.cursorShape = Qt.ArrowCursor
			
			console.log("$$$$$$$$$$$$$$$$$$$")
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
		color: Qt.rgba(0, 0, 0, 0.95)
		height: 60
		anchors.left: video.left
		anchors.right: video.right
		y: video.height - height
		opacity: hideOpacity
		
		property double showOpacity: 0.9
		property double hideOpacity: 0
		
		MouseArea {
			id: bottomPanelArea
			anchors.fill: parent
			hoverEnabled: true
			
			onPositionChanged: {
				hidingTimer.stop()
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
					height: normalHeight
					color: Qt.rgba(100, 100, 100, 0.2)
					
					property int normalHeight: 3
					property int handleHeight: 6
					
					Text {
						id: playTime
						anchors.left: parent.left
						anchors.top: progressbarBackground.bottom
						anchors.leftMargin: 10
						text: timeCurrent + " / " + timeTotal
						color: Qt.rgba(100, 100, 100, 1)
						font.pixelSize: 10
					}			
					
					MouseArea {
						id: progressbarArea
						anchors.fill: parent
						hoverEnabled: true
						onPositionChanged: {
							progressbarBackground.height = progressbarBackground.handleHeight
						}
						
						onExited: {
							progressbarBackground.height = progressbarBackground.normalHeight
						}
					}
					
					LinearGradient {
						id: progressbarForeground
						anchors.left: parent.left
						anchors.top: parent.top
						height: parent.height
						width: timePosition * parent.width
						start: Qt.point(0, 0)
						end: Qt.point(10, 0)
						gradient: Gradient {
							GradientStop { id: progressStopStart; position: 0.0; color: Qt.rgba(19 / 255.0, 48 / 255.0, 104 / 255.0, 0.5)}
							GradientStop { id: progressStopPoint; position: 1.0; color: Qt.rgba(33 / 255.0, 91 / 255.0, 210 / 255.0, 0.8)}
						}
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
					ImageButton {
						id: playerOpen
						imageName: "image/player_open"
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

					ImageButton {
						id: playerConfig
						imageName: "image/player_config"
						anchors.verticalCenter: parent.verticalCenter
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
