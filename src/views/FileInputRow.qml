import QtQuick 2.1
import Deepin.Widgets 1.0

Item {
    id: row
    width: 370
    height: Math.max(title.implicitHeight, input.height)

    property alias title: title.text
    property alias homeDir: open_folder_dialog.folder

    signal fileSet ()

    OpenFolderDialog {
        id: open_folder_dialog

        onAccepted: {
            input.text = fileUrl
            row.fileSet()
        }
    }

    Text {
        id: title
        color: "#787878"
        width: 136
        wrapMode: Text.Wrap
        font.pixelSize: 12
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
    }

    DFileChooseInput {
        id: input
        width: 200
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        onFileChooseClicked: open_folder_dialog.open()
    }
}