import QtQuick 2.1
import QtMultimedia 5.0
import QtGraphicalEffects 1.0
import Deepin.Widgets 1.0

DragableArea {
    id: control_bar
    // make sure the 15 pixels upon the controlbar hasn't the ability to play or pause the video
    height: program_constants.controlbarHeight + 15 
    
    property alias volume: volume_button.volume
    property alias percentage: progressbar.percentage
    property alias videoPlaying: play_pause_button.checkFlag
    property alias muted: volume_button.muted
    property alias widthHeightScale: videoPreview.widthHeightScale

    signal togglePlay ()
    signal mutedSet (bool muted)
    signal changeVolume (real volume)
    signal percentageSet(real percentage)
    signal configButtonClicked ()
    signal playStopButtonClicked ()
    signal openFileButtonClicked ()
    signal playlistButtonClicked ()
    signal previousButtonClicked ()
    signal nextButtonClicked ()

    Behavior on opacity {
        NumberAnimation { duration: 300 }
    }

    function show() {
        visible = true
    }

    function hide() {
        visible = false
    }

    function reset() {
        percentage = 0
        play_pause_button.checkFlag = false
    }

    function showPreview(mouseX, mode) {
        videoPreview.state = mode
        if (videoPreview.hasVideo && videoPreview.source != "") {
            videoPreview.visible = true
            videoPreview.x = Math.min(Math.max(mouseX - videoPreview.width / 2, 0),
                                      width - videoPreview.width)
            videoPreview.y = progressbar.y - videoPreview.height - 10

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
    }

    function flipPreviewHorizontal() { videoPreview.flipHorizontal() }
    function flipPreviewVertical() { videoPreview.flipVertical() }
    function rotatePreviewClockwise() { videoPreview.rotateClockwise() }
    function rotatePreviewAntilockwise() { videoPreview.rotateAnticlockwise() }

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
        width: parent.width
        height: program_constants.controlbarHeight
        anchors.bottom: parent.bottom

        ProgressBar {
            id: progressbar
            width: parent.width

            Preview {
                id: videoPreview
                source: movieInfo.movie_file
                visible: false
            }

            onMouseOver: { control_bar.showPreview(mouseX, "normal") }
            onMouseDrag: { control_bar.showPreview(mouseX, "minimal") }

            onMouseExit: {
                videoPreview.visible = false
            }

            onPercentageSet: {control_bar.percentageSet(percentage); print("percentageSet")}
        }

        Item {
            id: buttonArea
            state: { width < windowView.minimumWidth ? "minimal" : "normal"}
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 34

            states: [
                State {
                    name: "normal"
                    PropertyChanges {
                        target: leftButtonArea
                        visible: true
                    }
                    PropertyChanges {
                        target: middleButtonArea
                        anchors.centerIn: buttonArea
                        anchors.left: undefined
                        anchors.leftMargin: 0
                    }
                },
                State {
                    name: "minimal"
                    PropertyChanges {
                        target: leftButtonArea
                        visible: false
                    }
                    PropertyChanges {
                        target: middleButtonArea
                        anchors.centerIn: undefined
                        anchors.left: buttonArea.left
                        anchors.leftMargin: 27
                    }
                }
            ]

            Row {
                id: leftButtonArea
                anchors.left: parent.left
                anchors.leftMargin: 27
                anchors.verticalCenter: parent.verticalCenter
                spacing: 5

                Text {
                    id: playTime
                    visible: videoPreview.hasVideo && videoPreview.source != ""
                    anchors.verticalCenter: parent.verticalCenter
                    text: formatTime(control_bar.percentage * movieInfo.movie_duration) + " / " + formatTime(movieInfo.movie_duration)
                    color: Qt.rgba(100, 100, 100, 1)
                    font.pixelSize: 12
                }
            }

            Row {
                id: middleButtonArea
                anchors.centerIn: parent
                spacing: 0

                OpacityImageButton {
                    id: playerOpen
                    imageName: "image/player_stop.png"
                    anchors.verticalCenter: parent.verticalCenter

                    onClicked: control_bar.playStopButtonClicked()
                }

                Space {
                    width: 32
                }

                OpacityImageButton {
                    imageName: "image/player_previous_normal.png"
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: control_bar.previousButtonClicked()
                }

                Space {
                    width: 25
                }

                OpacityImageButton {
                    id: play_pause_button
                    imageName: checkFlag ? "image/player_pause_normal.png" : "image/player_play_normal.png"
                    property bool checkFlag: false

                    onClicked: {
                        checkFlag = !checkFlag
                        control_bar.togglePlay()
                    }
                }

                Space {
                    width: 25
                }

                OpacityImageButton {
                    imageName: "image/player_next_normal.png"
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: control_bar.nextButtonClicked()
                }

                Space {
                    width: 32
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
                anchors.rightMargin: 27
                anchors.verticalCenter: parent.verticalCenter
                spacing: 25

                OpacityImageButton {
                    id: open_file_button
                    imageName: "image/player_open.png"

                    onClicked: control_bar.openFileButtonClicked()
                }

                OpacityImageButton {
                    id: play_list_button

                    imageName: "image/player_list_normal.png"
                    anchors.verticalCenter: parent.verticalCenter

                    onClicked: {
                        control_bar.playlistButtonClicked()
                    }
                }

            /* ImageButton { */
            /*     id: playerConfig */
            /*     imageName: "image/player_config" */
            /*     anchors.verticalCenter: parent.verticalCenter */

            /*     onClicked: { */
            /*         control_bar.configButtonClicked() */
            /*     } */
            /* } */
            }
        }
    }

    Image {
        id: drag_point
        source: "image/dragbar.png"

        anchors.rightMargin: 5
        anchors.bottomMargin: 5
        anchors.right: parent.right
        anchors.bottom: parent.bottom
    }
}