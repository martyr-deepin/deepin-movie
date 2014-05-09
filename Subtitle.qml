import QtQuick 2.1

Item {
	width: 1000
	height: txt.implicitHeight

	property alias text: txt.text
	property alias fontColor: txt.color
	property alias fontSize: txt.font.pixelSize

	Text {
		id: txt
		width: parent.width
		color: "white"
		horizontalAlignment: Text.AlignHCenter
		wrapMode: Text.WordWrap
		maximumLineCount: 10
		font.pixelSize: 20
	}
}