import QtQuick 2.1
import QtGraphicalEffects 1.0

Item {
    width: 300
    height: 300
	property int frameRadius: 3
	property int shadowRadius: 10

    Rectangle {
        id: background
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0)
    }

    RectangularGlow {
        id: effect
        anchors.fill: rect
        glowRadius: shadowRadius
        spread: 0.2
        color: Qt.rgba(0, 0, 0, 0.2)
        cornerRadius: rect.radius + shadowRadius
    }
	
    Rectangle {
        id: rect
		opacity: 0.5
        color: Qt.rgba(200, 200, 200, 1)
        anchors.centerIn: parent
        width: Math.round(parent.width - shadowRadius * 2.5)
        height: Math.round(parent.height - shadowRadius * 2.5)
        radius: frameRadius
    }
}

