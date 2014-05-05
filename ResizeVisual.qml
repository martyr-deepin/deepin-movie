import QtQuick 2.1
import QtQuick.Window 2.1
import QtGraphicalEffects 1.0

Window {
    id: root
    width: Screen.width
    height: Screen.height
    color: "transparent"
    visible: false
    flags: Qt.Popup | Qt.FramelessWindowHint
    
    property alias frameX: frame.x
    property alias frameY: frame.y
    property alias frameWidth: frame.width
    property alias frameHeight: frame.height
    property int resizeEdge
    
    function show() {
        root.visible = true
    }

    function hide() {
        root.visible = false
    }
    
    function intelligentlyResize(window, x, y) {
        _intelligentlyResize(window, x, y, resizeEdge)
    }
    
    function _intelligentlyResize(window, x, y, flag) {
        if (flag == resize_edge.resizeTop) {
            frame.y = window.y + y
            frame.height = window.height - y
        } else if (flag == resize_edge.resizeBottom) {
            frame.height = y
        } else if (flag == resize_edge.resizeLeft) {
            frame.x = window.x + x
            frame.width = window.width - x
        } else if (flag == resize_edge.resizeRight) {
            frame.width = x
        } else if (flag == resize_edge.resizeTopLeft) {
            var widthHeightScale = window.width / window.height
            var deltaX = -x
            var deltaY = deltaX / widthHeightScale

            frame.x = window.x - deltaX
            frame.y = window.y - deltaY
            frame.width = window.width + deltaX
            frame.height = window.height + deltaY
        } else if (flag == resize_edge.resizeTopRight) {
            var widthHeightScale = window.width / window.height
            var deltaX = x - window.width
            var deltaY = deltaX / widthHeightScale
            
            frame.y = window.y - deltaY
            frame.width = window.width + deltaX
            frame.height = window.height + deltaY
        } else if (flag == resize_edge.resizeBottomLeft) {
            var widthHeightScale = window.width / window.height
            var deltaX = -x
            var deltaY = deltaX / widthHeightScale
            
            frame.x = window.x - deltaX
            frame.width = window.width + deltaX
            frame.height = window.height + deltaY
        } else if (flag == resize_edge.resizeBottomRight) {
            var widthHeightScale = window.width / window.height
            var deltaX = x - window.width
            var deltaY = deltaX / widthHeightScale
            
            frame.width = window.width + deltaX
            frame.height = window.height + deltaY
        }
    }

    Rectangle {
        id: frame
        color: "transparent"
        radius: 3
        border.color: "#AAAEC1D5"
        border.width: 2
    }
}
