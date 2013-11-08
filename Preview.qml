import QtQuick 2.1
import QtMultimedia 5.0
import QtGraphicalEffects 1.0

Rectangle {
    id: preview
    width: 150
    height: 100
    color: Qt.rgba(0, 0, 0, 0.0)
    property int triangleWidth: 20
    property int triangleHeight: 10
    property int previewPadding: 3
    
    property alias video: video
    property alias videoTime: videoTime
    property alias triangleArea: triangleArea
    property alias previewRectangle: previewRectangle
    
    signal positionChanged 
    
    Rectangle {
        id: previewRectangle
        anchors.fill: parent
        anchors.bottomMargin: triangleHeight
        color: Qt.rgba(0, 0, 0, 1)
        border.color: Qt.rgba(10, 10, 10, 0.5)
        radius: 3
        antialiasing: true
        
        Video {
            id: video
            autoPlay: true
            muted: true
            anchors.fill: parent
            anchors.topMargin: previewPadding
            anchors.leftMargin: previewPadding
            anchors.rightMargin: previewPadding
            anchors.bottomMargin: previewPadding
            
            onPositionChanged: {
                preview.positionChanged()
            }
            
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 20
                color: "#DD000000"
                
                Text {
                    id: videoTime
                    color: "white"                    
                    anchors.centerIn: parent
                }
            }
        }


    }
    
    Rectangle {
        id: previewTriangleArea
        anchors.fill: parent
        anchors.topMargin: parent.height - triangleHeight - 1
        color: Qt.rgba(0, 0, 0, 0)
        
        Canvas {
            id: triangleArea
            anchors.fill: parent
            antialiasing: true
            
            property int defaultOffsetX: (width - triangleWidth) / 2
            property int drawOffsetX: defaultOffsetX
            property int drawY: 0
            property int drawWidth: triangleWidth
            property int drawHeight: triangleHeight
            
            onDrawOffsetXChanged: requestPaint()
                
            onPaint: {
                var ctx = getContext("2d")

                ctx.clearRect(x, y, width, height)
                
                ctx.save()
                
                ctx.fillStyle = Qt.rgba(0, 0, 0, 1)
                
                
                ctx.beginPath()
                
                ctx.moveTo(x + drawOffsetX, y + drawY)
                ctx.lineTo(x + drawOffsetX + triangleWidth, y + drawY)
                ctx.lineTo(x + drawOffsetX + triangleWidth / 2, y + drawY + drawHeight)
                ctx.lineTo(x + drawOffsetX, y + drawY)
                
                ctx.closePath()
                ctx.fill()
                
                ctx.restore()
                
                ctx.save()

                ctx.lineWidth = 1
                ctx.strokeStyle = Qt.rgba(10, 10, 10, 0.7)
                
                ctx.beginPath()
                
                ctx.moveTo(x + drawOffsetX + triangleWidth / 2, y + drawY + drawHeight)
                ctx.lineTo(x + drawOffsetX, y + drawY)
                
                ctx.closePath()
                ctx.stroke()

                ctx.beginPath()
                
                ctx.moveTo(x + drawOffsetX + triangleWidth / 2, y + drawY + drawHeight)
                ctx.lineTo(x + drawOffsetX + triangleWidth, y + drawY)
                
                ctx.closePath()
                ctx.stroke()
                
                ctx.restore()
            }
        }
    }
}
