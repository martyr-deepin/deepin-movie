import QtQuick 2.1
import QtAV 1.5

Video {
    id: video
    autoPlay: true
    transform: flip
    timeout: 5 * 1000
    abortOnTimeout: false
    visible: playbackState != MediaPlayer.StoppedState

    subtitle.enabled: false
    // videoCodecPriority: ["VAAPI", "FFmpeg"]

    property string sourceString: ""
    property size resolution: _getResolution()
    property bool hasMedia: hasVideo || hasAudio
    property string title: metaData.title ? metaData.title : ""

    property alias subtitleContent: subtitle.text
    property alias subtitleFontSize: subtitle.fontSize
    property alias subtitleFontColor: subtitle.fontColor
    property alias subtitleFontFamily: subtitle.fontFamily
    property alias subtitleFontBorderSize: subtitle.fontBorderSize
    property alias subtitleFontBorderColor: subtitle.fontBorderColor
    property alias subtitleShow: subtitle.visible
    property real subtitleVerticalPosition: 0.2

    property bool isPreview: false

    function reset() {
        source = ""
        sourceString = ""
        resetRotationFlip()
    }

    function flipHorizontal() {
        if (flip.axis.y == 1) {
            flip.axis.y = 0
        } else {
            if (flip.axis.x == 1) {
                flip.axis.x = 0
                video.orientation -= 180
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
                video.orientation -= 180
            } else {
                flip.axis.x = 1
            }
        }
    }

    function _getResolution() {
        if (source.toString() && metaData["resolution"]) {
            return Qt.size(metaData["resolution"].width,
                metaData["resolution"].height)
        } else {
            return Qt.size(windowView.width - windowView.windowGlowRadius * 2,
                windowView.height - windowView.windowGlowRadius * 2)
        }
    }

    function _rotateResolution() {
        resolution = Qt.size(resolution.height, resolution.width)
    }
    function rotateClockwise() {
        video.orientation -= 90
        _rotateResolution()
    }
    function rotateAnticlockwise() {
        video.orientation += 90
        _rotateResolution()
    }

    function resetRotationFlip() {
        resolution = Qt.binding(_getResolution)

        video.orientation = 0
        flip.axis.x = 0
        flip.axis.y = 0
        flip.axis.z = 0
        flip.angle = 180
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

    DSubtitle {
        id: subtitle

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        anchors.bottomMargin: parent.subtitleVerticalPosition * (parent.height - subtitle.height - 30)
    }
}
