import QtQuick 2.1
import Deepin.Widgets 1.0
import Com.Deepin.DeepinMovie 1.0

DDialog {
    id: dialog
    width: 362 + shadowWidth * 2
    height: col.childrenRect.height + 38 + shadowWidth * 2

    signal confirmed(var renderer)

    function clearRenderers() {
        list_view.model.clear()
    }

    function addRenderer(renderer) {
        for (var i = 0; i < list_view.count; i++) {
            if (list_view.model.get(i).renderer.path == renderer.path) {
                return
            }
        }

        list_view.model.append({ "renderer": renderer })
    }

    function rmRenderer(path) {
        for (var i = 0; i < list_view.count; i++) {
            if (list_view.model.get(i).renderer.path == path) {
                list_view.model.remove(i, 1)
            }
        }
    }

    Column {
        id: col
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 2
        anchors.rightMargin: 2

        Text {
            id: msg
            text: dsTr("Please select the playing device") + dsTr(":")
            color: "white"
            font.pixelSize: 12

            anchors.left: parent.left
            anchors.leftMargin: 14
        }

        Item {
            width: parent.width
            height: 10
        }

        ListView {
            id: list_view
            width: parent.width
            height: Math.min(childrenRect.height, itemHeight * 5 + spacing * 4)
            spacing: 4
            clip: true

            property int itemHeight: 40

            delegate: Rectangle {
                // TODO: rename this color name to proper one
                color: DPalette.radioItemSelectedColor
                width: ListView.view.width
                height: ListView.view.itemHeight

                Image {
                    id: icon
                    width: 32
                    height: 32
                    visible: status == Image.Ready
                    source: renderer.icon

                    anchors.left: parent.left
                    anchors.leftMargin: 36
                    anchors.verticalCenter: parent.verticalCenter
                }

                Image {
                    visible: !icon.visible
                    anchors.fill: icon

                    source: mouse_area.pressed ? "../image/renderer_default_press.svg"
                                               : mouse_area.containsMouse ? "../image/renderer_default_hover.svg"
                                                                          : "../image/renderer_default_normal.svg"
                }

                Text {
                    color: mouse_area.pressed ? DPalette.textActiveColor
                                              : mouse_area.containsMouse ? DPalette.textHoverColor
                                                                         : DPalette.textNormalColor
                    text: renderer.name

                    anchors.left: icon.right
                    anchors.leftMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                }

                MouseArea {
                    id: mouse_area
                    hoverEnabled: true
                    anchors.fill: parent

                    onClicked: {
                        dialog.confirmed(renderer)
                        dialog.close()
                    }
                }
            }
            model: ListModel {}
        }
    }
}