import QtQuick 2.1
import QtMultimedia 5.0
import QtGraphicalEffects 1.0
import Deepin.Widgets 1.0

Item {
    id: control_bar
    height: program_constants.controlbarHeight

    property alias volume: volume_button.volume
    property alias percentage: progressbar.percentage
    
    signal togglePlay ()
    signal mutedSet (bool muted)
    signal changeVolume (real volume)
    signal percentageSet(real percentage)

    Behavior on opacity {
        NumberAnimation { duration: 300 }
    }

    function show() {
        if (videoPreview.hasVideo) {
            visible = true
        }
    }

    function hide() {
        visible = false
    }

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
        ProgressBar {
            id: progressbar
            width: parent.parent.width

            Preview {
                id: videoPreview
                source: movieInfo.movie_file
                visible: false
            }

            onMouseOver: {
                videoPreview.visible = true
                videoPreview.x = Math.min(Math.max(mouse.x - videoPreview.width / 2, 0),
                                          width - videoPreview.width)
                videoPreview.y = y - videoPreview.height

                var mouseX = mouse.x
                var mouseY = mouse.y

                if (mouseX <= videoPreview.cornerWidth / 2) {
                    videoPreview.cornerPos = mouseX + videoPreview.cornerWidth / 2
                    videoPreview.cornerType = "left"
                } else if (mouseX >= width - videoPreview.cornerWidth / 2) {
                    videoPreview.cornerPos = mouseX - width + videoPreview.width - videoPreview.cornerWidth / 2
                    videoPreview.cornerType = "right"
                } else if (mouseX < videoPreview.width / 2) {
                    videoPreview.cornerPos = mouseX
                    videoPreview.cornerType = "center"
                } else if (mouseX >= width - videoPreview.width / 2) {
                    videoPreview.cornerPos = mouseX - width + videoPreview.width
                    videoPreview.cornerType = "center"
                } else {
                    videoPreview.cornerPos = videoPreview.width / 2
                    videoPreview.cornerType = "center"
                }
                videoPreview.seek(mouseX / width)
            }

            onMouseExit: {
                videoPreview.visible = false
            }

            onPercentageSet: {control_bar.percentageSet(percentage); print("percentageSet")}
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
                spacing: 5

                Text {
                    id: playTime
                    anchors.verticalCenter: parent.verticalCenter
                    text: formatTime(control_bar.percentage * movieInfo.movie_duration) + " / " + formatTime(movieInfo.movie_duration)
                    color: Qt.rgba(100, 100, 100, 1)
                    font.pixelSize: 12
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

                DImageCheckButton {
                    id: playerPlay
                    activatedNomralImage: "image/player_play_normal.png"
                    activatedHoverImage: "image/player_play_hover.png"
                    activatedPressImage: "image/player_play_press.png"

                    inactivatedNomralImage: "image/player_pause_normal.png"
                    inactivatedHoverImage: "image/player_pause_hover.png"
                    inactivatedPressImage: "image/player_pause_press.png"

                    onClicked: {
                        control_bar.togglePlay()
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
                    id: volume_button
                    anchors.verticalCenter: parent.verticalCenter

                    onChangeVolume: {
                        control_bar.changeVolume(volume)
                    }

                    onMutedSet: {
                        control_bar.mutedSet(muted)
                    }
                }
            }

            Row {
                id: rightButtonArea
                anchors.right: parent.right
                anchors.rightMargin: 10
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
        }
    }
}