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
		print(allItems.length)
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
	function addItem(path) {
		var parent = findItemByPath(path.slice(0, path.length))
		if (parent != null) {
			parent.child.model.append({"itemName": path[path.length - 1][0],
									   "itemUrl": path[path.length - 1][1],
									   "itemChild": path[path.length -1][2]})
		}
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

			Item {
				width: column.width
				height: 20

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
					color: column.isGroup ? "8800BDFF" : playlist.isSelected ? "#00BDFF" : mouse_area.containsMouse ? "white" : "#B4B4B4"
					font.pixelSize: column.isGroup ? 12 : playlist.isSelected ? 13 : 11

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
						hoverEnabled: true
						anchors.fill: parent

						onClicked: {

						}
						onPressed: delete_button.source = "image/delete_pressed.png"
						onReleased: delete_button.source = "image/delete_hover.png"
					}
				}
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
						mouse.accepted = false
						if (column.isGroup) {
							sub.visible = !sub.visible							
						} else {
							column.isSelected = !column.isSelected
						}
					}
				}					
			}

			Loader {
				id: sub
				x: 15
				visible: false
				active: column.isGroup
				source: "PlaylistView2.qml"
				asynchronous: true
				onLoaded: {
					item.model = itemChild
					item.width -= sub
				}
			}
		}
	}
}