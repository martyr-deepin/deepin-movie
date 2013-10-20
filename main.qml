import QtQuick 2.1
import QtGraphicalEffects 1.0
import ImageCanvas 1.0
import TopRoundRect 1.0
import QtWebKit 3.0

Item {
	id: window
	
	property int titlebarHeight: 45
	property int frameRadius: 3
	property int shadowRadius: 10

	property bool isMax: false
	
	function toggleMaxWindow() {
		isMax ? windowView.showNormal() : windowView.showMaximized()
		isMax ? maxButton.imageName = "image/window_max" : maxButton.imageName = "image/window_unmax"
		isMax ? shadow.visible = true : shadow.visible = false
		isMax ? frame.border.width = (shadowRadius + frameRadius) * 2 : frame.border.width = 0
		isMax ? frame.radius = frameRadius : frame.radius = 0
		/* isMax ? skinBackground.radius = frameRadius : skinBackground.radius = 0 */
		isMax ? frameBackground.radius = frameRadius : frameBackground.radius = 0
		isMax ? titlebarGradient.radius = frameRadius : titlebarGradient.radius = 0
		isMax ? frameBorder.visible = true : frameBorder.visible = false
		
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
		opacity: 1				/* frame transparent */
        color: Qt.rgba(0, 0, 0, 0)
        /* color: Qt.rgba(0, 0, 0, 1) /\* this code just for test frame *\/ */
        anchors.centerIn: parent
        radius: frameRadius
		border.width: (shadowRadius + frameRadius) * 2
		border.color: Qt.rgba(0, 0, 0, 0)
		width: window.width - border.width
		height: window.height - border.width
		
		Rectangle {
			id: frameBackground
			color: "black"
			anchors.fill: parent
			radius: frameRadius
		}
		
		/* ImageCanvas { */
		/* 	id: skinBackground */
		/* 	anchors.fill: parent */
		/* 	imageFile: "skin/4.jpg" */
		/* 	radius: frameRadius */
		/*     /\* visible: false *\/ */
		/* } */
		
    }
	
	MouseArea {
        id: titlebar
        anchors.top: frame.top
        anchors.left: frame.left
        anchors.right: frame.right
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
		
		Rectangle {
			id: titlebarBackground
			anchors.fill: parent
			color: Qt.rgba(0, 0, 0, 0)
			
			TopRoundRect {
				id: titlebarGradient
				anchors.fill: parent
				radius: frameRadius
				radialRadius: parent.width * 2
				vOffset: -parent.width
				startColor: "#0F4196"
				endColor: "#060709"
			}
			
			Image {
				id: appIcon
				source: "image/logo.png"
				anchors.left: parent.left
				anchors.verticalCenter: parent.verticalCenter
				anchors.leftMargin: 20
			}
			
			Row {
				height: parent.height
				anchors.left: appIcon.right
				anchors.leftMargin: 60
				id: tabButtonArea
				spacing: 40
				
				TabButton {
					id: tabMoive
					text: "深度影院"
				}

				TabButton {
					id: tabPlay
					text: "视频播放"
				}

				TabButton {
					id: tabSearch
					text: "电影搜索"
				}

				TabButton {
					id: tabFavorite
					text: "我的收藏"
				}
			}
			
			Row {
				anchors {right: parent.right}
				id: windowButtonArea
				
				/* ImageButton { */
				/* 	id: themeButton */
				/* 	imageName: "image/window_theme" */
				/* } */

				/* ImageButton { */
				/* 	id: menuButton */
				/* 	imageName: "image/window_menu" */
				/* } */

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

	WebView {
		id: webview
		url: "http://pianku.xmp.kankan.com/moviestore_index.html"
		anchors.top: titlebar.bottom
		anchors.bottom: frame.bottom
		anchors.left: titlebar.left
		anchors.right: titlebar.right
	}
	
	Rectangle {
		id: frameBorder
		anchors.fill: frame
		color: Qt.rgba(0, 0, 0, 0)
		border.color: Qt.rgba(200, 200, 200, 0.5)
		border.width: 1
		smooth: true
		radius: frameRadius
	}
}

