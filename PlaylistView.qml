import QtQuick 2.1

ListView {
	id: playlist
	width: 300
	height: childrenRect.height

	property var allItems: []
	property bool isSelected: false
	property string currentPlayingSource
	property var root

	signal newSourceSelected(string path)
    
	function getPreviousSource() {
	   	if (isSelected) {
	   		for (var i = 0; i < allItems.length; i++) {
	   			if (allItems[i].isSelected) { // seek which Column is selected
	   				if (allItems[i].isGroup) { // if the Column has child, then find recursively
	   					return allItems[i].child.getNextSource()
	   				} else {
	   					if (i == 0) { // the source current playing is the first one in this category
	   						return null
	   					} else {
	   						if (i - 1 < 0 || allItems[i - 1].isGroup) { // the previous item in this category has child
	   							return null
	   						} else {
	   							return allItems[i - 1].propUrl // finally, get what we want
	   						}
	   					}
	   				}
	   			}
	   		}
	   	}
	   	return null
	}    

	function getNextSource() {
	   	if (isSelected) {
	   		for (var i = 0; i < allItems.length; i++) {
	   			if (allItems[i].isSelected) { // seek which Column is selected
	   				if (allItems[i].isGroup) { // if the Column has child, then find recursively
	   					return allItems[i].child.getNextSource()
	   				} else {
	   					if (i == allItems.length) { // the source current playing is the last one in this category
	   						return null
	   					} else {
	   						if (i + 1 > allItems.length || allItems[i + 1].isGroup) { // the next item in this category has child
	   							return null
	   						} else {
	   							return allItems[i + 1].propUrl // finally, get what we want
	   						}
	   					}
	   				}
	   			}
	   		}
	   	}
	   	return null
	}

	// ["Level One", "Level Two", "Level Three"]
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
					item.itemChild = []
					item.itemChild.push(result)
				}
			result = item
		}
		return result
	}

	// ["Level One", "Level Two", ("Level Three", "file:///home/hualet/Videos/movie.mov", [])]
	function addItem(path) {
		var parent = findItemByPath(path.slice(0, path.length - 1))
        if (allItems.length == 0 || parent == null) {
            model.append(_pathToListElement(path))
        } else if(parent != null){
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
			property bool isSelected: {
				var result = isGroup ? child.isSelected : (playlist.currentPlayingSource == itemUrl)
				ListView.view.isSelected = ListView.view.isSelected || result
				return result
			}

			Component.onCompleted: ListView.view.allItems.push(column)
			Component.onDestruction: {
				var idx = column.ListView.view.allItems.indexOf(column)
				if (idx != -1) {
					column.ListView.view.allItems.splice(idx, 1)
				}
			}

			Item {
				width: column.width
				height: 24

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
						} else if(!column.isSelected){
							column.ListView.view.root.newSourceSelected(propUrl)
						}
					}
				}

				Image {
					id: expand_button
                    visible: false
					/* opacity: isGroup ? 1 : 0 */
					source: sub.visible ? "image/expanded.png" : "image/not_expanded.png"

					anchors.verticalCenter: parent.verticalCenter
				}
                
                Image {
                    width: 10
                    height: 10
                    anchors.centerIn: expand_button
                    source: column.isSelected ? column.isGroup ? "" : "image/playing_indicator.png" : ""
                }
                
				Text {
					id: name
					width: parent.width - expand_button.width - anchors.leftMargin - anchors.rightMargin - delete_button.width
					text: itemName
					elide: Text.ElideRight
					font.pixelSize: 14
					color: column.isSelected ? column.isGroup ? "#8800BDFF" : "#00BDFF" : mouse_area.containsMouse ? "white" : "#B4B4B4"

					anchors.left: expand_button.right
					anchors.leftMargin: 9
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
				x: 10
				visible: column.isSelected
				active: column.isGroup
				source: "PlaylistView.qml"
				asynchronous: true
				onLoaded: {
					item.model = column.propChild
					item.width = column.width - sub.x
					item.root = column.ListView.view.root
					item.currentPlayingSource = Qt.binding(function () {return column.ListView.view.currentPlayingSource})
				}
			}
		}
	}
}