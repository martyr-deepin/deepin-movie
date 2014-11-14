import QtQuick 2.1
import Deepin.Widgets 1.0

Row {
	clip: true
	height: txt.implicitHeight
	spacing: 2

	property alias title: txt.text
	property alias showSep: sep.visible

	DssH2 { 
		id: txt
		text: "hello"
	}

	DSeparatorHorizontal { 
		id: sep
		width: 1000 
		anchors.verticalCenter: parent.verticalCenter
	}
}