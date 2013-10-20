import QtQuick 2.1
import QtGraphicalEffects 1.0

Item {
	id: window
	
	property int titlebarHeight: 26
	property int frameRadius: 3
	property int shadowRadius: 5
	property double shadowMultiplier: 2.5

	property bool isMax: false
	
	function toggleMaxWindow() {
		isMax ? windowView.showNormal() : windowView.showMaximized()
		isMax ? maxButton.imageName = "image/window_max" : maxButton.imageName = "image/window_unmax"
		isMax ? shadow.visible = true : shadow.visible = false
		isMax ? frame.border.width = shadowRadius * shadowMultiplier : frame.border.width = 0
		isMax ? frame.radius = frameRadius : frame.radius = 0
		
		isMax = !isMax
	}

    RectangularGlow {
        id: shadow
        anchors.fill: frame
        glowRadius: shadowRadius
        spread: 0.2
        color: Qt.rgba(0, 0, 0, 0.3)
        /* color: Qt.rgba(200, 0, 0, 0.8) /\* this code just for test shadow *\/ */
        cornerRadius: frame.radius + shadowRadius
		visible: true
    }
	
    Rectangle {
        id: frame
		opacity: 0.5
        color: Qt.rgba(200, 200, 200, 1)
        anchors.centerIn: parent
        radius: frameRadius
		border.width: shadowRadius * shadowMultiplier
		border.color: Qt.rgba(0, 0, 0, 0)
		width: window.width - border.width
		height: window.height - border.width
    }
	
	MouseArea {
        id: titlebar
        anchors.top: frame.top
		width: frame.width
        height: titlebarHeight
		property real lastMouseX: 0
        property real lastMouseY: 0
        onPressed: {
            lastMouseX = mouseX
            lastMouseY = mouseY
        }
        onMouseXChanged: windowView.x += (mouseX - lastMouseX)
        onMouseYChanged: windowView.y += (mouseY - lastMouseY)
		onDoubleClicked: {toggleMaxWindow()}
		
		Row {
			anchors {right: parent.right}
			id: windowButtonArea
			
			ImageButton {
				id: themeButton
				imageName: "image/window_theme"
			}

			ImageButton {
				id: minButton
				imageName: "image/window_min"
				onClicked: {windowView.showMinimized()}
			}

			ImageButton {
				id: maxButton
				imageName: "image/window_max"
				onClicked: {toggleMaxWindow()}
			}

			ImageButton {
				id: closeButton
				imageName: "image/window_close"
				onClicked: {qApp.quit()}
			}
		}
    }
}

