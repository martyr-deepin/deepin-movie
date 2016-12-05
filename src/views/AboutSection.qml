import QtQuick 2.1
import Deepin.Widgets 1.0

SectionContent {
    id: about
    title: dsTr("About")
    sectionId: "about"
    topSpaceHeight: 30

    property string version: "1.0"

    DssH2 {
        text: dsTr("Deepin Movie")

        anchors.horizontalCenter: parent.horizontalCenter
    }

    DIcon {
        width: 64
        height: 64
        theme: "Deepin"
        icon: "deepin-movie"

        anchors.horizontalCenter: parent.horizontalCenter
    }

    DssH3 {
        text: dsTr("Version") + dsTr(":") + about.version
        anchors.horizontalCenter: parent.horizontalCenter
    }

    DLinkText {
        text: "www.deepin.org"
        refLink: "http://www.deepin.org"
        font.pixelSize: 10
        anchors.horizontalCenter: parent.horizontalCenter
    }

    DLinkText {
        text: dsTr("Acknowledgements")
        refLink: "https://www.deepin.org/acknowledgments/deepin-movie"
        font.pixelSize: 10
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Column {
        id: info_column
        width: 338
        height: childrenRect.height
        anchors.horizontalCenter: parent.horizontalCenter

        Space {
            width: info_column.width
            height: 3
        }

        Text {
            color: "#606060"
            font.pixelSize: 10
            width: info_column.width
            wrapMode: Text.WordWrap
            lineHeightMode: Text.FixedHeight
            lineHeight: 18
            horizontalAlignment: Text.AlignHCenter
            text: dsTr("Deepin Movie is a well-designed and full-featured video player with simple borderless design. It supports local and streaming media play with multiple video formats.")
        }

        Text {
            color: "#606060"
            font.pixelSize: 10
            width: info_column.width
            wrapMode: Text.WordWrap
            lineHeightMode: Text.FixedHeight
            lineHeight: 18
            horizontalAlignment: Text.AlignHCenter
            text: dsTr("Deepin Movie is released under GPLv3.")
        }
    }

    Item {
        width: parent.width
        height: 20
    }
}