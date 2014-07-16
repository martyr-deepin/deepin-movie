import QtQuick 2.0

Canvas {
    id: canvas
    width: content_box.childrenRect.width + contentLeftMargin + contentRightMargin
    height: content_box.childrenRect.height + contentTopMargin + contentBottomMargin + arrowHeight
    antialiasing: true

    // need init
    property int radius: 4
    property int lineWidth: 0
    property real alpha: 1.0
    property int shadowWidth: 0
    property real arrowPosition: 0.9
    property int arrowWidth: 11
    property int arrowHeight: 6

    property bool fill: true
    property color fillStyle: "#b4b4b4"

    property bool stroke: true
    property color strokeStyle: "black"
    // need init

    property int contentTopMargin: 0
    property int contentBottomMargin: 0
    property int contentLeftMargin: 0
    property int contentRightMargin: 0

    default property alias content: content_box.children

    onArrowPositionChanged:requestPaint();
    onFillChanged:requestPaint();
    onStrokeChanged:requestPaint();
    onRadiusChanged:requestPaint();

    onPaint: {
        var ctx = getContext("2d");
        var rectx = 1
        var recty = arrowHeight + 1
        var rectWidth = width - 2
        var rectHeight = height - arrowHeight - 2

        ctx.save();
        ctx.clearRect(0,0,canvas.width, canvas.height);
        ctx.strokeStyle = canvas.strokeStyle;
        ctx.lineWidth = canvas.lineWidth
        ctx.fillStyle = canvas.fillStyle
        ctx.globalAlpha = canvas.alpha
        ctx.beginPath();
        ctx.moveTo(rectx+radius,recty);                 // top side
        //draw top arrow
        ctx.lineTo(rectx+arrowPosition*rectWidth-arrowWidth/2, recty);
        ctx.lineTo(rectx+arrowPosition*rectWidth, recty-arrowHeight);
        ctx.lineTo(rectx+arrowPosition*rectWidth+arrowWidth/2, recty);

        ctx.lineTo(rectx+rectWidth-radius,recty);
        // draw top right corner
        ctx.arcTo(rectx+rectWidth,recty,rectx+rectWidth,recty+radius,radius);
        ctx.lineTo(rectx+rectWidth,recty+rectHeight-radius);    // right side
        // draw bottom right corner
        ctx.arcTo(rectx+rectWidth,recty+rectHeight,rectx+rectWidth-radius,recty+rectHeight,radius);
        ctx.lineTo(rectx+radius,recty+rectHeight);              // bottom side
        // draw bottom left corner
        ctx.arcTo(rectx,recty+rectHeight,rectx,recty+rectHeight-radius,radius);
        ctx.lineTo(rectx,recty+radius);                 // left side
        // draw top left corner
        ctx.arcTo(rectx,recty,rectx+radius,recty,radius);
        ctx.closePath();
        if (canvas.fill)
            ctx.fill();
        if (canvas.stroke)
            ctx.stroke();
        ctx.restore();
    }

    Item {
        id: content_box
        anchors.fill: parent
        anchors.topMargin: parent.arrowHeight + parent.contentTopMargin
        anchors.bottomMargin: parent.contentBottomMargin
        anchors.leftMargin: parent.contentLeftMargin
        anchors.rightMargin: parent.contentRightMargin
    }
}
