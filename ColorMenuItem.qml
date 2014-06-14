import QtQuick 2.1
import Deepin.Widgets 1.0

Item {
    id: wrapper
    width: wrapper.ListView.view.width; height: 26

    signal selectAction(int index)

    property alias text: label.text
    property alias color: color_block.color

    Rectangle {
        color: wrapper.ListView.view.currentIndex == index ? "#141414" : "#232323"
        anchors.fill: parent
        anchors.leftMargin: 2

        Rectangle {
            id: color_block
            width: 24
            height: 10
            anchors.left: parent.left
            anchors.leftMargin: 6
            anchors.verticalCenter: parent.verticalCenter
        }
        DssH2 {
            id: label
            anchors.left: color_block.right
            anchors.leftMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            color: wrapper.ListView.view.currentIndex == index ? dconstants.activeColor : dconstants.fgColor
        }

    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onEntered:{
            wrapper.ListView.view.currentIndex = index
        }
        onExited: {
            wrapper.ListView.view.currentIndex = -1
        }
        onClicked: selectAction(index)
    }
}
