import QtQuick 2.1
import QtMultimedia 5.0
import QtGraphicalEffects 1.0

Video {
    id: video
    autoPlay: true
	/* muted: true */
	anchors.leftMargin: 1
	anchors.rightMargin: 1
	
	property string timeTotal: ""
	property string timeCurrent: ""
	property double timePosition: 0
	property double videoPosition: 0
	
	property bool showBottomPanel: false
	
	property double showHeight: 60
	property double hideHeight: 0
	
	property alias videoPreview: videoPreview
	property alias videoArea: videoArea
	property alias hidingBottomPanelAnimation: hidingBottomPanelAnimation
	
	signal playlistButtonClicked
	signal bottomPanelShow
	signal bottomPanelHide
	signal hideCursor
	signal showCursor
	signal toggleFullscreen
	
	Component.onCompleted: {
		timeTotal = formatTime(video.duration)
	}
	
	onPositionChanged: {
		timeCurrent = formatTime(video.position)
		timePosition = video.position / video.duration
	}
	
	onToggleFullscreen: {
		indicatorArea.visible = windowView.getState() != Qt.WindowFullScreen
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
	
	Rectangle {
		id: indicatorArea
		anchors.top: parent.top
		anchors.right: parent.right
		anchors.topMargin: 10
		visible: false
		width: 80
		
		Text {
			id: timeIndicator
			anchors.horizontalCenter: parent.horizontalCenter
			text: ""
			font.pixelSize: 20
			color: "#80999999"
			style: Text.Outline
			styleColor: "#FF333333"
			
			Timer {
				interval: 1000;
				running: true;
				repeat: true
				onTriggered: {
					timeIndicator.text = Qt.formatDateTime(new Date(), "hh:mm")
				}
			}
		}

		Row {
			id: positionIndicator
			spacing: 2
			anchors.horizontalCenter: parent.horizontalCenter
			anchors.top: timeIndicator.bottom
			
			property int dotSize: 3
			
			Repeater {
				model: 10
				delegate: Rectangle {
					color: video.position / video.duration * 10 > index ? "#80DDDDDD" : "#80666666"
					width: positionIndicator.dotSize
					height: positionIndicator.dotSize
				}
			}
		}
	}
	
    InteractiveArea {
		id: videoArea
		anchors.fill: parent
		hoverEnabled: true
		
		property real windowViewX: 0
        property real windowViewY: 0

		property real lastMouseX: 0
        property real lastMouseY: 0

		property bool isHover: false
		property bool isDoubleClick: false

		property int maskHeight: 30
		
        onPressed: {
			isHover = false
			isDoubleClick = false
			
			lastMouseX = mouseX
			lastMouseY = mouseY
        }
		
		onClicked: {
			if (!isHover) {
				clickTimer.restart()
			}
		}
		
		onDoubleClicked: {
			isDoubleClick = true
			video.toggleFullscreen()
		}
		
		onPositionChanged: {
			if (!showingBottomPanelAnimation.running) {
				showingBottomPanelAnimation.restart()
			}
			hidingTimer.restart()

			isHover = true
			video.showCursor()
			
			if (pressedButtons == Qt.LeftButton) {
				windowView.x += mouseX - lastMouseX
				windowView.y += mouseY - lastMouseY
			}
		}

		onExited: {
			video.showCursor()
		}
		
		Timer {
			id: hidingTimer
			interval: 2000
			repeat: false
			onTriggered: {
				if (!hidingBottomPanelAnimation.running) {
					hidingBottomPanelAnimation.restart()
				}
				video.hideCursor()
			}
		}
		
		Timer {
			id: clickTimer
			interval: 200
			repeat: false
			onTriggered: {
				if (!videoArea.isDoubleClick) {
					toggle()
				}
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
		opacity: 1
		
		property double showOpacity: 0.9
		property double hideOpacity: 0
		
		InteractiveArea {
			id: bottomPanelArea
			anchors.fill: parent
			hoverEnabled: true
			property real lastMouseX: 0
			property real lastMouseY: 0
			
			onPressed: {
				lastMouseX = mouseX
				lastMouseY = mouseY
			}
			
			onPositionChanged: {
				hidingTimer.stop()
				
				if (pressedButtons == Qt.LeftButton) {
					windowView.x += mouseX - lastMouseX
					windowView.y += mouseY - lastMouseY
				}
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
					
					InteractiveArea {
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
							
							videoPosition = video.duration * mouseX / (progressbarBackground.width - progressbarBackground.x)
							
							videoPreview.video.visible = false
							updatePreviewTimer.restart()
							
							videoPreview.videoTime.text = formatTime(videoPosition)
							
							var minOffsetX = 10
							
							if (mouseX < videoPreview.width / 2) {
								videoPreview.triangleArea.drawOffsetX = Math.max(mouseX, minOffsetX)
							} else if (mouseX > progressbarArea.width - videoPreview.width / 2) {
								var offsetX = Math.min(mouseX - (progressbarArea.width - videoPreview.width / 2),
													  videoPreview.triangleArea.width / 2 - minOffsetX * 2)
								videoPreview.triangleArea.drawOffsetX = videoPreview.triangleArea.defaultOffsetX + offsetX
							} else {
								videoPreview.triangleArea.drawOffsetX = videoPreview.triangleArea.defaultOffsetX
							}
						}
						
						onExited: {
							videoPreview.visible = false
						}
						
						Timer {
							id: updatePreviewTimer
							interval: 50
							repeat: false
							onTriggered: {
								videoPreview.video.seek(videoPosition)
							}
						}
					}
					
					Preview {
						id: videoPreview
						visible: false
						
						onPositionChanged: {
							videoPreview.video.visible = true
						}
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
						
						onClicked: {
							video.playlistButtonClicked()
						}
					}
					
					ImageButton {
						id: playerConfig
						imageName: "image/player_config"
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
						id: playerOpen
						imageName: "image/player_open"
						anchors.verticalCenter: playerPlay.verticalCenter
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
					VolumeButton {
						id: playerVolume
						anchors.verticalCenter: parent.verticalCenter
						visible: showBottomPanel ? 1 : 0
						
						onInVolumebar: {
							hidingTimer.stop()
						}
						
						onChangeVolume: {
							video.volume = playerVolume.volume
						}
					}
				}

				Row {
					id: rightButtonArea
					anchors.right: parent.right
					anchors.rightMargin: 10
					anchors.verticalCenter: parent.verticalCenter
					spacing: 5
					
					Text {
						id: playTime
						anchors.verticalCenter: parent.verticalCenter
						text: timeCurrent + " / " + timeTotal
						color: Qt.rgba(100, 100, 100, 1)
						font.pixelSize: 12
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
	Keys.onEscapePressed: {
		if (windowView.getState() == Qt.WindowFullScreen) {
			video.toggleFullscreen()
		}
	}

	ParallelAnimation{
		id: showingBottomPanelAnimation
		alwaysRunToEnd: true
		
		PropertyAnimation {
			target: bottomPanel
			property: "height"
			to: showHeight
			duration: 100
			easing.type: Easing.OutBack
		}

		onStarted: {
			video.bottomPanelShow()
		}
		
		onRunningChanged: {
			if (!showingBottomPanelAnimation.running) {
				showBottomPanel = true
			}
		}
	}	

	ParallelAnimation{
		id: hidingBottomPanelAnimation
		alwaysRunToEnd: true
		
		PropertyAnimation {
			target: bottomPanel
			property: "height"
			to: hideHeight
			duration: 100
			easing.type: Easing.OutBack
		}
		
		onStarted: {
			video.bottomPanelHide()
		}
		
		onRunningChanged: {
			if (!showingBottomPanelAnimation.running) {
				showBottomPanel = false
			}
		}
	}	
}
