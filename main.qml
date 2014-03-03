import QtQuick 2.1
import QtQuick.Window 2.1

Item {
    id: root
    width: 950
    height: 470

    ResizeEdge { id: resize_edge }
    Constants { id: program_constants }

    Connections {
        target: windowView

        onWidthChanged: {
            if (!player.visible) {
                pageManager.show_page(titlebar.currentPage, online.x, online.y, online.width, online.height)
            }
        }
        onHeightChanged: {
            if (!player.visible) {
                pageManager.show_page(titlebar.currentPage, online.x, online.y, online.width, online.height)
            }
        }
    }

    Rectangle {
        id: main_window
        width: root.width - 6
        height: root.height - 6
        clip: true
        color: "#1D1D1D"
        radius: program_constants.windowRadius
        anchors.centerIn: parent

        Image { anchors.fill: parent; source: "image/background.png" }

        Player1 {
            id: player
            source: "/home/hualet/Videos/1.mp4"
            anchors.fill: parent
        }

        PlaceHolder {
            id: online;
            width: parent.width
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.topMargin: program_constants.titlebarHeight
        }
    }

    MainController {
        window: root
    }

    TitleBar {
        id: titlebar;
        width: main_window.width
        anchors.horizontalCenter: main_window.horizontalCenter
    }

    ControlBar {
        id: controlbar

        width: main_window.width
        anchors.bottom: main_window.bottom
        anchors.horizontalCenter: main_window.horizontalCenter
    }
}