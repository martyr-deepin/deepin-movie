import QtQuick 2.1

ListView {
	id: playlist
	width: 300
	height: childrenRect.height
	layer.enabled: true

	property var allItems: []
	property string currentPlayingSource
	property var root
	// isSelected is determined by its children
	property bool isSelected: false
	property url clickedOnItemUrl

	signal newSourceSelected(string path)
	signal removeItemPrivate(string url)
	signal rightClickedOnItem(string url)

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
	   		if (flatList[i] == (currentPlayingSource || source)) {
	   			var destIndex = cycle ? (i + flatList.length - 1) % flatList.length : Math.max(i-1, 0)
	   			return flatList[destIndex]
	   		}
	   	}
	   	return null
	}    

	function _getNextSource(source, cycle) {
	   	var flatList = _flattenList()
	   	for (var i = 0; i < flatList.length; i++) {
	   		if (flatList[i] == (currentPlayingSource || source)) {
	   			var destIndex = cycle ? (i + 1) % flatList.length : Math.min(i+1, flatList.length - 1)
	   			return flatList[destIndex]
	   		}
	   	}
	   	return null
	}

	// ["Level One", "Level Two"]
	function findItemByPath(path) {
		for (var i = 0; i < allItems.length; i++) {
			if (allItems[i].propName == path[0]) {
				if (path.length == 1) {
					return allItems[i]
				} else if (allItems[i].child) {
					return allItems[i].child.findItemByPath(path.slice(1))
				} else {
					return null
				}
			}
		}
		return null
	}

	// ["Level One", ["Level Two", "/home/hualet/Videos/movie.mov", []]]
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
					item.itemChild = []
					item.itemChild.push(result)
				}
			result = item
		}
		return result
	}

	// ["Level One", ["Level Two",  "file:///home/hualet/Videos/movie.mov"]
	// NOTE: we only support two level playlist by now
	function addItem(path) {
		var parent = findItemByPath(path.slice(0, 1))
        if (parent == null) {
        	// check for redundant insertion
        	for (var i = 0; i < count; i++) {
        		if (model.get(i).itemUrl == path[path.length - 1][1]) return
        	}

            model.append(_pathToListElement(path))
        } else {
        	var item = {
        	    "itemName": path[path.length - 1][0],
        	    "itemUrl": path[path.length - 1][1],
        	    "itemChild": path[path.length -1][2]
        	}

        	// check for redundant insertion
        	for (var i = 0; i < parent.propChild.count; i++) {
        		if (parent.propChild.get(i).itemUrl == item.itemUrl) return
        	}

        	parent.propChild.append(item)
        }
        forceLayout()
	}

	function removeItem(url) { root.removeItemPrivate(url) }
	function removeInvalidItems(valid_check_func) {
	    var flatList = _flattenList()
	    for (var i = 0; i < flatList.length; i++) {
	    	if (!valid_check_func(flatList[i])) {
	    		removeItem(flatList[i])
	    	}
	    }
	}

	function _flattenList() {
		var result = []
		for (var i = 0; i < allItems.length; i++) {
		    if (allItems[i].isGroup) {
		        result = result.concat(allItems[i].child._flattenList())
		    } else {
		        result.push(allItems[i].propUrl)
		    }
		}
		return result
	}

	// playlist serialization
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

    // playlist deserialization
    function fromContent(content) {
    	var result = []

    	var list = JSON.parse(content)
    	for (var i = 0; i < list.length; i++) {
    		result.push({
    			"itemName": list[i].itemName,
    			"itemUrl": list[i].itemUrl,
    			"itemChild": fromContent(list[i].itemChild)
    			})
    	}

    	return result
    }

    // Note: this function is solely used for _initialization_
    function initializeWithContent(content) {
     	var eles = fromContent(content)   
     	for (var i = 0; i < eles.length; i++) {
     		model.append(eles[i])
     	}
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

		    property bool isGroup: propChild ? propChild.count > 0 : false
			property bool isSelected: isGroup ? child.isSelected : playlist.currentPlayingSource == itemUrl
			property bool isHover: mouse_area.containsMouse
			onIsSelectedChanged: column.ListView.view.isSelected = isSelected

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
					if (propUrl == url) {
						column.ListView.view.model.remove(index, 1)
					}
				}
			}

			Item {
				width: column.width
				height: 24

				MouseArea {
					id: mouse_area
					hoverEnabled: true
					acceptedButtons: Qt.LeftButton | Qt.RightButton
					anchors.fill: parent
					onEntered: {
					    delete_button.visible = true
					    delete_button.source = "image/delete_hover.png"
					    tooltip.showTip(itemName)
					}
					onExited: {
						tooltip.hideTip()
					    delete_button.visible = false
					    delete_button.source = "image/delete_normal.png"
					}
					onClicked: {
						if (mouse.button == Qt.RightButton) {
							column.ListView.view.root.clickedOnItemUrl = propUrl
						    _menu_controller.show_playlist_menu(propUrl)
						} else {
							if (column.isGroup) {
								sub.visible = !sub.visible							
							}
						}
					}
					onDoubleClicked: {
						if(!column.isSelected){
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
                    color: {
                    	if (column.isSelected) {
                    		return column.isGroup ? "#8853B6F5" : "#53B6F5"
                    	} else if (column.isHover) {
                    		return "#FFFFFF"
                    	} else {
                    		return "#9F9F9F"
                    	}
                    }

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
							column.ListView.view.model.remove(index, 1)
						}

						onPressed: delete_button.source = "image/delete_pressed.png"
						onReleased: delete_button.source = "image/delete_hover.png"
					}
				}
			}

			Loader {
				id: sub
				x: 14
				visible: false
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