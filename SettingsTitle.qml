import QtQuick 2.1
import Deepin.Widgets 1.0

Row {
	clip: true
	height: txt.implicitHeight

	property alias title: txt.text
	property alias showSep: sep.visible

	DssH1 { 
		id: txt
		text: "hello"
	}

	DSeparatorHorizontal { 
		id: sep
		width: 1000 
		anchors.verticalCenter: parent.verticalCenter
	}
}