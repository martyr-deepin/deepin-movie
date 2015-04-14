import QtQuick 2.1
import Deepin.Widgets 1.0
import "sources/ui_utils.js" as UIUtils

Rectangle {
    id: playlistPanel
    state: "active"
    opacity: 1

    property var currentItem
    property string tabId: "local"
    property bool expanded: width == program_constants.playlistWidth
    property bool canExpand: true
    property string currentPlayingSource
    property string clickedOnItemUrl: playlist.clickedOnItemUrl
    property string clickedOnItemName: playlist.clickedOnItemName
    property int maxWidth: program_constants.playlistWidth
    property alias window: playlistPanelArea.window
    property QtObject tooltipItem

    signal showed
    signal newSourceSelected (string path)

    signal addButtonClicked ()
    signal modeButtonClicked ()

    signal moveInWindowButtons
    signal moveOutWindowButtons

    signal cleared()
    signal itemRemoved(string url)
    signal categoryRemoved(string name)

    states: [
        State {
            name: "active"
            PropertyChanges { target: playlistPanel; color: "#1B1C1D"; opacity: 1 }
            PropertyChanges { target: hidePlaylistButton; opacity: 1 }
        },
        State {
            name: "inactive"
            PropertyChanges { target: playlistPanel; color: "#1B1C1D"; opacity: 0.80 }
            PropertyChanges { target: hidePlaylistButton; opacity: 0.95 }
        }
    ]

    onStateChanged: {
        if (state == "inactive") {
            moveOutWindowButtons()
            hide_timer.restart()
        } else {
            hide_timer.stop()
        }
    }

    function show() {
        program_constants.playlistWidth = Math.min(maxWidth, program_constants.playlistWidth)
        visible = true
        hide_handle_timer.stop()
        showingPlaylistPanelAnimation.restart()
    }

    function hide() {
        moveOutWindowButtons()
        hidingPlaylistPanelAnimation.restart()
    }

    function showHandle() {
        visible = true
        hide_handle_timer.restart()
    }

    function toggleShow() { expanded ? hide() : show() }

    function getContent() { return playlist.getContent() }

    function contains(url) { return playlist.contains(url) }

    function addItem(groupName, itemName, itemUrl) { playlist.addItem(groupName, itemName, itemUrl) }

    function removeItem(itemUrl) { playlist.removeItem(itemUrl) }

    function removeClickedItem() {
        if (clickedOnItemUrl.toString() != "") {
            playlist.removeItem(clickedOnItemUrl)
        } else if (clickedOnItemName != "") {
            playlist.removeGroup(clickedOnItemName)
        }
    }

    function removeInvalidItems(valid_check_func) { playlist.removeInvalidItems(valid_check_func) }

    function showClickedItemInFM() { _utils.showFileInFM(clickedOnItemUrl) }

    function clear() { playlist.clear() }

    function getFirst() { return playlist.getFirst() }
    function getRandom() { return playlist.getRandom() }
    function getNextSource(source) { return playlist.getNextSource(source) }
    function getNextSourceCycle(source) { return playlist.getNextSourceCycle(source) }

    function changeFileExistence(file, exists) { exists ? playlist.fileBack(file) : playlist.fileMissing(file) }

    Timer {
        id: hide_timer
        interval: 5000
        repeat: false

        onTriggered: hide()
    }

    Timer {
        id: hide_handle_timer
        interval: 300

        onTriggered: {
            if (mouseInPlaylistTriggerArea()) {
                hide_handle_timer.restart()
            } else {
                hide()
            }
        }
    }

    PropertyAnimation {
        id: showingPlaylistPanelAnimation
        alwaysRunToEnd: true

        target: playlistPanel
        property: "width"
        to: program_constants.playlistWidth
        duration: 300
        easing.type: Easing.OutQuint

        onStopped: {
            playlistPanel.showed()
            playlistPanel.state = "active"
        }
    }

    PropertyAnimation {
        id: hidingPlaylistPanelAnimation
        alwaysRunToEnd: true

        target: playlistPanel
        property: "width"
        to: 0
        duration: 300
        easing.type: Easing.OutQuint

        onStopped: {
            playlistPanel.visible = false
        }
    }

    DragableArea {
        id: playlistPanelArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onEntered: { playlistPanel.state = "active" }
        onExited: {
            if (!mouseInPlaylistArea()) {
                playlistPanel.state = "inactive"
                playlistPanel.moveOutWindowButtons()
            }
        }
        onWheel: {}
        onClicked: {
            if (mouse.button == Qt.RightButton) {
                _menu_controller.show_playlist_menu("", playlist.isEmpty())
            } else if(shouldPerformClick){
                playlistPanel.hide()
            }
        }
        onPositionChanged: {
            if (UIUtils.inRectCheck(mouse, Qt.rect(0, 0, width, 30))) {
                playlistPanel.moveInWindowButtons()
            } else {
                playlistPanel.moveOutWindowButtons()
            }
        }
    }

    Item {
        width: parent.width
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: bottom_rect.top
        anchors.topMargin: 20 + 6
        anchors.bottomMargin: 20

        DScrollBar {
            visible: playlistPanel.expanded && playlist.interactive
            flickable: playlist
            anchors.right: parent.right
            anchors.rightMargin: 5
        }

        PlaylistView {
            id: playlist
            width: parent.width - 14 * 2
            height: parent.height
            interactive: childrenRect.height > parent.height
            root: playlist
            currentIndex: -1 // this is important, getClickedItemInfo will sometimes works wrongly.
            visible: playlistPanel.expanded
            currentPlayingSource: playlistPanel.currentPlayingSource
            anchors.left: parent.left
            anchors.leftMargin: 8

            // x, y are all values related to playlist
            function getClickedItemUrl(x, y) {
                var playlistSubItem = childAt(x, y)
                if (!playlistSubItem) return
                var subItemPoint = mapToItem(playlistSubItem, x, y)
                var listItem = playlistSubItem.childAt(subItemPoint.x, subItemPoint.y)
                if (!listItem) return

                return listItem.propUrl
            }

            onCleared: playlistPanel.cleared()
            onItemRemoved: playlistPanel.itemRemoved(url)
            onCategoryRemoved: playlistPanel.categoryRemoved(name)

            onNewSourceSelected: {
                playlistPanel.newSourceSelected(path)
            }

            Component.onCompleted: initializeWithContent(_database.getPlaylistContent())
        }
    }

    Rectangle {
        id: bottom_rect
        width: parent.width
        height: 25
        visible: playlistPanel.expanded
        color: Qt.rgba(1, 1, 1, 0.05)
        anchors.bottom: parent.bottom

        Row {
            height: parent.height
            anchors.right: parent.right
            anchors.rightMargin: 10
            spacing: 10

            OpacityImageButton {
                tooltip: dsTr("Play mode")
                tooltipItem: playlistPanel.tooltipItem

                imageName: "image/playlist_mode_button.png"
                anchors.verticalCenter: parent.verticalCenter
                onClicked: { playlistPanel.modeButtonClicked() }
            }
            OpacityImageButton {
                tooltip: dsTr("Add file")
                tooltipItem: playlistPanel.tooltipItem

                imageName: "image/playlist_add_button.png"
                anchors.verticalCenter: parent.verticalCenter
                onClicked: { playlistPanel.addButtonClicked() }
            }
            OpacityImageButton {
                tooltip: dsTr("Clear playlist")
                tooltipItem: playlistPanel.tooltipItem

                imageName: "image/playlist_clear_button.png"
                anchors.verticalCenter: parent.verticalCenter
                onClicked: { playlist.clear() }
            }
        }
    }

    MouseArea {
        width: hidePlaylistButton.width
        height: parent.height
        hoverEnabled: true
        enabled: playlistPanel.expanded

        anchors.right: parent.left
        anchors.verticalCenter: parent.verticalCenter

        onPositionChanged: {
            if (playlistPanel.expanded) {
                if (pressed) {
                    program_constants.playlistWidth = Math.min(playlistPanel.maxWidth,
                        Math.max(program_constants.playlistMinWidth,
                            playlistPanel.width - mouse.x))
                    playlistPanel.width = program_constants.playlistWidth
                } else {
                    cursorShape = Qt.SizeHorCursor
                }
            }
        }

        Image {
            id: hidePlaylistButton
            width: implicitWidth
            height: implicitHeight
            source: "image/playlist_handle_bg.png"
            anchors.centerIn: parent

            function buttonClicked() {
                if (handle_arrow_button.rotation == 180) {
                    playlistPanel.show()
                } else {
                    playlistPanel.hide()
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: { hidePlaylistButton.buttonClicked() }
                onPositionChanged: { playlistPanel.state = "active" }
            }

            DImageButton {
                id: handle_arrow_button
                normal_image: "image/playlist_handle_normal.png"
                hover_image: "image/playlist_handle_hover_press.png"
                press_image: "image/playlist_handle_hover_press.png"
                rotation: playlistPanel.expanded ? 0 : 180
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 3

                onClicked: { hidePlaylistButton.buttonClicked() }
            }
        }
    }
}
