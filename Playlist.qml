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

    signal newSourceSelected (string path)
    
    signal addButtonClicked ()
    signal deleteButtonClicked ()
    signal clearButtonClicked ()
    signal modeButtonClicked ()

    states: [
        State {
            name: "active"
            PropertyChanges { target: playlistPanel; color: "#1B1C1D"; opacity: 1 }
            PropertyChanges { target: hidePlaylistButton; source: "image/playlist_handle_bg.png"; opacity: 1 }
        },
        State {
            name: "inactive"
            PropertyChanges { target: playlistPanel; color: "#1B1C1D"; opacity: 0.95 }
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

    function getContent(type) {
        if (type == "network") {
            return network_playlist.getContent()
        } else {
            return local_playlist.getContent()
        }
    }

    function addItem(playlistType, item) {
        if (playlistType == "network") {
            network_playlist.addItem(item)
        } else {
            local_playlist.addItem(item)
        }
    }

    function clear() {
        print(playlistPanel.tabId)
        if (playlistPanel.tabId == "local") {
            local_playlist.clear()
            database.playlist_local = ""
        } else {
            network_playlist.cleart()
            database.playlist_network = ""
        }
    }
    
    function getPreviousSource() {
        return local_playlist.getPreviousSource()
    }

    function getNextSource() {
        // if (local_playlist.isSelected) {
        //     return local_playlist.getNextSource()
        // } else {
        //     return network_playlist.getNextSource()
        // }
        return local_playlist.getNextSource()
    }

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
        duration: 100
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
        duration: 100
        easing.type: Easing.OutQuint

        onStopped: {
            playlistPanel.visible = false
        }
    }

    MouseArea {
        id: playlistPanelArea
        anchors.fill: parent
        hoverEnabled: true

        onEntered: { playlistPanel.state = "active" }
        onWheel: {}
    }

    Item {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: bottom_rect.top
        anchors.topMargin: 20
        anchors.bottomMargin: 20

        DScrollBar {
            flickable: local_playlist
            anchors.right: parent.right
            anchors.rightMargin: 5
        }

        PlaylistView {
            id: local_playlist
            width: 181
            height: parent.height
            root: local_playlist
            visible: playlistPanel.expanded && tabId == "local"
            currentPlayingSource: playlistPanel.currentPlayingSource
            anchors.horizontalCenter: parent.horizontalCenter

            onNewSourceSelected: {
                playlistPanel.newSourceSelected(path)
            }

            Component.onCompleted: initializeWithContent(database.playlist_local)
        }

        PlaylistView {
            id: network_playlist
            visible: false
            width: 0
            root: local_playlist
            currentPlayingSource: playlistPanel.currentPlayingSource

            // Component.onCompleted: initializeWithContent(database.playlist_local)
        }
    }

    Rectangle {
        id: bottom_rect
        width: parent.width
        height: 25
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
            OpacityImageButton {
                imageName: "image/playlist_delete_button.png"
                anchors.verticalCenter: parent.verticalCenter                
                onClicked: { playlistPanel.deleteButtonClicked() }
            }
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

    Image {
        id: hidePlaylistButton
        width: implicitWidth
        height: implicitHeight
        anchors.right: parent.left
        anchors.verticalCenter: playlistPanel.verticalCenter

        DImageButton {
            id: handle_arrow_button
            normal_image: "image/playlist_handle_normal.png"
            hover_image: "image/playlist_handle_hover.png"
            press_image: "image/playlist_handle_press.png"
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 3

            onClicked: {
                hidingPlaylistPanelAnimation.restart()
            }
        }
    }
}
