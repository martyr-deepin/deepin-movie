import QtQuick 2.1
import QtQuick.Window 2.1
import Deepin.Widgets 1.0

DComboBox {
    id: root

    DConstants { id: dconstants }
    delegate: Component {
        Item {
            height: 26

            Rectangle {
                id: color_block
                width: 24
                height: 10
                color: root.value["color"]
                anchors.left: parent.left
                anchors.leftMargin: 6
                anchors.verticalCenter: parent.verticalCenter
            }
            DssH2 {
                id: label
                text: root.value["label"]
                color: dconstants.fgColor

                anchors.left: color_block.right
                anchors.leftMargin: 6
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
    itemDelegate: Component {
        Rectangle {
            width: 100
            height: 26
            color: itemOnHover ? "#141414" : "#191919"

            property bool itemOnHover: false
            property int index: -1
            property var value: ""

            Image {
                id: check_mark
                source: itemOnHover ? "image/select-dark-hover.png" : "image/select-dark.png"
                visible: index == 0

                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.verticalCenter: parent.verticalCenter
            }

            Rectangle {
                id: color_block
                width: 24
                height: 10
                color: parent.value["color"]
                anchors.left: check_mark.right
                anchors.leftMargin: 6
                anchors.verticalCenter: parent.verticalCenter
            }
            DssH2 {
                id: label
                text: parent.value["label"]
                color: itemOnHover ? dconstants.activeColor : dconstants.fgColor

                anchors.left: color_block.right
                anchors.leftMargin: 6
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}