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
    property double triggerButtonWidth: 20
    property double triggerButtonHeight: 62
    property bool inTriggerButton: false
    
    property double triggerTopPanelHeight: 50
    property double triggerBottomPanelHeight: 50
    property double triggerPlaylistProtectedWidth: 50
    
    property alias videoPreview: videoPreview
    property alias videoArea: videoArea
    property alias hidingBottomPanelAnimation: hidingBottomPanelAnimation
    property alias playlistPanelArea: playlistPanelArea
    property alias notifybar: notifybar
    
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
    
    InteractiveArea {
        id: videoArea
        anchors.fill: parent
        hoverEnabled: true
        
        property real windowViewX: 0
        property real windowViewY: 0

        property real lastMouseX: 0
        property real lastMouseY: 0

        property bool isHover: false
        property bool isDoubleClick: false

        property int maskHeight: 30
        
        onPressed: {
            isHover = false
            isDoubleClick = false
            
            lastMouseX = mouseX
            lastMouseY = mouseY
        }
        
        onClicked: {
            if (!isHover) {
                clickTimer.restart()
            }
        }
        
        onDoubleClicked: {
            isDoubleClick = true
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

            isHover = true
            video.showCursor()
            
            if (pressedButtons == Qt.LeftButton) {
                windowView.x += mouseX - lastMouseX
                windowView.y += mouseY - lastMouseY
            }
        }

        onExited: {
            video.showCursor()
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
            }
        }
        
        Timer {
            id: clickTimer
            interval: 200
            repeat: false
            onTriggered: {
                if (!videoArea.isDoubleClick) {
                    toggle()
                }
            }
        }
    }

    Rectangle {
        id: playlistPanel
        color: "#1D1D1D"
        height: video.height
        width: hideWidth
        opacity: 1
        
        MouseArea {
            id: playlistPanelArea
            anchors.fill: parent
            hoverEnabled: true
            
            property real lastMouseX: 0
            property real lastMouseY: 0
            
            onPressed: {
                lastMouseX = mouseX
                lastMouseY = mouseY
            }
            
            onClicked: {
                console.log("Click on playlist.")
            }
            
            onPositionChanged: {
                if (pressedButtons == Qt.LeftButton) {
                    windowView.x += mouseX - lastMouseX
                    windowView.y += mouseY - lastMouseY
                }
            }
        }
        
        Image {
            id: hidePlaylistButton
            source: "image/playlist_button_background.png"
            anchors.left: playlistPanel.right
            anchors.verticalCenter: playlistPanel.verticalCenter
            visible: playlistPanel.width == showWidth
            
            Image {
                source: "image/playlist_button_arrow.png"
                anchors.right: parent.right
                anchors.rightMargin: 7
                anchors.verticalCenter: parent.verticalCenter
            }
            
            MouseArea {
                id: hidePlaylistButtonArea
                anchors.fill: parent
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
    }
    
    Rectangle {
        id: bottomPanel
        /* color: Qt.rgba(0, 0, 0, 0.95) */
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
                    
        InteractiveArea {
            id: bottomPanelArea
            anchors.fill: parent
            hoverEnabled: true
            property real lastMouseX: 0
            property real lastMouseY: 0
            
            onPressed: {
                lastMouseX = mouseX
                lastMouseY = mouseY
            }
            
            onPositionChanged: {
                hidingTimer.stop()
                
                if (pressedButtons == Qt.LeftButton) {
                    windowView.x += mouseX - lastMouseX
                    windowView.y += mouseY - lastMouseY
                }
            }
            
            onExited: {
                hidingTimer.restart()
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
                    
                    InteractiveArea {
                        id: progressbarArea
                        anchors.fill: parent
                        hoverEnabled: true
                        
                        onClicked: {
                            video.seek(video.duration * mouseX / (progressbarBackground.width - progressbarBackground.x))
                        }
                        
                        onPositionChanged: {
                            hidingTimer.stop()
                            
                            videoPreview.visible = true
                            videoPreview.x = Math.max(Math.min(mouseX - videoPreview.width / 2, progressbarArea.width - videoPreview.width), 0)
                            videoPreview.y = progressbarArea.y - videoPreview.height
                            
                            videoPosition = video.duration * mouseX / (progressbarBackground.width - progressbarBackground.x)
                            
                            videoPreview.video.visible = false
                            updatePreviewTimer.restart()
                            
                            videoPreview.videoTime.text = formatTime(videoPosition)
                            
                            var minOffsetX = 10
                            
                            if (mouseX < videoPreview.width / 2) {
                                videoPreview.triangleArea.drawOffsetX = Math.max(mouseX, minOffsetX)
                            } else if (mouseX > progressbarArea.width - videoPreview.width / 2) {
                                var offsetX = Math.min(mouseX - (progressbarArea.width - videoPreview.width / 2),
                                                      videoPreview.triangleArea.width / 2 - minOffsetX * 2)
                                videoPreview.triangleArea.drawOffsetX = videoPreview.triangleArea.defaultOffsetX + offsetX
                            } else {
                                videoPreview.triangleArea.drawOffsetX = videoPreview.triangleArea.defaultOffsetX
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
                    }
                    
                    Preview {
                        id: videoPreview
                        visible: false
                        
                        onPositionChanged: {
                            videoPreview.video.visible = true
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
                        x: timePosition * parent.width - width / 2
                        y: progressbarForeground.y + (progressbarForeground.height - height) / 2
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
    
    Notifybar {
        id: notifybar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 20 + titlebar.height
        anchors.leftMargin: 20
    }

    ParallelAnimation{
        id: showingBottomPanelAnimation
        alwaysRunToEnd: true
        
        PropertyAnimation {
            target: bottomPanel
            property: "height"
            to: showHeight
            duration: 100
            easing.type: Easing.OutBack
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
            easing.type: Easing.OutBack
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
            easing.type: Easing.OutBack
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
            easing.type: Easing.OutBack
        }
    }    
}
