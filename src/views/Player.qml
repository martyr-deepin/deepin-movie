import QtQuick 2.1
import QtAV 1.6
import QtGraphicalEffects 1.0

Video {
    id: video
    autoPlay: true
    transform: flip
    timeout: 5 * 1000
    abortOnTimeout: false
    visible: playbackState != MediaPlayer.StoppedState

    subtitle.autoLoad: false
    subtitleText.z: glow.z + 1
    subtitleText.style: Text.Normal
    subtitleText.font.bold: false
    subtitleText.anchors.leftMargin: 20
    subtitleText.anchors.rightMargin: 20
    subtitleText.anchors.bottomMargin: subtitleVerticalPosition * height + 30
    videoCodecPriority: ["VDPAU", "VAAPI", "FFmpeg"]

    property string sourceString: ""
    property size resolution: _getResolution()
    property int storageSize: metaData["size"] || 0
    property bool hasMedia: hasVideo || hasAudio
    property string title: metaData.title ? metaData.title : ""

    property int subtitleFontSize
    property color subtitleFontColor
    property string subtitleFontFamily
    property alias subtitleFontBorderSize: glow.radius
    property alias subtitleFontBorderColor: glow.color
    property bool subtitleShow: true
    property real subtitleVerticalPosition: 0.2

    subtitle.enabled: subtitleShow
    subtitleText.font.pixelSize: subtitleFontSize
    subtitleText.color: subtitleFontColor
    subtitleText.font.family: subtitleFontFamily

    property bool verticallyFlipped: flip.axis.x == 1
    property bool horizontallyFlipped: flip.axis.y == 1
    property var externalAudioTracksRecord: []

    property int __reopenPosition: 0

    onSourceChanged: {
        __reopenPosition = 0

        externalAudio = ""
        externalAudioTracksRecord = []
    }

    onExternalAudioTracksChanged: {
        for (var i = 0; i < externalAudioTracks.length; i++) {
            var target = externalAudioTracks[i]
            var equalFlag = false

            for (var j = 0; j < externalAudioTracksRecord.length; j++) {
                var compareTo = externalAudioTracksRecord[j]
                if (target.id == compareTo.id
                    && target.file == compareTo.file) {
                    equalFlag = true
                    break
                }
            }

            if (!equalFlag) {
                externalAudioTracksRecord.push(target)
            }
        }
    }

    Timer {
        id: reopen_seek_timer
        interval: 500
        onTriggered: seek(__reopenPosition)
    }

    function reset() {
        source = ""
        sourceString = ""
        subtitle.file = ""
        resetRotationFlip()
    }

    function _reopen() {
        __reopenPosition = position
        player.stop()
        player.play()
        reopen_seek_timer.start()
    }

    function enabledHardwareAcceleration() {
        player.videoCodecPriority = ["VAAPI", "VDPAU", "FFmpeg"]
        player._reopen()
    }

    function disableHardwareAcceleration() {
        player.videoCodecPriority = ["FFmpeg"]
        player._reopen()
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

    Glow {
        id: glow
        anchors.fill: subtitleText
        spread: 1
        samples: 16
        source: subtitleText
        visible: radius != 0 && video.subtitleShow
    }
}
