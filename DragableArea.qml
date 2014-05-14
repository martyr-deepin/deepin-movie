import QtQuick 2.1

MouseArea {
	property var window
	property int startX
	property int startY

	onPressed: { startX = mouse.x; startY = mouse.y }
	onPositionChanged: { 
		window.setX(window.x + mouse.x - startX)
		window.setY(window.y + mouse.y - startY)
	}
}