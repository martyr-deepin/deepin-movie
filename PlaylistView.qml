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

            property int itemIndex: index
            property alias child: column.child
            property string title: itemName

            Behavior on height {
                SmoothedAnimation {duration: 100}
            }

            Component.onCompleted: {
                ListView.view.parent.childrenItems.push(item)
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
                                column.child.destroy();
                                column.parent.decreaseH(column.child.actualHeight);
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

    // getContent returns the string representation of this playlist hierarchy
    // getObject returns the object representation of this playlist hierarchy
    function getContent() {
        var result = [];
        for (var i = 0; i < listview.count; i++) {
            result.push(listview.model.get(i));
        }
        return JSON.stringify(result);
    }

    function getObject() {
        return contentToObject(getContent());
    }

    function contentToObject(content) {
        var result = [];

        if (!content || content == "") return result;
        var items = JSON.parse(content);
        for (var i = 0; i < items.length; i++) {
            items[i].itemChild = contentToObject(items[i].itemChild)
            result.push(items[i]);
        }

        return result;
    }

    function objectToContent(obj) {
        if (!obj) return "[]";

        var result = [];

        for (var i = 0; i < obj.length; i++) {
            var item = {};
            item.itemName = obj[i].itemName;
            item.itemChild = objectToContent(obj[i].itemChild);
            result.push(item);
        }

        return JSON.stringify(result);
    }

    // Just this level
    function getItemByName(name) {
        for (var i = 0; i < childrenItems.length; i++) {
            if (childrenItems[i].title == name) {
                return childrenItems[i]
            }
        }

        /* for (var i = 0; i < childrenItems.length; i++) { */
        /*     var child = childrenItems[i].child; */
        /*     if (child) { */
        /*         var item = child.getItemByName(name); */
        /*         if (item != null) { */
        /*             return item; */
        /*         } */
        /*     } */
        /* } */

        return null
    }

    /* Database operations */
    // path is something like ["level one", "level two", "level three"]
    function _insert(path) {
        var lastMatchItem = root;
        for (var i = 0; i < path.length; i++) {
            var item = lastMatchItem.getItemByName(path[i]);
            if (item != null) {
                if (item.child) {
                    lastMatchItem = item.child;
                } else {
                    return lastMatchItem.insertToContent(path[i],
                                                         path.slice(Math.min(i + 1, path.length - 1),
                                                                    path.length))
                }
            } else {
                return lastMatchItem.insertToListModel(path.slice(i, path.length));
            }
        }
    }

    function _delete(path) {
        var lastMatchItem = root;
        for (var i = 0; i < path.length - 1; i++) {
            var item = lastMatchItem.getItemByName(path[i]);
            print(item)
            if (item != null) {
                if (item.child) {
                    lastMatchItem = item.child;
                } else {
                    return lastMatchItem.deleteFromContent(path[i],
                                                           path.slice(i + 1, path.length))
                }
            } else {
                return;
            }
        }

        if(lastMatchItem && lastMatchItem.getItemByName(path[path.length - 1])) {
            lastMatchItem.deleteFromListModel(path[path.length - 1]);
        }
    }

    function _save() {
        if (type == "local") {
            database.playlist_local = getContent()
        }
    }

    function _fetch() {
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

    function insertToListModel(path) {
        listview.model.append(pathToListElement(path));
    }

    function insertToContent(parentNode, path) {
        var obj = getObject();
        for (var i = 0; i < obj.length; i++) {
            if (obj[i].itemName == parentNode) {
                var parent = obj[i];

                for (var i = 0; i < path.length; i++) {
                    var child = parent.itemChild;
                    var flag = false;
                    for (var j = 0; j < child.length; j++) {
                        var c = child[i];
                        if (c && c.itemName == path[i]) {
                            flag = true;
                            parent = c;
                            break;
                        }
                    }
                    if (!flag) {
                        parent.itemChild.push(pathToListElement(path.slice(i, path.length)));
                    }
                }
                break;
            }
        }
        content = objectToContent(obj);
    }

    function deleteFromListModel(name) {
        for (var i = 0; i < listview.count; i++) {
            if (listview.model.get(i).itemName == name) {
                listview.model.remove(i, 1);
            }
        }
    }

    function deleteFromContent(parentNode, path) {
        var obj = getObject();
        for (var i = 0; i < obj.length; i++) {
            if (obj[i].itemName == parentNode) {
                var parent = obj[i];

                for (var i = 0; i < path.length - 1; i++) {
                    var child = parent.itemChild;
                    var flag = false;
                    for (var j = 0; j < child.length; j++) {
                        var c = child[i];
                        if (c && c.itemName == path[i]) {
                            flag = true;
                            parent = c;
                            break;
                        }
                    }
                    if (!flag) {
                        break;
                    }
                }
                var child = parent.itemChild;
                for (var j = 0; j < child.length; j++) {
                    var c = child[i];
                    if (c && c.itemName == path[i]) {
                        parent.itemChild.splice(i, 1);
                    }
                }
                break;
            }
        }
        content = objectToContent(obj);
    }

    function deleteOne(name) {
        for (var i = 0; i < listview.count; i++) {
            if (listview.model.get(i).itemName == name) {
                listview.model.remove(i, 1);
            }
        }
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
        _insert(["Three", "Two", "Four"]);
        _delete(["Three", "Two", "One"]);
         /* print(objectToContent(contentToObject(content))) */
     }
}