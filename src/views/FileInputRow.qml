import QtQuick 2.1
import Deepin.Widgets 1.0
import "sources/ui_utils.js" as UIUtils

Item {
    id: row
    width: 370
    height: Math.max(title.implicitHeight, input.height)

    property alias title: title.text
    property alias text: input.text
    property alias transientWindow: open_folder_dialog.transientParent

    signal fileSet (string path)

    OpenFolderDialog {
        id: open_folder_dialog
        modality: Qt.ApplicationModal

        onAccepted: {
            var path = UIUtils.formatFilePath(fileUrl.toString())
            input.text = path
            row.fileSet(path)
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