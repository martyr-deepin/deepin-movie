import QtQuick 2.1
import QtAV 1.5
import QtGraphicalEffects 1.0
import "sources/ui_utils.js" as UIUtils

RectWithCorner {
    id: preview
    state: "normal"
    cornerPos: 89
    withBlur: false
    blurWidth: 2

    property alias source: video_preview.file
    property real widthHeightScale
    property int previewPadding: 4

    states: [
        State {
            name: "normal"
            PropertyChanges {
                target: preview
                rectWidth: widthHeightScale >= 1 ? 178 : 89
                rectHeight: (rectWidth - previewPadding * 2) / widthHeightScale + previewPadding * 2 + preview.cornerHeight
            }
            PropertyChanges { target: video_preview; visible: true }
            PropertyChanges { target: time_bg; color: "#DD000000" }
        },
        State {
            name: "minimal"
            PropertyChanges { target: preview; rectWidth: 100; rectHeight: 44 }
            PropertyChanges { target: video_preview; visible: false }
            PropertyChanges { target: time_bg; color: "transparent" }
        }
    ]

    function seek(percentage) {
        video_preview.timestamp = Math.floor(player.duration * percentage)
        videoTime.text = UIUtils.formatTime(player.duration * percentage)
    }

    function flipHorizontal() {
        if (flip.axis.y == 1) {
            flip.axis.y = 0
        } else {
            if (flip.axis.x == 1) {
                flip.axis.x = 0
                video_preview.orientation -= 180
            } else {
                flip.axis.y = 1
            }
        }
    }

    function flipVertical() {
        if (flip.axis.x == 1) {
            flip.axis.x = 0
        } else {
            if (flip.axis.y == 1) {
                flip.axis.y = 0
                video_preview.orientation -= 180
            } else {
                flip.axis.x = 1
            }
        }
    }

    function rotateClockwise() {
        video_preview.orientation -= 90
    }

    function rotateAnticlockwise() {
        video_preview.orientation += 90
    }

    function resetRotationFlip() {
        video_preview.orientation = 0
        flip.axis.x = 0
        flip.axis.y = 0
        flip.axis.z = 0
        flip.angle = 180
    }

    VideoPreview {
        id: video_preview

        anchors.fill: parent
        anchors.topMargin: previewPadding
        anchors.bottomMargin: previewPadding + preview.cornerHeight
        anchors.leftMargin: previewPadding
        anchors.rightMargin: previewPadding
    }

    Rotation {
        id: flip
        origin.x: width / 2
        origin.y: height / 2
        axis.x: 0
        axis.y: 0
        axis.z: 0
        angle: 180
    }

    Rectangle {
        id: time_bg
        height: 24
        anchors.bottom: video_preview.bottom
        anchors.left: video_preview.left
        anchors.right: video_preview.right

        Text {
            id: videoTime
            color: "white"
            anchors.centerIn: parent
        }
    }
}
