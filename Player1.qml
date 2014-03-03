import QtQuick 2.1
import QtMultimedia 5.0

Item {
    property alias source: video.source
    
    Video {
        id: video
        autoPlay: true
        anchors.fill: parent
    }
}
