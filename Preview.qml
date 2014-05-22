import QtQuick 2.1
import QtMultimedia 5.0
import QtGraphicalEffects 1.0

RectWithCorner {
    id: preview
    state: "normal"
    cornerPos: 89
    withBlur: false
    blurWidth: 2

    states: [
        State {
            name: "normal"
            PropertyChanges { target: preview; rectWidth: 178; rectHeight: (rectWidth - previewPadding * 2) * movieInfo.movie_height / movieInfo.movie_width + previewPadding * 2 + preview.cornerHeight }
            PropertyChanges { target: video; visible: true }
            PropertyChanges { target: time_bg; color: "#DD000000" }
        },
        State {
            name: "minimal"
            PropertyChanges { target: preview; rectWidth: 100; rectHeight: 44 }
            PropertyChanges { target: video; visible: false }
            PropertyChanges { target: time_bg; color: "transparent" }
        }        
    ]

    property alias source: video.source
    property alias hasVideo: video.hasVideo
    
    property int previewPadding: 4
    
    function seek(percentage) {
        video.seek(Math.floor(movieInfo.movie_duration * percentage))
        videoTime.text = formatTime(movieInfo.movie_duration * percentage)
    }
    
    Video {
        id: video
        autoPlay: true
        muted: true
        
        anchors.fill: parent
        anchors.topMargin: previewPadding
        anchors.bottomMargin: previewPadding + preview.cornerHeight
        anchors.leftMargin: previewPadding
        anchors.rightMargin: previewPadding
        
        onPlaying: pause()
    }
    
    Rectangle {
        id: time_bg
        height: 24
        anchors.bottom: video.bottom
        anchors.left: video.left
        anchors.right: video.right
        
        Text {
            id: videoTime
            color: "white"
            anchors.centerIn: parent
        }
    }
}
