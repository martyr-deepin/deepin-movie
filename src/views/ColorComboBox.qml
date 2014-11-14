import QtQuick 2.1
import QtQuick.Window 2.1
import Deepin.Widgets 1.0

Item {
    id: combobox
    width: Math.max(minMiddleWidth, parent.width)
    height: background.height

    property bool hovered: false
    property bool pressed: false

    property alias text: currentLabel.text
    property alias color: curerntColor.color
    property alias menu: menu

    property var parentWindow
    property var items
    property int selectIndex: -1
    onSelectIndexChanged: menu.currentIndex = selectIndex

    signal clicked
    signal menuSelect(int index)

    Component.onCompleted: {
        text = selectIndex == -1 ? "" : menu.items[selectIndex].label
        color = selectIndex == -1 ? "transparent" : menu.items[selectIndex].color
        menu.currentIndex = selectIndex
    }

    ColorMenu {
        id: menu
        parentWindow: combobox.parentWindow
        items: combobox.items
        onMenuSelect: {
            combobox.menuSelect(index)
            selectIndex = index
            combobox.text = menu.items[selectIndex].label
            combobox.color = menu.items[selectIndex].color
        }
    }

    function showMenu(x, y, w) {
        menu.x = x - menu.frameEdge + 1
        menu.y = y - menu.frameEdge
        menu.width = w + menu.frameEdge * 2 -2
        menu.visible = true
    }

    onClicked: {
        var pos = mapToItem(null, 0, 0)
        var x = parentWindow.x + pos.x
        var y = parentWindow.y + pos.y + height
        var w = width
        showMenu(x, y, w)
    }

    QtObject {
        id: buttonImage
        property string status: "normal"
        property string header: "image/button_left_%1.png".arg(status)
        property string middle: "image/button_center_%1.png".arg(status)
        property string tail: "image/button_right_%1.png".arg(status)
    }

    property int minMiddleWidth: buttonHeader.width + downArrow.width + buttonTail.width

    Row {
        id: background
        height: buttonHeader.height
        width: parent.width

        Image{
            id: buttonHeader
            source: buttonImage.header
        }

        Image {
            id: buttonMiddle
            source: buttonImage.middle
            width: parent.width - buttonHeader.width - buttonTail.width
        }

        Image{
            id: buttonTail
            source: buttonImage.tail
        }
    }

    Rectangle {
        id: content
        width: buttonMiddle.width
        height: background.height
        anchors.left: parent.left
        anchors.leftMargin: buttonHeader.width
        anchors.verticalCenter: parent.verticalCenter
        color: Qt.rgba(1, 0, 0, 0)

        Rectangle {
            id: curerntColor
            width: 24
            height: 10
            anchors.left: parent.left
            anchors.leftMargin: 6
            anchors.verticalCenter: parent.verticalCenter
        }

        DssH2 {
            id: currentLabel
            anchors.left: curerntColor.right
            anchors.leftMargin: 6
            anchors.verticalCenter: parent.verticalCenter

            width: parent.width - downArrow.width
            elide: Text.ElideRight
        }

        Image {
            id: downArrow
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            source: hovered ? "image/arrow_down_hover.png" : "image/arrow_down_normal.png"
        }

    }

    MouseArea{
        anchors.fill: parent
        hoverEnabled: true

        onEntered: {
            parent.hovered = true
        }

        onExited: {
            parent.hovered = false
        }

        onPressed: {
            parent.pressed = true
            buttonImage.status = "press"
        }
        onReleased: {
            parent.pressed = false
            parent.hovered = containsMouse
            buttonImage.status = "normal"
        }

        onClicked: {
            combobox.clicked()
        }
    }

}
