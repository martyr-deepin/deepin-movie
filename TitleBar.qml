import QtQuick 2.1
import QtGraphicalEffects 1.0

DragableArea {
    id: titlebar
    height: program_constants.titlebarHeight

    property bool showMaximizButton: true
    property alias title: title_text.text

    signal minButtonClicked ()
    signal maxButtonClicked ()
    signal closeButtonClicked ()

    function show() {
        visible = true
    }

    function hide() {
        visible = false
    }

    onDoubleClicked: titlebar.maxButtonClicked()

    Item {
        id: titlebarBackground
        anchors.fill: parent

        LinearGradient {
            id: topPanelBackround
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: parent.height
            start: Qt.point(0, 0)
            end: Qt.point(0, height)
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#FF000000"}
                GradientStop { position: 1.0; color: "#00000000"}
            }
        }

        TopRoundItem {
            target: topPanelBackround
            radius: program_constants.windowRadius
        }

        Image {
            id: appIcon
            source: "image/logo.png"
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.top: parent.top
            anchors.topMargin: 5
        }

        TabButton {
            id: btn
            text: "深度影院"

            anchors.left: appIcon.right
            anchors.leftMargin: 10
            anchors.verticalCenter: appIcon.verticalCenter
        }

        Item {
            width: parent.width - appIcon.width - btn.width - windowButtonArea.width
            height: title_text.height
            
            anchors.verticalCenter: appIcon.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            
            Text {
                id: title_text
                font.pixelSize: 13
                color: Qt.rgba(1, 1, 1, 0.8)
                elide: Text.ElideRight
                
                anchors.centerIn: parent
            }
        }

        Row {
            id: windowButtonArea
            anchors {right: parent.right}

            ImageButton {
                id: minButton
                imageName: "image/window_min"
                onClicked: { titlebar.minButtonClicked() }
            }

            ImageButton {
                id: maxButton
                imageName: "image/window_max"
                visible: titlebar.showMaximizButton
                onClicked: { titlebar.maxButtonClicked() }
            }

            ImageButton {
                id: closeButton
                imageName: "image/window_close"
                onClicked: { titlebar.closeButtonClicked() }
            }
        }
    }
}