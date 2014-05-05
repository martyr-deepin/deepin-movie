import QtQuick 2.1
import QtGraphicalEffects 1.0

Item {
    id: titlebar
    height: program_constants.titlebarHeight

    property alias tabPages: tabs.children
    property string currentPage

    signal minButtonClicked ()
    signal maxButtonClicked ()
    signal closeButtonClicked ()

    function show() {
        visible = true
    }

    function hide() {
        visible = false
    }

    Item {
        id: tabs

        Item {
            property string name: "深度影音"
            property variant page: undefined
            property int index: 0
        }
    }

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
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 8
        }

        TabButton {
            text: "深度影音"

            anchors.left: appIcon.right
            anchors.leftMargin: 10
        }

        Row {
            anchors {right: parent.right}
            id: windowButtonArea

            ImageButton {
                id: minButton
                imageName: "image/window_min"
                onClicked: { titlebar.minButtonClicked() }
            }

            ImageButton {
                id: maxButton
                imageName: "image/window_max"
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