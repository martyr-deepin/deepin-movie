import QtQuick 2.1
import QtMultimedia 5.0
import QtGraphicalEffects 1.0

RectWithCorner {
    id: preview
    rectWidth: 178
    rectHeight: (rectWidth - padding * 2) * movie_info["video_height"] / movie_info["video_width"] + padding * 2 + preview.cornerHeight - previewPadding * 2
    cornerPos: 89
    withBlur: false
    blurWidth: 2

    property alias video: video
    property alias videoTime: videoTime
    
    property int previewPadding: 4
    
    signal positionChanged
    
    Video {
        id: video
        autoPlay: true
        muted: true
        anchors.fill: parent
        anchors.topMargin: previewPadding
        anchors.bottomMargin: previewPadding + preview.cornerHeight
        anchors.leftMargin: previewPadding
        anchors.rightMargin: previewPadding
        
        onPositionChanged: {
            preview.positionChanged()
        }
        
    }
    
    Rectangle {
        anchors.bottom: video.bottom
        anchors.left: video.left
        anchors.right: video.right
        height: 24
        color: "#DD000000"
        
        Text {
            id: videoTime
            color: "white"
            anchors.centerIn: parent
        }
    }
}
