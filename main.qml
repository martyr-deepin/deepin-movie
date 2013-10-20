import QtQuick 2.1
import QtGraphicalEffects 1.0

Item {
	id: window
	
	property int titlebarHeight: 26
	property int frameRadius: 3
	property int shadowRadius: 10

	property bool isMax: false
	
	function toggleMaxWindow() {
		isMax ? windowView.showNormal() : windowView.showMaximized()
		isMax ? maxButton.imageName = "image/window_max" : maxButton.imageName = "image/window_unmax"
		isMax ? shadow.visible = true : shadow.visible = false
		isMax ? frame.border.width = (shadowRadius + frameRadius) * 2 : frame.border.width = 0
		isMax ? frame.radius = frameRadius : frame.radius = 0
		
		isMax = !isMax
	}

    RectangularGlow {
        id: shadow
        anchors.fill: frame
        glowRadius: shadowRadius
        spread: 0.2
        /* color: Qt.rgba(0, 0, 0, 0.3) */
        color: Qt.rgba(200, 0, 0, 0.8) /* this code just for test shadow */
        cornerRadius: frame.radius + shadowRadius
		visible: true
    }
	
    Rectangle {
        id: frame
		opacity: 1				/* frame transparent */
        color: Qt.rgba(0, 0, 0, 0)
        /* color: Qt.rgba(0, 0, 0, 1) /\* this code just for test frame *\/ */
        anchors.centerIn: parent
        radius: frameRadius
		border.width: (shadowRadius + frameRadius) * 2
		border.color: Qt.rgba(0, 0, 0, 0)
		width: window.width - border.width
		height: window.height - border.width
		
		Canvas {
			/* visible: false */
			id: canvas
			anchors.fill: parent
			antialiasing: true
			property int radius: 3
			property int rectx: 0
			property int recty: 0
			property int rectWidth: parent.width
			property int rectHeight: parent.height
			property int lineWidth: 1
			property string imagefile: "skin/4.jpg"
			
			Component.onCompleted: loadImage(canvas.imagefile)
			onImageLoaded: requestPaint()	
			onWidthChanged: requestPaint()
			onHeightChanged: requestPaint()
			onRectxChanged: requestPaint()
			onRectyChanged: requestPaint()
			onRectWidthChanged: requestPaint()
			onRectHeightChanged: requestPaint()
			onRadiusChanged: requestPaint()
			onLineWidthChanged: requestPaint()

			onPaint: {
				var ctx = getContext("2d");
				ctx.save();
				ctx.clearRect(0, 0, canvas.width, canvas.height);
				ctx.lineWidth = canvas.lineWidth
				ctx.globalAlpha = 1
				ctx.roundedRect(rectx, recty, rectWidth, rectHeight, radius, radius)
				ctx.clip()
				ctx.drawImage(canvas.imagefile, rectx, recty)
				
				ctx.restore();
			}
		}		
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
				id: menuButton
				imageName: "image/window_menu"
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

