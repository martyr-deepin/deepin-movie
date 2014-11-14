import QtQuick 2.1
import QtQuick.Window 2.1
import QtGraphicalEffects 1.0

Window {
    id: root
    width: Screen.width
    height: Screen.height
    color: "transparent"
    visible: false
    flags: Qt.X11BypassWindowManagerHint

    property alias frameX: frame.x
    property alias frameY: frame.y
    property alias frameWidth: frame.width
    property alias frameHeight: frame.height
    property int resizeEdge
    property real widthHeightScale

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
            var deltaY = -y
            var deltaX = deltaY * widthHeightScale

            if (windowView.width + deltaX >= windowView.minimumWidth &&
                windowView.height + deltaY >= windowView.minimumHeight) {
                frame.y = window.y - deltaY
                frame.width = window.width + deltaX
                frame.height = window.height + deltaY
            }
        } else if (flag == resize_edge.resizeBottom) {
            var deltaY = y - windowView.height
            var deltaX = deltaY * widthHeightScale

            if (windowView.width + deltaX >= windowView.minimumWidth &&
                windowView.height + deltaY >= windowView.minimumHeight) {
                frame.width = window.width + deltaX
                frame.height = window.height + deltaY
            }
        } else if (flag == resize_edge.resizeLeft) {
            var deltaX = -x
            var deltaY = deltaX / widthHeightScale

            if (windowView.width + deltaX >= windowView.minimumWidth &&
                windowView.height + deltaY >= windowView.minimumHeight) {
                frame.x = window.x - deltaX
                frame.width = window.width + deltaX
                frame.height = window.height + deltaY
            }
        } else if (flag == resize_edge.resizeRight) {
            var deltaX = x - window.width
            var deltaY = deltaX / widthHeightScale

            if (windowView.width + deltaX >= windowView.minimumWidth &&
                windowView.height + deltaY >= windowView.minimumHeight) {
                frame.width = window.width + deltaX
                frame.height = window.height + deltaY
            }
        } else if (flag == resize_edge.resizeTopLeft) {
            var deltaX = -x
            var deltaY = deltaX / widthHeightScale

            if (windowView.width + deltaX >= windowView.minimumWidth &&
                windowView.height + deltaY >= windowView.minimumHeight) {
                frame.x = window.x - deltaX
                frame.y = window.y - deltaY
                frame.width = window.width + deltaX
                frame.height = window.height + deltaY
            }
        } else if (flag == resize_edge.resizeTopRight) {
            var deltaX = x - window.width
            var deltaY = deltaX / widthHeightScale

            if (windowView.width + deltaX >= windowView.minimumWidth &&
                windowView.height + deltaY >= windowView.minimumHeight) {
                frame.y = window.y - deltaY
                frame.width = window.width + deltaX
                frame.height = window.height + deltaY
            }
        } else if (flag == resize_edge.resizeBottomLeft) {
            var deltaX = -x
            var deltaY = deltaX / widthHeightScale

            if (windowView.width + deltaX >= windowView.minimumWidth &&
                windowView.height + deltaY >= windowView.minimumHeight) {
                frame.x = window.x - deltaX
                frame.width = window.width + deltaX
                frame.height = window.height + deltaY
            }
        } else if (flag == resize_edge.resizeBottomRight) {
            var deltaX = x - window.width
            var deltaY = deltaX / widthHeightScale

            if (windowView.width + deltaX >= windowView.minimumWidth &&
                windowView.height + deltaY >= windowView.minimumHeight) {
                frame.width = window.width + deltaX
                frame.height = window.height + deltaY
            }
        }
    }

    Rectangle {
        id: frame
        color: "transparent"
        radius: 3
        border.color: "#AAAEC1D5"
        border.width: 2
        layer.enabled: true

        Text {
            id: resolution
            color: frame.border.color
            font.pixelSize: 50
            text: "%1x%2".arg(Math.floor(frame.width - 2 * program_constants.windowGlowRadius))
                            .arg(Math.floor(frame.height - 2 * program_constants.windowGlowRadius))
            anchors.centerIn: parent
        }
    }
}
