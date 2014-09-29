import QtQuick 2.1
import QtQuick.Window 2.1

Window {
    id: toolTip
    width: tipText.contentWidth + horizontalMargin * 2
    height: tipText.height + verticalMargin * 2
    flags: Qt.Popup | Qt.WindowStaysOnTopHint
    color: Qt.rgba(0, 0, 0, 0)

    property var window
    property var screenSize

    property int maxWidth: 350
    property int horizontalMargin: 5
    property int verticalMargin: 5

    function showTip(s){
        tipText.text = s

        var cursorPosition = tooltip.window.getCursorPos()
        var screenSize = tooltip.screenSize
        toolTip.x = cursorPosition.x + 10
        toolTip.y = cursorPosition.y + 10
        if (toolTip.x + toolTip.width > screenSize.width){
            toolTip.x = screenSize.width - toolTip.width
        }

        toolTip.show()
        toolTip.visible = true
        toolTip.raise()
        timeoutHide.restart()
    }

    function hideTip(){
        toolTip.hide()
        toolTip.visible = false
    }

    Timer {
        id: timeoutHide
        interval: 3000

        onTriggered: toolTip.hideTip()
    }

    Rectangle {
        id: background
        width: parent.width
        height: parent.height
        color: Qt.rgba(0, 0, 0, 0.9)
        radius: 4

        Text {
            id: tipText
            x: toolTip.horizontalMargin
            width: toolTip.maxWidth
            height: contentHeight
            font.pixelSize: 12
            color: Qt.rgba(1, 1, 1, 0.7)
            wrapMode: Text.WrapAnywhere
            lineHeightMode: Text.FixedHeight
            lineHeight: 18

            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
