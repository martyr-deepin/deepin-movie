import QtQuick 2.1

Item {
	width: 380
	height: childrenRect.height

	default property alias content: col.children
	property alias topSpaceHeight: topSpace.height
	property alias bottomSpaceHeight: bottomSpace.height

	property string sectionId
	property alias title: settings_title.title
	property alias showSep: settings_title.showSep

	MouseArea {
		anchors.fill: parent
		onClicked: parent.focus = true
	}

	Item { id: topSpace; width: parent.width; height: 0 }

	SettingsTitle { id: settings_title; anchors.top: topSpace.bottom }

	Item { id: bottomSpace; width: parent.width; height: 0; anchors.top: settings_title.bottom }

	Column {
		id: col
		height: childrenRect.height
		spacing: 10
		anchors.top: bottomSpace.bottom
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.leftMargin: 5
		anchors.rightMargin: 5
	}
}
