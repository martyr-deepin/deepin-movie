import QtQuick 2.1
import QtMultimedia 5.0
import QtGraphicalEffects 1.0

RectWithCorner {
    id: preview
    rectWidth: 178
    rectHeight: rectWidth * movieInfo.movie_height / movieInfo.movie_width + preview.cornerHeight - previewPadding * 2
    cornerPos: 89
    withBlur: false
    blurWidth: 2

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
        height: 24
        color: "#DD000000"
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
