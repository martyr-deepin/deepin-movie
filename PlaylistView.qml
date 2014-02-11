import QtQuick 2.1

Item {
    id: root
    width: 300
    height: 500

    property int actualWidth: listview.contentWidth
    property int actualHeight: listview.contentHeight

    property string content: JSON.stringify([{"itemName": "One",
                                              "itemChild": ""},
                                             {"itemName": "Three",
                                              "itemChild": JSON.stringify([{"itemName": "Two",
                                                                            "itemChild": JSON.stringify([{"itemName": "One",
                                                                                                          "itemChild": ""},
                                                                                                         {"itemName": "One",
                                                                                                          "itemChild": ""}])}])},
                                             {"itemName": "Two",
                                              "itemChild": JSON.stringify([{"itemName": "One",
                                                                            "itemChild": ""}])}])

    Component {
        id: listview_delegate

        Item {
            width: label.width
            height: label.height

            Behavior on height {
                SmoothedAnimation {duration: 100}
            }

            function increaseH(h) {
                height += h
                if (ListView.view &&
                    ListView.view.parent.parent &&
                    ListView.view.parent.parent.parent &&
                    ListView.view.parent.parent.parent.increaseH) {
                    ListView.view.parent.parent.parent.increaseH(h)
                }
            }

            function decreaseH(h) {
                height -= h
                if (ListView.view &&
                    ListView.view.parent.parent &&
                    ListView.view.parent.parent.parent &&
                    ListView.view.parent.parent.parent.decreaseH) {
                    ListView.view.parent.parent.parent.decreaseH(h)
                }
            }

            Column {
                id: column

                property var child

                Text {
                    id: label
                    
                    text: itemName
                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            if (column.child) {
                                column.child.destroy()
                                column.parent.decreaseH(column.child.actualHeight)
                            } else {
                                if (itemChild && itemChild != "") {
                                    column.child = Qt.createQmlObject('import QtQuick 2.1; PlaylistView{}',
                                                                      column, "child");
                                    column.child.content = itemChild
                                    column.child.anchors.left = column.left
                                    column.child.anchors.leftMargin = 10
                                    column.parent.increaseH(column.child.actualHeight)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    ListView {
        id: listview

        model: root.getModelFromString(root.content, listview)
        delegate: listview_delegate

        anchors.fill: parent
    }
    
    function getModelFromString(str, prt) {
        var model = Qt.createQmlObject('import QtQuick 2.1; ListModel{}',
                                       prt, "model");
        if (str != "") {
            var obj = JSON.parse(str);

            for (var i = 0; i < obj.length; i++) {
                model.append({"itemName": obj[i].itemName, "itemChild": obj[i].itemChild})
            }
        }

        return model
    }
}