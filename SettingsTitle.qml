import QtQuick 2.1
import Deepin.Widgets 1.0

Row {
	clip: true
	height: txt.implicitHeight

	property alias title: txt.text

	DssH1 { 
		id: txt
		text: "hello"
	}

	DSeparatorHorizontal { 
		width: 500 
		anchors.verticalCenter: parent.verticalCenter
	}
}