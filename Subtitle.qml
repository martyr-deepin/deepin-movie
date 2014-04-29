import QtQuick 2.1

Item {
	width: 1000
	height: txt.implicitHeight

	property alias text: txt.text
	property alias textColor: txt.color
	property alias fontSize: txt.font.pixelSize

	Text {
		id: txt
		width: parent.width
		horizontalAlignment: Text.AlignHCenter
		wrapMode: Text.WordWrap
		maximumLineCount: 10
	}
}