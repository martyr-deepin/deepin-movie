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
    
    signal resizeDone ()
    
    function show() {
        root.visible = true
    }

    function hide() {
        root.resizeDone()
        root.visible = false
    }
    
    function intelligentlyResize(window, x, y) {
        _intelligentlyResize(window, x, y, resizeEdge)
    }
    
    function _intelligentlyResize(window, x, y, flag) {
        if (flag == resize_edge.resizeTop || 
            flag == resize_edge.resizeTopLeft ||
            flag == resize_edge.resizeTopRight) {
            frame.y = window.y + y
            frame.height = window.height - y
        }
        if (flag == resize_edge.resizeBottom || 
            flag == resize_edge.resizeBottomLeft ||
            flag == resize_edge.resizeBottomRight) {
            frame.height = y
        }
        if (flag == resize_edge.resizeLeft || 
            flag == resize_edge.resizeTopLeft ||
            flag == resize_edge.resizeBottomLeft) {
            frame.x = window.x + x
            frame.width = window.width - x
        }
        if (flag == resize_edge.resizeRight || 
            flag == resize_edge.resizeTopRight ||
            flag == resize_edge.resizeBottomRight) {
            frame.width = x
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
