import QtQuick 2.1
import QtGraphicalEffects 1.0

Item {
	id: container
	property variant target
	width: target.width; height: target.height
    
	property int radius: 0
	
	Canvas {
		id: mask
		anchors.fill: container
		antialiasing: true
		smooth: true
        
        onWidthChanged: requestPaint()        
        onHeightChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d")

            ctx.save()
            ctx.clearRect(0, 0, mask.width, mask.height)

            ctx.beginPath();
            
            var x = 0
            var y = 0
            var w = width
            var h = height
            
            ctx.moveTo(x + radius, y)
            ctx.lineTo(x + w - radius, y)
            ctx.arcTo(x + w, y, x + w, y + radius, radius)
            ctx.lineTo(x + w, y + h)
            ctx.lineTo(x, y + h)
            ctx.lineTo(x, y + radius)
            ctx.arcTo(x, y, x + radius, y, radius)
            
            ctx.closePath();

            ctx.lineWidth = 1
            ctx.fill()

            ctx.restore()
        }
	}
	
    OpacityMask {
        anchors.fill: parent
        source: ShaderEffectSource { sourceItem: target; hideSource: true }
        maskSource: ShaderEffectSource{ sourceItem: mask; hideSource: true }
    }
}
	
