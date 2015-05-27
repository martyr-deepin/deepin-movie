import QtQuick 2.2
import Deepin.Widgets 1.0

Item {
	id: root
	width: content.width + rect.blurWidth * 2
	height: content.height + rect.blurWidth * 2

	signal screenshotButtonClicked ()
	signal burstModeButtonClicked ()

	DRectWithCorner {
		id: rect
		rectWidth: parent.width
		rectHeight: parent.height
		borderWidth: 0
		borderColor: "transparent"
		fillColor: "#1A1B1B"
	}

	Item {
		id: content
		width: 198
		height: 140
		anchors.top: parent.top
		anchors.left: parent.left
		anchors.topMargin: rect.blurWidth
		anchors.leftMargin: rect.blurWidth

		Grid {
			width: parent.width - 6 * 2
			height: parent.height - 4 * 2
			rows: 2
			columns: 3
			columnSpacing: 3
			anchors.centerIn: parent

			ToolboxButton {
				text: "Screenshot"
				normalImage: "../image/toolbox_screenshot_normal.svg"
				hoverImage: "../image/toolbox_screenshot_hover_press.svg"
				pressedImage: "../image/toolbox_screenshot_hover_press.svg"

				onClicked: { root.visible = false; root.screenshotButtonClicked() }
			}

			ToolboxButton {
				text: "Burst"
				normalImage: "../image/toolbox_serial_screenshots_normal.svg"
				hoverImage: "../image/toolbox_serial_screenshots_hover_press.svg"
				pressedImage: "../image/toolbox_serial_screenshots_hover_press.svg"

				onClicked: { root.visible = false; root.burstModeButtonClicked() }
			}
		}
	}
}