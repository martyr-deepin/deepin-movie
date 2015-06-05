import QtQuick 2.2

MouseArea {
	id: root
	width: 48
	height: 48
	hoverEnabled: true

	property url normalImage: "../image/share.svg"
	property url hoverImage: "../image/share_hover.svg"
	property url pressImage: "../image/share_press.svg"

	Rectangle {
	    radius: 3
	    color: Qt.rgba(0, 0, 0, 0.3)
	    border.width: 1
	    border.color: Qt.rgba(1, 1, 1, 0.2)

	    anchors.fill: parent

	    Image {
	    	id: img
	    	source: root.normalImage
	    	sourceSize.width: 36
	    	sourceSize.height: 36
	    	anchors.centerIn: parent
	    }
	}

	onEntered: img.source = hoverImage
	onExited: img.source = normalImage
	onPressed: img.source = pressImage
	onReleased: img.source = containsMouse ? hoverImage : normalImage
}