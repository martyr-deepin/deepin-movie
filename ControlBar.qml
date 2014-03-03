import QtQuick 2.1
import QtMultimedia 5.0
import QtGraphicalEffects 1.0

Item {
    height: program_constants.controlbarHeight

    LinearGradient {
        id: bottomPanelBackround
        
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 100
        start: Qt.point(0, 0)
        end: Qt.point(0, height)
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#00000000"}
            GradientStop { position: 1.0; color: "#FF000000"}
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
                color: "#444a4a4a"

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: 1
                    color: "#443c3c3c"
                }

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
                        videoPreview.x = Math.min(Math.max(mouseX - videoPreview.width / 2, 0),
                                                  progressbarArea.width - videoPreview.width)
                        videoPreview.y = progressbarArea.y - videoPreview.height + progressbarArea.height / 2
                        videoPosition = video.duration * mouseX / (progressbarBackground.width - progressbarBackground.x)

                        videoPreview.video.visible = false
                        updatePreviewTimer.restart()

                        videoPreview.videoTime.text = formatTime(videoPosition)

                        if (mouseX <= videoPreview.cornerWidth / 2) {
                            videoPreview.cornerPos = mouseX + videoPreview.cornerWidth / 2
                            videoPreview.cornerType = "left"
                        } else if (mouseX >= progressbarArea.width - videoPreview.cornerWidth / 2) {
                            videoPreview.cornerPos = mouseX - progressbarArea.width + videoPreview.width - videoPreview.cornerWidth / 2
                            videoPreview.cornerType = "right"
                        } else if (mouseX < videoPreview.width / 2) {
                            videoPreview.cornerPos = mouseX
                            videoPreview.cornerType = "center"
                        } else if (mouseX >= progressbarArea.width - videoPreview.width / 2) {
                            videoPreview.cornerPos = mouseX - progressbarArea.width + videoPreview.width
                            videoPreview.cornerType = "center"
                        } else {
                            videoPreview.cornerPos = videoPreview.width / 2
                            videoPreview.cornerType = "center"
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

                Rectangle {
                    id: progressbarForeground
                    anchors.left: parent.left
                    anchors.top: parent.top
                    height: parent.height
                    /* width: timePosition * parent.width */
                    color: "#007cc2"

                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        height: 1
                        color: "#04a4ff"
                    }
                }

                Image {
                    source: "image/progress_pointer.png"
                    /* x: Math.min(Math.max(timePosition * parent.width - width / 2, 0), parent.width - width) */
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
                    /* active: playlistPanel.width == showWidth */
                }

                ToggleButton {
                    id: playerConfig
                    imageName: "image/player_config"
                    anchors.verticalCenter: parent.verticalCenter
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
                }

                Space {
                    width: 46
                }

                ImageButton {
                    id: playerBackward
                    imageName: "image/player_backward"
                    anchors.verticalCenter: playerPlay.verticalCenter
                }

                Space {
                    width: 28
                }

                ImageButton {
                    id: playerPlay
                    imageName: player.playbackState == MediaPlayer.PlayingState ? "image/player_pause" : "image/player_play"
                    onClicked: {
                        toggle()
                    }
                }

                Space {
                    width: 28
                }

                ImageButton {
                    id: playerForward
                    imageName: "image/player_forward"
                    anchors.verticalCenter: playerPlay.verticalCenter
                }

                Space {
                    width: 46
                }

                VolumeButton {
                    id: playerVolume
                    anchors.verticalCenter: parent.verticalCenter

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
                            notifybar.show("image/notify_volume.png", "音量: " + Math.round(player.volume * 100) + "%")
                        }
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
                    /* text: timeCurrent + " / " + timeTotal */
                    color: Qt.rgba(100, 100, 100, 1)
                    font.pixelSize: 12
                }
            }
        }
    }
}