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

    property int minimumWidth
    property int minimumHeight

    function show() {
        frame.x = windowView.x
        frame.y = windowView.y
        frame.width = windowView.width
        frame.height = windowView.height

        root.visible = true
    }

    function hide() {
        root.visible = false
    }

    function intelligentlyResize(x, y) {
        _intelligentlyResize(x, y, resizeEdge)
    }

    function _intelligentlyResize(x, y, flag) {
        if (flag == resize_edge.resizeTop) {
            var deltaY = -y
            var deltaX = deltaY * widthHeightScale

            if (windowView.width + deltaX >= root.minimumWidth &&
                windowView.height + deltaY >= root.minimumHeight) {
                frame.y = windowView.y - deltaY
                frame.width = windowView.width + deltaX
                frame.height = windowView.height + deltaY
            }
        } else if (flag == resize_edge.resizeBottom) {
            var deltaY = y - windowView.height
            var deltaX = deltaY * widthHeightScale

            if (windowView.width + deltaX >= root.minimumWidth &&
                windowView.height + deltaY >= root.minimumHeight) {
                frame.width = windowView.width + deltaX
                frame.height = windowView.height + deltaY
            }
        } else if (flag == resize_edge.resizeLeft) {
            var deltaX = -x
            var deltaY = deltaX / widthHeightScale

            if (windowView.width + deltaX >= root.minimumWidth &&
                windowView.height + deltaY >= root.minimumHeight) {
                frame.x = windowView.x - deltaX
                frame.width = windowView.width + deltaX
                frame.height = windowView.height + deltaY
            }
        } else if (flag == resize_edge.resizeRight) {
            var deltaX = x - windowView.width
            var deltaY = deltaX / widthHeightScale

            if (windowView.width + deltaX >= root.minimumWidth &&
                windowView.height + deltaY >= root.minimumHeight) {
                frame.width = windowView.width + deltaX
                frame.height = windowView.height + deltaY
            }
        } else if (flag == resize_edge.resizeTopLeft) {
            var deltaX = -x
            var deltaY = deltaX / widthHeightScale

            if (windowView.width + deltaX >= root.minimumWidth &&
                windowView.height + deltaY >= root.minimumHeight) {
                frame.x = windowView.x - deltaX
                frame.y = windowView.y - deltaY
                frame.width = windowView.width + deltaX
                frame.height = windowView.height + deltaY
            }
        } else if (flag == resize_edge.resizeTopRight) {
            var deltaX = x - windowView.width
            var deltaY = deltaX / widthHeightScale

            if (windowView.width + deltaX >= root.minimumWidth &&
                windowView.height + deltaY >= root.minimumHeight) {
                frame.y = windowView.y - deltaY
                frame.width = windowView.width + deltaX
                frame.height = windowView.height + deltaY
            }
        } else if (flag == resize_edge.resizeBottomLeft) {
            var deltaX = -x
            var deltaY = deltaX / widthHeightScale

            if (windowView.width + deltaX >= root.minimumWidth &&
                windowView.height + deltaY >= root.minimumHeight) {
                frame.x = windowView.x - deltaX
                frame.width = windowView.width + deltaX
                frame.height = windowView.height + deltaY
            }
        } else if (flag == resize_edge.resizeBottomRight) {
            var deltaX = x - windowView.width
            var deltaY = deltaX / widthHeightScale

            if (windowView.width + deltaX >= root.minimumWidth &&
                windowView.height + deltaY >= root.minimumHeight) {
                frame.width = windowView.width + deltaX
                frame.height = windowView.height + deltaY
            }
        }
    }

    Item {
        id: frame

        Rectangle {
            color: "transparent"
            radius: 3
            border.color: "#AAAEC1D5"
            border.width: 2
            layer.enabled: true
            anchors.fill: parent
            anchors.margins: windowView.windowGlowRadius

            Text {
                id: resolution
                color: parent.border.color
                font.pixelSize: 50
                text: "%1x%2".arg(Math.floor(frame.width - 2 * program_constants.windowGlowRadius))
                                .arg(Math.floor(frame.height - 2 * program_constants.windowGlowRadius))
                anchors.centerIn: parent
            }
        }
    }
}
