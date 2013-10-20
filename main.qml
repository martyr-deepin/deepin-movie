/* import QtQuick 2.1 */
/* import QtQuick.Window 2.0 */
 
/* Window { */
/*     id: window */
/*     visible: true */
/*     width: 100 */
/*     height: 100 */
/*     flags: Qt.FramelessWindowHint */
 
/*     Rectangle { */
/*         color: "steelblue" */
/*         anchors.top: parent.top */
/*         width: parent.width */
/*         height: 20 */
/*         MouseArea { */
/*             anchors.fill: parent */
/*             property real lastMouseX: 0 */
/*             property real lastMouseY: 0 */
/*             onPressed: { */
/*                 lastMouseX = mouseX */
/*                 lastMouseY = mouseY */
/*             } */
/*             onMouseXChanged: window.x += (mouseX - lastMouseX) */
/*             onMouseYChanged: window.y += (mouseY - lastMouseY) */
/*         } */
/*     } */
/* } */

import QtQuick 2.1
import QtGraphicalEffects 1.0

Item {
	id: window
    width: 600
    height: 400
	
	property int frameRadius: 3
	property int shadowRadius: 5

    RectangularGlow {
        id: shadow
        anchors.fill: frame
        glowRadius: shadowRadius
        spread: 0.2
        color: Qt.rgba(0, 0, 0, 0.3)
        cornerRadius: frame.radius + shadowRadius
    }
	
    Rectangle {
        id: frame
		opacity: 0.5
        color: Qt.rgba(200, 200, 200, 1)
        anchors.centerIn: parent
        width: Math.round(parent.width - shadowRadius * 2.5)
        height: Math.round(parent.height - shadowRadius * 2.5)
        radius: frameRadius
    }
	
	MouseArea {
        id: titlebar
        anchors.top: frame.top
		width: frame.width
        height: 26
		property real lastMouseX: 0
        property real lastMouseY: 0
        onPressed: {
            lastMouseX = mouseX
            lastMouseY = mouseY
        }
        onMouseXChanged: windowView.x += (mouseX - lastMouseX)
        onMouseYChanged: windowView.y += (mouseY - lastMouseY)
    }
}

