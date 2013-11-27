import QtQuick 2.1
import QtMultimedia 5.0
import QtGraphicalEffects 1.0

Video {
    id: video
    autoPlay: false
    /* autoPlay: true */
    /* muted: true */
    anchors.leftMargin: 1
    anchors.rightMargin: 1
    
    property bool continuePlay: false
    
    property string timeTotal: ""
    property string timeCurrent: ""
    property double timePosition: 0
    property double videoPosition: 0
    
    property bool showBottomPanel: true
    
    property double showHeight: 64
    property double hideHeight: 0
    
    property double showWidth: 200
    property double hideWidth: 0
    property double triggerPlaylistX: 50
    property bool inTriggerButton: false
    
    property double triggerTopPanelHeight: 50
    property double triggerBottomPanelHeight: 50
    property double triggerPlaylistProtectedWidth: 50
    
    property alias videoPreview: videoPreview
    property alias videoArea: videoArea
    property alias hidingBottomPanelAnimation: hidingBottomPanelAnimation
    property alias hidingTimer: hidingTimer
    property alias playlistPanelArea: playlistPanelArea
    property alias notifybar: notifybar
    property alias pauseNotify: pauseNotify
    
    signal bottomPanelShow
    signal bottomPanelHide
    signal hideCursor
    signal showCursor
    signal toggleFullscreen
    
    Component.onCompleted: {
        timeTotal = formatTime(video.duration)
        
        hidingTimer.restart()
        
        video.seek(database.fetch_video_position(video.source))
        video.play()
        
        video.volume = config.fetch("Normal", "volume") * 1
    }
    
    onPositionChanged: {
        timeCurrent = formatTime(video.position)
        timePosition = video.position / video.duration
    }
    
    onToggleFullscreen: {
        indicatorArea.visible = windowView.getState() != Qt.WindowFullScreen
    }
    
    Connections {
        target: video
        onVolumeChanged: {
            playerVolume.volumeMiddle.width = video.volume * playerVolume.showWidth
        }
    }
    
    function tryPauseVideo() {
        if (video.playbackState == MediaPlayer.PlayingState) {
            video.pause()
            video.continuePlay = true
        } else {
            video.continuePlay = false
        }
    }
    
    function tryPlayVideo() {
        if (video.playbackState != MediaPlayer.PlayingState) {
            if (video.continuePlay) {
                video.play()
                video.continuePlay = false
            }
        }
    }
    
    function formatTime(millseconds) {
        var secs = Math.floor(millseconds / 1000)
        var hr = Math.floor(secs / 3600);
        var min = Math.floor((secs - (hr * 3600))/60);
        var sec = secs - (hr * 3600) - (min * 60);
          
        if (hr < 10) {hr = "0" + hr; }
        if (min < 10) {min = "0" + min;}
        if (sec < 10) {sec = "0" + sec;}
        if (hr) {hr = "00";}
        return hr + ':' + min + ':' + sec;
    }

    function toggle() {
        video.playbackState == MediaPlayer.PlayingState ? video.pause() : video.play()
    }
    
    function forward() {
        var newPositoin = video.position + 5000
        video.seek(newPositoin)
        
        notifybar.show("image/notify_forward.png", "快进至 " + formatTime(newPositoin))
    }
    
    function backward() {
        var newPositoin = video.position - 5000
        video.seek(newPositoin)
        
        notifybar.show("image/notify_backward.png", "快退至 " + formatTime(newPositoin))
    }
    
    function increaseVolume() {
        video.volume = Math.min(video.volume + 0.05, 1.0)
        
        notifybar.show("image/notify_volume.png", "音量: " + Math.round(video.volume * 100) + "%")
    }

    function decreaseVolume() {
        video.volume = Math.max(video.volume - 0.05, 0.0)
        
        notifybar.show("image/notify_volume.png", "音量: " + Math.round(video.volume * 100) + "%")
    }
    
    Rectangle {
        id: indicatorArea
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 10
        visible: false
        width: 80
        
        Text {
            id: timeIndicator
            anchors.horizontalCenter: parent.horizontalCenter
            text: ""
            font.pixelSize: 20
            color: "#80DDDDDD"
            style: Text.Outline
            styleColor: "#FF333333"
            
            Timer {
                interval: 1000;
                running: true;
                repeat: true
                onTriggered: {
                    timeIndicator.text = Qt.formatDateTime(new Date(), "hh:mm")
                }
            }
        }

        Row {
            id: positionIndicator
            spacing: 2
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: timeIndicator.bottom
            
            property int dotSize: 3
            
            Repeater {
                model: 10
                delegate: Rectangle {
                    color: video.position / video.duration * 10 > index ? "#80DDDDDD" : "#80666666"
                    width: positionIndicator.dotSize
                    height: positionIndicator.dotSize
                }
            }
        }
    }
    
    Notifybar {
        id: notifybar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 20 + titlebar.height
        anchors.leftMargin: 20
    }

    Image {
        id: pauseNotify
        source: "image/pause_notify.svg"
        visible: video.playbackState != MediaPlayer.PlayingState
    }
    
    Connections {
        target: video
        onPaused: {
            pauseNotify.scale = 0.6
            pauseNotify.opacity = 0
            pauseNotify.anchors.left = undefined
            pauseNotify.anchors.bottom = undefined
            pauseNotify.anchors.leftMargin = 0
            pauseNotify.anchors.bottomMargin = 0
            pauseNotify.x = (parent.width - pauseNotify.width) / 2
            pauseNotify.y = (parent.height - pauseNotify.height) / 2
            
            movePauseNotify.restart()
        }
    }
    
    DragArea {
        id: videoArea
        window: windowView
        anchors.fill: parent
        hoverEnabled: true
        
        property real windowViewX: 0
        property real windowViewY: 0

        property int maskHeight: 30
        
        onDoubleClicked: {
            video.toggleFullscreen()
        }
        
        onPositionChanged: {
            if (playlistPanel.width != showWidth || mouseX >= showWidth + triggerPlaylistProtectedWidth) {
                if (mouseX < triggerPlaylistX) {
                    if (!showingPlaylistPanelAnimation.running) {
                        showingPlaylistPanelAnimation.restart()
                    }
                } else {
                    if (mouseY < triggerTopPanelHeight || mouseY > videoArea.height - triggerBottomPanelHeight) {
                        if (!showingBottomPanelAnimation.running) {
                            showingBottomPanelAnimation.restart()
                        }
                    }
                    hidingTimer.restart()
                }
            }
            video.showCursor()
        }

        onExited: {
            video.showCursor()
        }
        
        onSingleClicked: {
            toggle()
        }
        
        Timer {
            id: hidingTimer
            interval: 2000
            repeat: false
            onTriggered: {
                if (!hidingBottomPanelAnimation.running) {
                    hidingBottomPanelAnimation.restart()
                }
                
                if (!playlistPanelArea.containsMouse && !hidePlaylistButton.containsMouse) {
                    video.hideCursor()
                }
                
                interval = 2000
            }
        }
        
        InteractiveItem {
            targetItem: parent
        }
    }
    
    Rectangle {
        id: playlistPanel
        color: "#1D1D1D"
        height: video.height
        width: hideWidth
        opacity: 1
        
        DragArea {
            id: playlistPanelArea
            window: windowView
            anchors.fill: parent
            hoverEnabled: true
            
            onEntered: {
                playlistPanel.color = "#1D1D1D"
                playlistPanel.opacity = 1
            }
            
            onExited: {
                playlistPanel.color = "#000000"
                playlistPanel.opacity = 0.9
            }
            
            onClicked: {
                console.log("Click on playlist.")
            }
        }
        
        Image {
            id: hidePlaylistButton
            source: "image/playlist_button_background.png"
            anchors.left: playlistTopline.left
            anchors.verticalCenter: playlistPanel.verticalCenter
            visible: playlistPanel.width == showWidth
            opacity: playlistPanel.opacity
            
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
    
    Rectangle {
        id: bottomPanel
        color: Qt.rgba(0, 0, 0, 0)
        height: showHeight
        anchors.left: video.left
        anchors.right: video.right
        y: video.height - height
        opacity: 1
        
        property double showOpacity: 0.9
        property double hideOpacity: 0
        
        LinearGradient {
            id: bottomPanelBackround
            anchors.fill: parent
            start: Qt.point(0, 0)
            end: Qt.point(0, height)
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#88000000"}
                GradientStop { position: 0.1; color: "#AA000000"}
                GradientStop { position: 0.6; color: "#DD000000"}
                GradientStop { position: 1.0; color: "#FF000000"}
            }
            visible: showBottomPanel ? 1 : 0
        }
                    
        DragArea {
            id: bottomPanelArea
            window: windowView
            anchors.fill: parent
            hoverEnabled: true
            
            onPositionChanged: {
                hidingTimer.stop()
            }
            
            onExited: {
                hidingTimer.restart()
            }

            InteractiveItem {
                targetItem: parent
            }
        }

        Column {
            anchors.fill: parent
            
            Item {
                id: progressbar
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right

                Rectangle {
                    id: progressbarBackground
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 7
                    color: "#5540404a"
                    visible: showBottomPanel ? 1 : 0
                    
                    MouseArea {
                        id: progressbarArea
                        anchors.fill: parent
                        hoverEnabled: true
                        
                        onClicked: {
                            video.seek(video.duration * mouseX / (progressbarBackground.width - progressbarBackground.x))
                        }
                        
                        onPositionChanged: {
                            hidingTimer.stop()
                            
                            videoPreview.visible = true
                            videoPreview.x = Math.max(Math.min(mouseX - videoPreview.width / 2, 
                                                               progressbarArea.width - videoPreview.width),
                                                      0)
                            videoPreview.y = progressbarArea.y - videoPreview.height + videoPreview.cornerHeight
                            
                            videoPosition = video.duration * mouseX / (progressbarBackground.width - progressbarBackground.x)
                            
                            videoPreview.video.visible = false
                            updatePreviewTimer.restart()
                            
                            videoPreview.videoTime.text = formatTime(videoPosition)
                            
                            if (mouseX < videoPreview.width / 2) {
                                videoPreview.cornerPos = mouseX
                            } else if (mouseX > progressbarArea.width - videoPreview.width / 2) {
                                videoPreview.cornerPos = mouseX - progressbarArea.width + videoPreview.width
                            } else {
                                videoPreview.cornerPos = videoPreview.width / 2
                            }
                        }
                        
                        onExited: {
                            videoPreview.visible = false
                        }
                        
                        Timer {
                            id: updatePreviewTimer
                            interval: 50
                            repeat: false
                            onTriggered: {
                                videoPreview.video.seek(videoPosition)
                            }
                        }
                        
                        InteractiveItem {
                            targetItem: parent
                        }
                    }
                    
                    LinearGradient {
                        id: progressbarForeground
                        anchors.left: parent.left
                        anchors.top: parent.top
                        height: parent.height
                        width: timePosition * parent.width
                        start: Qt.point(0, 0)
                        end: Qt.point(width, 0)
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#EE00f893"}
                            GradientStop { position: 0.95; color: "#EE00f893"}
                            GradientStop { position: 1.0; color: "#EE00f893"}
                        }
                        visible: showBottomPanel ? 1 : 0
                    }
                    
                    Image {
                        source: "image/progress_pointer.png"
                        x: Math.min(Math.max(timePosition * parent.width - width / 2, 0), parent.width - width)
                        y: progressbarForeground.y + (progressbarForeground.height - height) / 2
                    }
                    
                    Preview {
                        id: videoPreview
                        visible: false
                        
                        onPositionChanged: {
                            videoPreview.video.visible = true
                        }
                    }
                }
            }
            
            Item {
                id: buttonArea
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: 34
                
                Row {
                    id: leftButtonArea
                    anchors.left: parent.left
                    anchors.leftMargin: 24
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 20
                    
                    ToggleButton {
                        id: playerList
                        imageName: "image/player_list"
                        anchors.verticalCenter: parent.verticalCenter
                        visible: showBottomPanel ? 1 : 0
                        active: playlistPanel.width == showWidth
                        
                        onClicked: {
                            if (playlistPanel.width == showWidth) {
                                hidingPlaylistPanelAnimation.restart()
                            } else {
                                showingPlaylistPanelAnimation.restart()
                            }
                        }
                    }
                    
                    ToggleButton {
                        id: playerConfig
                        imageName: "image/player_config"
                        anchors.verticalCenter: parent.verticalCenter
                        visible: showBottomPanel ? 1 : 0
                        active: false
                    }
                }
                
                Row {
                    id: middleButtonArea
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 0
                    
                    ImageButton {
                        id: playerOpen
                        imageName: "image/player_open"
                        anchors.verticalCenter: playerPlay.verticalCenter
                        visible: showBottomPanel ? 1 : 0
                    }
                    
                    Space {
                        width: 46
                    }
                    
                    ImageButton {
                        id: playerBackward
                        imageName: "image/player_backward"
                        anchors.verticalCenter: playerPlay.verticalCenter
                        visible: showBottomPanel ? 1 : 0
                    }
                    
                    Space {
                        width: 28
                    }
                    
                    ImageButton {
                        id: playerPlay
                        imageName: video.playbackState == MediaPlayer.PlayingState ? "image/player_pause" : "image/player_play"
                        onClicked: {
                            toggle()
                        }
                        visible: showBottomPanel ? 1 : 0
                    }
                    
                    Space {
                        width: 28
                    }
                    
                    ImageButton {
                        id: playerForward
                        imageName: "image/player_forward"
                        anchors.verticalCenter: playerPlay.verticalCenter
                        visible: showBottomPanel ? 1 : 0
                    }
                    
                    Space {
                        width: 46
                    }
                    
                    VolumeButton {
                        id: playerVolume
                        anchors.verticalCenter: parent.verticalCenter
                        visible: showBottomPanel ? 1 : 0
                        
                        onInVolumebar: {
                            hidingTimer.stop()
                        }
                        
                        onChangeVolume: {
                            video.volume = playerVolume.volume
                            
                            notifybar.show("image/notify_volume.png", "音量: " + Math.round(video.volume * 100) + "%")
                        }
                        
                        onClickMute: {
                            video.muted = !playerVolume.active
                            
                            if (video.muted) {
                                notifybar.show("image/notify_volume.png", "静音")
                            } else {
                                notifybar.show("image/notify_volume.png", "音量: " + Math.round(video.volume * 100) + "%")
                            }
                        }
                        
                        Component.onCompleted: {
                            playerVolume.volume = video.volume
                        }
                    }
                }

                Row {
                    id: rightButtonArea
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 5
                    
                    Text {
                        id: playTime
                        anchors.verticalCenter: parent.verticalCenter
                        text: timeCurrent + " / " + timeTotal
                        color: Qt.rgba(100, 100, 100, 1)
                        font.pixelSize: 12
                        visible: showBottomPanel ? 1 : 0
                    }
                }
            }
        }
    }
    
    focus: true
    Keys.onSpacePressed: toggle()
    Keys.onLeftPressed: backward()
    Keys.onRightPressed: forward()
    Keys.onUpPressed: increaseVolume()
    Keys.onDownPressed: decreaseVolume()
    Keys.onEscapePressed: {
        if (windowView.getState() == Qt.WindowFullScreen) {
            video.toggleFullscreen()
        }
    }
    
    ParallelAnimation{
        id: showingBottomPanelAnimation
        alwaysRunToEnd: true
        
        PropertyAnimation {
            target: bottomPanel
            property: "height"
            to: showHeight
            duration: 100
            easing.type: Easing.OutQuint
        }

        onStarted: {
            video.bottomPanelShow()
        }
        
        onRunningChanged: {
            if (!showingBottomPanelAnimation.running) {
                showBottomPanel = true
            }
        }
    }    

    ParallelAnimation{
        id: hidingBottomPanelAnimation
        alwaysRunToEnd: true
        
        PropertyAnimation {
            target: bottomPanel
            property: "height"
            to: hideHeight
            duration: 100
            easing.type: Easing.OutQuint
        }
        
        onStarted: {
            video.bottomPanelHide()
        }
        
        onRunningChanged: {
            if (!showingBottomPanelAnimation.running) {
                showBottomPanel = false
            }
        }
    }    

    ParallelAnimation{
        id: showingPlaylistPanelAnimation
        alwaysRunToEnd: true
        
        PropertyAnimation {
            target: playlistPanel
            property: "width"
            to: showWidth
            duration: 100
            easing.type: Easing.OutQuint
        }
        
        onRunningChanged: {
            if (!showingPlaylistPanelAnimation.running) {
                hidingBottomPanelAnimation.restart()
            }
        }
    }    

    ParallelAnimation{
        id: hidingPlaylistPanelAnimation
        alwaysRunToEnd: true
        
        PropertyAnimation {
            target: playlistPanel
            property: "width"
            to: hideWidth
            duration: 100
            easing.type: Easing.OutQuint
        }
    }    
    
    SequentialAnimation {
        id: movePauseNotify
        
        ParallelAnimation {
            PropertyAnimation {
                target: pauseNotify
                property: "scale"
                to: 1
                duration: 100
                easing.type: Easing.OutQuint
            }
            
            PropertyAnimation {
                target: pauseNotify
                property: "opacity"
                to: 1
                duration: 100
                easing.type: Easing.OutQuint
            }
        }

        PauseAnimation { 
            duration: 500
        }
        
        ParallelAnimation {
            PropertyAnimation {
                target: pauseNotify
                property: "scale"
                to: 0.6
                duration: 650
                easing.type: Easing.OutQuint
            }
            
            PropertyAnimation {
                target: pauseNotify
                property: "opacity"
                to: 0
                duration: 650
                easing.type: Easing.OutQuint
            }
        }
    }
}
