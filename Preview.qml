import QtQuick 2.1
import QtMultimedia 5.0
import QtGraphicalEffects 1.0

RectWithCorner {
    id: preview
    rectWidth: 178
    rectHeight: 128
    cornerPos: 89

    property alias video: video
    property alias videoTime: videoTime
    
    property int previewPadding: 15
    
    signal positionChanged
    
    Video {
        id: video
        autoPlay: true
        muted: true
        anchors.fill: parent
        anchors.topMargin: previewPadding
        anchors.leftMargin: previewPadding
        anchors.rightMargin: previewPadding
        anchors.bottomMargin: previewPadding + preview.cornerHeight
        
        onPositionChanged: {
            preview.positionChanged()
        }
        
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 24
            color: "#DD000000"
            
            Text {
                id: videoTime
                color: "white"
                anchors.centerIn: parent
            }
        }
    }
}
