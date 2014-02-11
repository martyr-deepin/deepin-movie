import QtQuick 2.1

Item {
    id: root
    width: 300
    height: 500

    property string type: "local" // local or network
    property int actualWidth: listview.contentWidth
    property int actualHeight: listview.contentHeight

    property var childrenItems: []

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
            id: item

            width: 200
            height: label.height

            property string title: itemName

            Behavior on height {
                SmoothedAnimation {duration: 100}
            }

            Component.onCompleted: {
                ListView.view.parent.childrenItems.push(item)
            }

            function getChildPlaylist() {
                return column.child
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

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 15
                anchors.rightMargin: 15

                Text {
                    id: label

                    text: itemName
                    color: "white"
                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            if (column.child) {
                                column.child.destroy()
                                column.parent.decreaseH(column.child.actualHeight)
                            } else {
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

    ListView {
        id: listview

        model: root.getModelFromString(root.content, listview)
        delegate: listview_delegate

        anchors.fill: parent
    }

    function getContent() {
        return content
    }

    function getItemByName(name) {
        for (var i = 0; i < childrenItems.length; i++) {
            print(childrenItems[i].title)
            if (childrenItems[i].title == name) {
                return childrenItems[i]
            }
        }

        for (var i = 0; i < childrenItems.length; i++) {
            var child = childrenItems[i].getChildPlaylist();
            if (child) {
                var item = child.getItemByName(name);
                if (item != null) {
                    return item;
                }
            }
        }

        return null
    }

    /* Database operations */
    // path is something like ["level one", "level two", "level three"]
    function insert(path) {
        var lastMatchItem = root;
        for (var i = 0; i < path.length; i++) {
            var item = getItemByName(path[i]);
            if (item != null) {
                lastMatchItem = item.getChildPlaylist();
            } else {
                return lastMatchItem.insertOne(path.slice(i, path.length));
            }
        }
    }

    function save() {
        if (type == "local") {
            database.playlist_local = getContent()
        }
    }

    function fetch() {
        return type == "local" ? database.playlist_local : database.playlist_network
    }
    /* Database operations end */

    // see `insert' above for more infomation about path
    function pathToListElement(path) {
        var result;
        
        for (var i = path.length - 1; i >= 0; i--) {
            var ele = {};
            ele.itemName = path[i];
            ele.itemChild = result ? JSON.stringify([result]) : "";
            result = ele;
        }

        return result;
    }
    
    function insertOne(path) {
        listview.model.append(pathToListElement(path));
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

    Component.onCompleted: {
        /* save() */
        /* print(fetch()) */
        /* getItemByName("One") */
        /* print(JSON.stringify(pathToListElement(["one", "two", "three"]))) */
        insert(["Four", "Five"])
    }
}