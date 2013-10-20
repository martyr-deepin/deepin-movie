import QtQuick 2.1
import QtGraphicalEffects 1.0

Item {
	id: window
	
	property int titlebarHeight: 26
	property int frameRadius: 3
	property int shadowRadius: 5
	property double shadowMultiplier: 2.5

	property bool isMax: false
	
	function toggleWindow() {
		isMax ? windowView.showNormal() : windowView.showMaximized()
		isMax ? maxButton.imageName = "image/window_max" : maxButton.imageName = "image/window_unmax" 
		isMax ? shadow.visible = true : shadow.visible = false
		isMax = !isMax
	}

    RectangularGlow {
        id: shadow
        anchors.fill: frame
        glowRadius: shadowRadius
        spread: 0.2
        /* color: Qt.rgba(0, 0, 0, 0.3) */
        color: Qt.rgba(200, 0, 0, 0.8)
        cornerRadius: frame.radius + shadowRadius
		visible: true
    }
	
    Rectangle {
        id: frame
		opacity: 0.5
        color: Qt.rgba(200, 200, 200, 1)
        anchors.centerIn: parent
        width: Math.round(window.width - shadowRadius * shadowMultiplier)
        height: Math.round(window.height - shadowRadius * shadowMultiplier)
        radius: frameRadius
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
		onDoubleClicked: {toggleWindow()}
		
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
				onClicked: {toggleWindow()}
			}

			ImageButton {
				id: closeButton
				imageName: "image/window_close"
				onClicked: {qApp.quit()}
			}
		}
    }
}

