import QtQuick 2.1
import QtMultimedia 5.0
import QtGraphicalEffects 1.0

ImageButton {
	id: volumeButton
	
	imageName: "image/player_volume"
	
	property alias volumebar: volumebar
	property double volume: 1.0
	property int hideWidth: 0.0
	property int showWidth: 60.0
	property int hidePosition: hideWidth
	property int showPosition: volume * showWidth
	
	signal inVolumebar
	signal changeVolume
	
	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
		
		onPositionChanged: {
			volumeButton.inVolumebar()
			
			volumebar.width = showWidth
			volumePositionBar.width = showPosition
			
			hideVolumebarTimer.start()
		}
	}
	
	Rectangle {
		id: volumebar
		anchors.left: parent.right
		anchors.verticalCenter: parent.verticalCenter
		anchors.leftMargin: 5
		width: hideWidth
		height: 5
		color: Qt.rgba(2, 2, 2, 0.2)
		
		LinearGradient {
			id: volumePositionBar
			anchors.left: parent.left
			anchors.top: parent.top
			height: parent.height
			width: hidePosition
			start: Qt.point(0, 0)
			end: Qt.point(width, 0)
			gradient: Gradient {
				GradientStop { position: 0.0; color: Qt.rgba(19 / 255.0, 48 / 255.0, 104 / 255.0, 0.5)}
				GradientStop { position: 0.95; color: Qt.rgba(33 / 255.0, 91 / 255.0, 210 / 255.0, 0.8)}
				GradientStop { position: 1.0; color: Qt.rgba(33 / 255.0, 91 / 255.0, 210 / 255.0, 0.5)}
			}
			
			Behavior on width {
				NumberAnimation {
					duration: 50
					easing.type: Easing.OutQuint
				}
			}
		}
		
		Behavior on width {
			NumberAnimation {
				duration: 300
				easing.type: Easing.OutQuint
			}
		}
	}
	
	MouseArea {
		id: volumebarArea
		anchors.top: volumebar.top
		anchors.bottom: volumebar.bottom
		anchors.left: volumebar.left
		anchors.right: volumebar.right
		hoverEnabled: true

		onClicked: {
			volume = mouseX / showWidth
			volumePositionBar.width = showPosition
			volumeButton.changeVolume()
		}
		
		onPositionChanged: {
			volumeButton.inVolumebar()
			
			volumebar.width = showWidth
			volumePositionBar.width = showPosition
			
			hideVolumebarTimer.stop()
		}
		
		onExited: {
			hideVolumebarTimer.start()
		}
		
		onWheel: {
			volume = Math.max(Math.min(volume + (wheel.angleDelta.y / 120 * 0.05), 1.0), 0.0)
			volumePositionBar.width = showPosition
			volumeButton.changeVolume()
		}
	}

	Timer {
		id: hideVolumebarTimer
		interval: 2000
		repeat: false
		onTriggered: {
			volumebar.width = hideWidth
			volumePositionBar.width = hidePosition
		}
	}
}
