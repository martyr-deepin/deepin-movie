import QtQuick 2.1

ListView {
    id: playlist
    width: 300
    height: childrenRect.height
    layer.enabled: true
    cacheBuffer: Math.max(0, contentHeight) // retains all the items, protect them from being destroied and rebuilt.
    boundsBehavior: Flickable.StopAtBounds

    property var allItems: []
    property string currentPlayingSource
    property var root
    // isSelected is determined by its children
    property bool isSelected: false
    property url clickedOnItemUrl
    property string clickedOnItemName

    signal newSourceSelected(string path)
    signal removeItemPrivate(string url)
    signal removeGroupPrivate(string name)
    signal rightClickedOnItem(string url)
    signal fileMissing(string url)
    signal fileBack(string url)

    signal cleared()
    signal itemRemoved(string url)
    signal categoryRemoved(string name)

    Connections {
        target: _file_monitor
        onFileMissing: playlist.fileMissing("file://"+file)
        onFileBack: playlist.fileBack("file://"+file)
    }

    function getFirst() {
        var flatList = _flattenList()
        return flatList.length == 0 ? null : flatList[0]
    }

    function getRandom() {
        var flatList = _flattenList()
        var rand = Math.floor(Math.random() * flatList.length)
        return flatList.length > 0 ? flatList[rand] : null
    }

    function getPreviousSourceCycle(source) { return _getPreviousSource(source, true) }

    function getNextSourceCycle(source) { return _getNextSource(source, true) }

    function getPreviousSource(source) { return _getPreviousSource(source, false) }

    function getNextSource(source) { return _getNextSource(source, false) }

    function _getPreviousSource(source, cycle) {
        var flatList = _flattenList()
        for (var i = 0; i < flatList.length; i++) {
            if (playlist._urlEqual(flatList[i], (currentPlayingSource || source))) {
                if (cycle) {
                    var destIndex = (i + flatList.length - 1) % flatList.length
                    return flatList[destIndex]
                } else {
                    if (i - 1  < 0) {
                        return null
                    } else {
                        return flatList[i - 1]
                    }
                }
            }
        }
        return null
    }

    function _getNextSource(source, cycle) {
        var flatList = _flattenList()
        for (var i = 0; i < flatList.length; i++) {
            if (playlist._urlEqual(flatList[i], (currentPlayingSource || source))) {
                if (cycle) {
                    var destIndex = (i + 1) % flatList.length
                    return flatList[destIndex]
                } else {
                    if (i + 1 > flatList.length - 1) {
                        return null
                    } else {
                        return flatList[i + 1]
                    }
                }
            }
        }
        return null
    }

    function addItem(groupName, itemName, itemUrl) {
        if (groupName) {
            var item = {
                "itemName": itemName,
                "itemUrl": itemUrl,
                "itemChild": []
            }
            var group = {
                "itemName": groupName,
                "itemUrl": "",
                "itemChild": [item]
            }
            for (var i = 0; i < count; i++) {
                var modelItem = model.get(i)
                if (modelItem["itemName"] == groupName) {
                    modelItem["itemChild"].append(item)
                    return
                }
            }
            model.append(group)
        } else {
            var item = {
                "itemName": itemName,
                "itemUrl": itemUrl,
                "itemChild": []
            }
            model.append(item)
        }
    }

    function removeItem(url) { root.removeItemPrivate(url); itemRemoved(url) }
    function removeGroup(name) { root.removeGroupPrivate(name); categoryRemoved(name) }
    function removeInvalidItems(valid_check_func) {
        var flatList = _flattenList()
        for (var i = 0; i < flatList.length; i++) {
            if (!valid_check_func(flatList[i])) {
                removeItem(flatList[i])
            }
        }
    }

    function moveItem(from, to) {
        model.move(from, to, 1)
        allItems.splice(to, 0, allItems.splice(from, 1)[0])
        root.itemMoved(from, to)
    }

    function contains(url) {
        var list = _flattenList()
        for (var i = 0; i< list.length; i++) {
            if (playlist._urlEqual(list[i], url)) return true
        }
        return false
    }

    function isEmpty() {
        return _flattenList().length == 0
    }

    function _flattenList() {
        var result = []
        for (var i = 0; i < allItems.length; i++) {
            if (allItems[i].isGroup && allItems[i].child) {
                result = result.concat(allItems[i].child._flattenList())
            } else {
                result.push(allItems[i].propUrl)
            }
        }
        return result
    }

    // Note: this function is solely used for _initialization_
    function initializeWithContent(content) {
        var list = JSON.parse(content)
        for (var i = 0; i < list.length; i++) {
            addItem(list[i]["category"], list[i]["name"], list[i]["url"])
        }
    }

    function getContent() {
        var result = []
        for (var i = 0; i < count; i++) {
            var modelItem = model.get(i)
            if (modelItem["itemChild"].count != 0) {
                for (var j = 0; j < modelItem["itemChild"].count; j++) {
                    result.push({
                        "category": modelItem["itemName"],
                        "name": modelItem["itemChild"].get(j)["itemName"],
                        "url": modelItem["itemChild"].get(j)["itemUrl"]
                        })
                }
            } else {
                result.push({
                    "category": "",
                    "name": modelItem["itemName"],
                    "url": modelItem["itemUrl"]
                    })
            }
        }
        return JSON.stringify(result)
    }

    function clear() {
        model.clear()
        allItems = []
        cleared()
    }

    function _urlEqual(url1, url2) {
        return url1 && url2 && url1.toString().replace("file://", "") == url2.toString().replace("file://", "")
    }

    function _sortFuncY(item1, item2) {
        return item1.y > item2.y ? 1 : -1
    }

    // Rectangle {
    //  id: sep
    //  visible: false
    //  width: 1
    //  height: parent.width
    //  rotation: -90
    //  transformOrigin: Item.TopLeft
    //  gradient: Gradient {
    //      GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.0)}
    //      GradientStop { position: 0.3; color: Qt.rgba(1, 1, 1, 1.0)}
    //      GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, 1.0)}
    //      GradientStop { position: 0.7; color: Qt.rgba(1, 1, 1, 1.0)}
    //      GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.0)}
    //  }
    // }

    model: ListModel{}
    delegate: Component {
        Column {
            id: column
            visible: isGroup ? propChild ? propChild.count > 0 : false : true
            width: ListView.view.width

            property var propName: itemName
            property var propUrl: itemUrl
            property var propChild: itemChild
            property var child: sub.item

            property bool isGroup: propUrl == ""
            property bool isSelected: isGroup ? child.isSelected : playlist._urlEqual(playlist.currentPlayingSource, itemUrl)
            property bool isHover: mouse_area.containsMouse
            onIsSelectedChanged: column.ListView.view.isSelected = isSelected

            property int lastY: y
            onYChanged: {
                if (mouse_area.drag.active) {
                    var listView = column.ListView.view
                    for (var i = 0; i < listView.allItems.length; i++) {
                        if (y > lastY) {
                            if (listView.allItems[i].y < y + height
                                && y + height < listView.allItems[i].y + listView.allItems[i].height)
                            {
                                // sep.parent = parent
                                // sep.x = parent.x
                                // sep.y = listView.allItems[i].y + listView.allItems[i].height
                                // sep.visible = true

                                if (listView.allItems[i].isGroup) {
                                    if (listView.allItems[i].y > y) {
                                        listView.allItems[i].y -= height
                                    }
                                } else {
                                    listView.allItems[i].y -= height
                                }
                            }
                        } else if (y < lastY) {
                            if (listView.allItems[i].y < y
                                && y < listView.allItems[i].y + listView.allItems[i].height)
                            {
                                // sep.parent = parent
                                // sep.x = parent.x
                                // sep.y = listView.allItems[i].y + listView.allItems[i].height
                                // sep.visible = true

                                if (listView.allItems[i].isGroup) {
                                    if (listView.allItems[i].y + listView.allItems[i].height < y + height) {
                                        listView.allItems[i].y += height
                                    }
                                } else {
                                    listView.allItems[i].y += height
                                }
                            }
                        }
                    }
                }

                lastY = y
            }

            Component.onCompleted: ListView.view.allItems.push(column)
            Component.onDestruction: {
                var idx = column.ListView.view.allItems.indexOf(column)
                if (idx != -1) {
                    column.ListView.view.allItems.splice(idx, 1)
                }
            }

            Connections {
                target: column.ListView.view.root
                onRemoveItemPrivate: {
                    if (playlist._urlEqual(propUrl, url)) {
                        column.ListView.view.model.remove(index, 1)
                    }
                }
                onRemoveGroupPrivate: {
                    if (propName == name) {
                        column.ListView.view.model.remove(index, 1)
                    }
                }
                onFileMissing: if (playlist._urlEqual(propUrl, url)) name.color = "#4f4f50"
                onFileBack: if (playlist._urlEqual(propUrl, url)) name.color = Qt.binding(getTextColor)
            }

            function getTextColor() {
                if (column.isSelected) {
                    return column.isGroup ? "#8853B6F5" : "#53B6F5"
                } else if (column.isHover) {
                    return "#FFFFFF"
                } else {
                    return "#9F9F9F"
                }
            }

            Item {
                width: column.width
                height: 24

                Timer {
                    id: show_tooltip_timer
                    interval: 1000
                    onTriggered: {
                        if (mouse_area.containsMouse) {
                            tooltip.showTip(itemName)
                        }
                    }
                }

                MouseArea {
                    id: mouse_area
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    anchors.fill: parent

                    drag {
                        target: column
                        axis: Drag.YAxis
                        onActiveChanged: {
                            if (drag.active) return

                            // sep.visible = false
                            var listView = column.ListView.view
                            var origInx = index
                            listView.allItems.sort(listView._sortFuncY)
                            var nowInx = listView.allItems.indexOf(column)
                            listView.moveItem(origInx, nowInx)
                        }
                    }

                    onEntered: {
                        delete_button.visible = true
                        delete_button.source = "image/delete_hover.png"
                        show_tooltip_timer.restart()
                    }
                    onExited: {
                        tooltip.hideTip()
                        delete_button.visible = false
                        delete_button.source = "image/delete_normal.png"
                    }
                    onClicked: {
                        if (mouse.button == Qt.RightButton) {
                            column.ListView.view.root.clickedOnItemUrl = propUrl
                            column.ListView.view.root.clickedOnItemName = propName
                            _menu_controller.show_playlist_menu(propUrl, column.ListView.view.root.isEmpty())
                        } else {
                            if (column.isGroup) {
                                sub.visible = !sub.visible
                            }
                        }
                    }
                    onDoubleClicked: {
                        if(!column.isGroup && !column.isSelected){
                            column.ListView.view.root.newSourceSelected(propUrl)
                        }
                    }
                }

                Image {
                    id: expand_button
                    visible: column.isGroup ? true : false
                    source: sub.visible ? "image/expanded.png" : "image/not_expanded.png"

                    anchors.verticalCenter: parent.verticalCenter
                }

                Image {
                    visible: column.isGroup ? false : column.isSelected ? true : false
                    source: "image/playing_indicator.png"
                    anchors.right: name.left
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    id: name
                    width: parent.width - expand_button.width - anchors.leftMargin - anchors.rightMargin - delete_button.width
                    text: itemName
                    elide: Text.ElideRight
                    font.pixelSize: 14
                    color: column.isGroup ? getTextColor() : _file_monitor.addFile(propUrl) ? getTextColor() : "#4f4f50"

                    anchors.left: expand_button.right
                    anchors.leftMargin: 6
                    anchors.right: delete_button.left
                    anchors.rightMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                }

                Image {
                    id: delete_button
                    visible: false
                    source: "image/delete_normal.png"

                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            if (column.isGroup) {
                                column.ListView.view.root.removeGroup(column.propName)
                            } else {
                                column.ListView.view.root.removeItem(column.propUrl)
                            }
                        }

                        onPressed: delete_button.source = "image/delete_pressed.png"
                        onReleased: delete_button.source = "image/delete_hover.png"
                    }
                }
            }

            Loader {
                id: sub
                x: 14
                visible: column.isSelected
                active: column.isGroup
                width: column.width - sub.x
                source: "PlaylistView.qml"
                asynchronous: true
                onLoaded: {
                    item.root = column.ListView.view.root
                    item.model = column.propChild
                    // item.width = Qt.binding(column.width - sub.x)
                    item.currentPlayingSource = Qt.binding(function () {return column.ListView.view.currentPlayingSource})
                }
            }
        }
    }
}