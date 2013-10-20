import QtQuick 2.1

Rectangle {
      width: 400
      height: 400
	  color: Qt.rgba(0, 200, 0, 0.5)
      radius: 3
	  smooth: true
	  
	  Text {
		  text: "hello world"
		  anchors.horizontalCenter: parent.horizontalCenter
		  anchors.verticalCenter: parent.verticalCenter
		  color: "white"
	  }
}
