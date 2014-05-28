import QtQuick 2.1

Item {
	width: 300
	height: childrenRect.height

	default property alias content: col.children

	property string sectionId
	property alias title: settings_title.title
	property alias showSep: settings_title.showSep

	MouseArea {
		anchors.fill: parent
		onClicked: parent.focus = true
	}

	SettingsTitle { id: settings_title }

	Column {
		id: col
		width: parent.width
		height: childrenRect.height
		anchors.top: settings_title.bottom
	}
}
