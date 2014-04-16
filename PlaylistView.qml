import QtQuick 2.1

ListView {
	id: playlist
	width: 300
	height: childrenRect.height

	property var allItems: []
	property string currentPlayingSource
	property bool isSelected: {
		for (var i = 0; i < allItems.length; i++) {
			if (allItems.isSelected) {
				return true
			}
		}
		return false
	}

	// ["Level One", "Level Two", "Level Three"]
	function findItemByPath(path) {
		for (var i = 0; i < allItems.length; i++) {
			if (allItems[i].propName == path[0]) {
				if (allItems[i].child) {
					return allItems[i].child.findItemByPath(path.slice(1))					
				} else if (path.length == 1) {
					return allItems[i]
				} else {
					return null
				}
			}
		}
		return null
	}

	// ["Level One", "Level Two", ("Level Three", "/home/hualet/Videos/movie.mov", [])]
	function _pathToListElement(path) {
		var result  = null
		for (var i = path.length - 1; i >= 0; i--) {
			var item = {}
			if (i == path.length - 1) {
				item.itemName = path[i][0]
				item.itemUrl = path[i][1]
				item.itemChild = []
				} else {
					item.itemName = path[i]
					item.itemUrl = ""
					item.itemChild = [result]
				}
			result = item
		}
		print(JSON.stringify(result))
		return result
	}

	// ["Level One", "Level Two", ("Level Three", "/home/hualet/Videos/movie.mov", [])]
	function addItem(path) {
        if (allItems.length == 0) {
            model.append(_pathToListElement(path))
        } else {
        	var item = {
        	    "itemName": path[path.length - 1][0],
        	    "itemUrl": path[path.length - 1][1],
        	    "itemChild": path[path.length -1][2]
        	}
            var parent = findItemByPath(path.slice(0, path.length))
            if (parent != null) {
                parent.child.model.append(item)
            }
        }
	}

    function getContent() {
        var result = []
        for (var i = 0; i < allItems.length; i++) {
            if (allItems[i].isGroup) {
                result.push({
                    "itemName": allItems[i].propName, 
                    "itemUrl": allItems[i].propUrl,
                    "itemChild": allItems[i].child.getContent()})
            } else {
                result.push({
                    "itemName": allItems[i].propName,
                    "itemUrl": allItems[i].propUrl,
                    "itemChild": "[]"
                    })
            }
        }
        return JSON.stringify(result)
    }

    // Note: this function is solely used for _initialization_
    function initializeWithContent(content) {
     	var eles = _fromContent(content)   
     	for (var i = 0; i < eles.length; i++) {
     		print(eles[i])
     		model.append(eles[i])
     	}
    }

    function _fromContent(content) {
    	var result = []

    	var list = JSON.parse(content)
    	for (var i = 0; i < list.length; i++) {
    		result.push({
    			"itemName": list[i].itemName,
    			"itemUrl": list[i].itemUrl,
    			"itemChild": _fromContent(list[i].itemChild)
    			})
    	}

    	return result
    }

    function clear() {
        model.clear()
    }

	model: ListModel {}
	delegate: Component {
		Column {
			id: column
			width: ListView.view.width

			property var propName: itemName
			property var propUrl: itemUrl
			property var propChild: itemChild
			property var child: sub.item

		    property bool isGroup: itemChild.count > 0
			property bool isSelected: isGroup ? sub.item.isSelected : (playlist.currentPlayingSource == itemUrl)

			Component.onCompleted: playlist.allItems.push(column)
			Component.onDestruction: {
				var idx = column.ListView.view.allItems.indexOf(column)
				if (idx != -1) {
					column.ListView.view.allItems.splice(idx, 1)
				}
			}

			Item {
				width: column.width
				height: 20

				MouseArea {
					id: mouse_area
					hoverEnabled: true
					anchors.fill: parent
					onEntered: {
					    delete_button.visible = true
					    delete_button.source = "image/delete_hover.png"
					}
					onExited: {
					    delete_button.visible = false
					    delete_button.source = "image/delete_normal.png"
					}
					onClicked: {
						if (column.isGroup) {
							sub.visible = !sub.visible							
						} else {
							column.isSelected = !column.isSelected
						}
					}
				}

				Image {
					id: expand_button
					opacity: isGroup ? 1 : 0
					source: isSelected ? "image/expanded.png" : "image/not_expanded.png"

					anchors.verticalCenter: parent.verticalCenter
				}
				Text {
					id: name
					width: parent.width - expand_button.width - anchors.leftMargin - delete_button.width
					text: itemName
					elide: Text.ElideRight
					color: column.isGroup ? "#8800BDFF" : column.isSelected ? "#00BDFF" : mouse_area.containsMouse ? "white" : "#B4B4B4"
					font.pixelSize: column.isGroup ? 12 : column.isSelected ? 13 : 11

					anchors.left: expand_button.right
					anchors.leftMargin: 10
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
							column.ListView.view.model.remove(index, 1)
						}

						onPressed: delete_button.source = "image/delete_pressed.png"
						onReleased: delete_button.source = "image/delete_hover.png"
					}
				}
			}

			Loader {
				id: sub
				x: 15
				visible: false
				active: column.isGroup
				source: "PlaylistView.qml"
				asynchronous: true
				onLoaded: {
					item.model = itemChild
					item.width = column.width - sub.x
					item.currentPlayingSource = column.ListView.view.currentPlayingSource
				}
			}
		}
	}
}