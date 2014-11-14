import QtQuick 2.1

Item {
	width: 380
	height: settings_title.height + top_space.height + col.height + bottom_space.height

	default property alias content: col.children
	property alias topSpaceHeight: top_space.height
	property alias bottomSpaceHeight: bottom_space.height

	property string sectionId
	property alias title: settings_title.title
	property alias showSep: settings_title.showSep

	MouseArea {
		anchors.fill: parent
		onClicked: parent.focus = true
	}

	SettingsTitle { id: settings_title }

	Item { id: top_space; width: parent.width; height: 0; anchors.top: settings_title.bottom }

	Column {
		id: col
		height: childrenRect.height
		spacing: 10
		anchors.top: top_space.bottom
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.leftMargin: 5
		anchors.rightMargin: 5
	}

	Item { id: bottom_space; width: parent.width; height: 0; anchors.top: col.bottom }
}
