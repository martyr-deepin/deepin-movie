import QtQuick 2.1
import QtQuick.Window 2.1

Item {
    width: main_window.width
    height: main_window.height

    ResizeEdge { id: resize_edge }

    Rectangle {
        id: main_window
        width: 300
        height: 300

        MainController {
            window: main_window
        }
        
        /* TitleBar { width: parent.width } */
    }
}