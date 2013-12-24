import QtQuick 2.1

Rectangle {
    id: playlistPanel
    color: "#1D1D1D"
    height: video.height
    width: hideWidth
    opacity: 1

    property alias playlistPanelArea: playlistPanelArea
    property alias hidePlaylistButton: hidePlaylistButton
    
    DragArea {
        id: playlistPanelArea
        window: windowView
        anchors.fill: parent
        hoverEnabled: true
        
        onEntered: {
            playlistPanel.color = "#1D1D1D"
            playlistPanel.opacity = 1
            hidePlaylistButton.source = "image/playlist_button_active_background.png"
        }
        
        onExited: {
            playlistPanel.color = "#000000"
            playlistPanel.opacity = 0.9
            hidePlaylistButton.source = "image/playlist_button_inactive_background.png"
        }
        
        onClicked: {
            console.log("Click on playlist.")
        }
    }
    
    Image {
        id: hidePlaylistButton
        source: "image/playlist_button_active_background.png"
        anchors.left: playlistTopline.left
        anchors.leftMargin: 1
        anchors.verticalCenter: playlistPanel.verticalCenter
        visible: playlistPanel.width == showWidth
        opacity: playlistPanel.opacity + 0.1
        
        Image {
            id: hidePlaylistArrow
            source: "image/playlist_button_arrow.png"
            anchors.right: parent.right
            anchors.rightMargin: 7
            anchors.verticalCenter: parent.verticalCenter
            opacity: playlistPanel.opacity
        }
        
        MouseArea {
            id: hidePlaylistButtonArea
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.left: hidePlaylistArrow.left
            hoverEnabled: true
            
            onClicked: {
                hidingPlaylistPanelAnimation.restart()
            }
            
            onEntered: {
                inTriggerButton = true
            }
            
            onExited: {
                inTriggerButton = false
            }
        }
    }
    
    Rectangle {
        id: playlistTopline
        color: "#060606"
        width: 1
        anchors.top: playlistPanel.top
        anchors.bottom: hidePlaylistButton.top
        anchors.right: playlistPanel.right
        visible: playlistPanel.width == showWidth
        opacity: playlistPanel.opacity
    }

    Rectangle {
        id: playlistBottomline
        color: "#060606"
        width: 1
        anchors.top: hidePlaylistButton.bottom
        anchors.bottom: playlistPanel.bottom
        anchors.right: playlistPanel.right
        visible: playlistPanel.width == showWidth
        opacity: playlistPanel.opacity
    }
}