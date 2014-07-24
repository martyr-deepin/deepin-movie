import QtQuick 2.1
import Deepin.Widgets 1.0

Rectangle {
    id: playlistPanel
    state: "active"
    opacity: 1

    property var currentItem
    property string tabId: "local"
    property bool expanded: width == program_constants.playlistWidth
    property url currentPlayingSource
    property url clickedOnItemUrl: playlist.clickedOnItemUrl
    property int maxWidth: program_constants.playlistWidth
    property alias window: playlistPanelArea.window

    signal newSourceSelected (string path)
    
    signal addButtonClicked ()
    signal deleteButtonClicked ()
    signal clearButtonClicked ()
    signal modeButtonClicked ()

    signal moveInWindowButtons
    signal moveOutWindowButtons 

    states: [
        State {
            name: "active"
            PropertyChanges { target: playlistPanel; color: "#1B1C1D"; opacity: 1 }
            PropertyChanges { target: hidePlaylistButton; source: "image/playlist_handle_bg.png"; opacity: 1 }
        },
        State {
            name: "inactive"
            PropertyChanges { target: playlistPanel; color: "#1B1C1D"; opacity: 0.80 }
            PropertyChanges { target: hidePlaylistButton; source: "image/playlist_handle_bg.png"; opacity: 0.95 }
        }
    ]

    onStateChanged: {
        if (state == "inactive") {
            hide_timer.restart()
        } else {
            hide_timer.stop()
        }
    }

    function show() {
        if (!expanded) {
            visible = true
            showingPlaylistPanelAnimation.restart()
        }
    }

    function hide() {
        if (expanded) {
            moveOutWindowButtons()
            hidingPlaylistPanelAnimation.restart()
        }
    }

    function toggleShow() {
        if (expanded) {
            hidingPlaylistPanelAnimation.restart()
        } else {
            visible = true
            showingPlaylistPanelAnimation.restart()
        }
    }

    function getContent(type) { return playlist.getContent() }

    function addItem(item) { playlist.addItem(item) }

    function removeClickedItem() { playlist.removeItem(clickedOnItemUrl) }

    function removeInvalidItems(valid_check_func) { playlist.removeInvalidItems(valid_check_func) }

    function showClickedItemInFM() { _utils.showFileInFM(clickedOnItemUrl) }

    function clear() {
        playlist.clear()
        database.playlist_local = ""
    }
    
    function getRandom() { return playlist.getRandom() }
    function getPreviousSource(source) { return playlist.getPreviousSource(source) }
    function getNextSource(source) { return playlist.getNextSource(source) }
    function getPreviousSourceCycle(source) { return playlist.getPreviousSourceCycle(source) }
    function getNextSourceCycle(source) { return playlist.getNextSourceCycle(source) }

    Timer {
        id: hide_timer
        interval: 5000
        repeat: false

        onTriggered: hidingPlaylistPanelAnimation.start()
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
        onExited: { mouseInPlaylistArea() || (playlistPanel.state = "inactive"); 
                    playlistPanel.moveOutWindowButtons() }
        onWheel: {}
        onClicked: { 
            if (mouse.button == Qt.RightButton) {
                _menu_controller.show_playlist_menu("")
            } else if(shouldPerformClick){
                playlistPanel.hide() 
            }
        }
        onPositionChanged: {
            if (inRectCheck(mouse, Qt.rect(0, 0, width, 30))) {
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
            anchors.horizontalCenter: parent.horizontalCenter

            // x, y are all values related to playlist
            function getClickedItemUrl(x, y) {
                var playlistSubItem = childAt(x, y)
                if (!playlistSubItem) return
                var subItemPoint = mapToItem(playlistSubItem, x, y)
                var listItem = playlistSubItem.childAt(subItemPoint.x, subItemPoint.y)
                if (!listItem) return

                return listItem.propUrl
            }

            onNewSourceSelected: {
                playlistPanel.newSourceSelected(path)
            }

            Component.onCompleted: initializeWithContent(database.playlist_local)
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
                imageName: "image/playlist_mode_button.png"
                anchors.verticalCenter: parent.verticalCenter
                onClicked: { playlistPanel.modeButtonClicked() }
            }
            // OpacityImageButton {
            //     imageName: "image/playlist_delete_button.png"
            //     anchors.verticalCenter: parent.verticalCenter                
            //     onClicked: { playlistPanel.deleteButtonClicked() }
            // }
            OpacityImageButton {
                imageName: "image/playlist_add_button.png"
                anchors.verticalCenter: parent.verticalCenter                
                onClicked: { playlistPanel.addButtonClicked() }
            }            
            OpacityImageButton {
                imageName: "image/playlist_clear_button.png"
                anchors.verticalCenter: parent.verticalCenter                
                onClicked: { playlistPanel.clearButtonClicked() }
            }            
        }
    }

    MouseArea {
        width: hidePlaylistButton.width
        height: parent.height
        hoverEnabled: true

        anchors.right: parent.left
        anchors.verticalCenter: parent.verticalCenter

        onPositionChanged: {
            if (pressed) {
                program_constants.playlistWidth = Math.min(playlistPanel.maxWidth, 
                    Math.max(program_constants.playlistMinWidth, 
                        playlistPanel.width - mouse.x))
                playlistPanel.width = program_constants.playlistWidth
            } else {
                cursorShape = Qt.SizeHorCursor
            }
        }

        Image {
            id: hidePlaylistButton
            width: implicitWidth
            height: implicitHeight
            anchors.centerIn: parent

            DImageButton {
                id: handle_arrow_button
                normal_image: "image/playlist_handle_normal.png"
                hover_image: "image/playlist_handle_hover_press.png"
                press_image: "image/playlist_handle_hover_press.png"
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 5

                onClicked: {
                    hidingPlaylistPanelAnimation.restart()
                }
            }
        }
    }
}
