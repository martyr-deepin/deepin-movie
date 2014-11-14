import QtQuick 2.1
import QtQuick.Window 2.1
import Deepin.Widgets 1.0

DPopupWindow {
    id: menuPopupWindow
    property int frameEdge: menuFrame.shadowRadius + menuFrame.frameRadius
    property int minWidth: 30
    property real posX: 0
    property real posY: 0

    x: posX - 28
    y: posY - 12

    width: minWidth + 24
    height: completeViewBox.height + 32

    property int maxHeight: -1

    property alias currentIndex: completeView.currentIndex
    property var items
    visible: false

    signal menuSelect(int index)

    DWindowFrame {
        id: menuFrame
        layer.enabled: true
        anchors.fill: parent

        Item {
            id: completeViewBox
            anchors.centerIn: parent
            width: parent.width - 6
            height: childrenRect.height

            ListView {
                id: completeView
                width: parent.width
                height: maxHeight != -1 ? Math.min(childrenHeight, maxHeight) : childrenHeight
                property int childrenHeight: childrenRect.height
                maximumFlickVelocity: 1000
                model: items
                delegate: ColorMenuItem {
                    text: items[index].label
                    color: items[index].color
                    onSelectAction:{
                        menuPopupWindow.visible = false
                        menuPopupWindow.menuSelect(index)
                    }
                }
                clip: true
            }
        }

    }

}
