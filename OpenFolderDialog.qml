import QtQuick 2.1
import QtQuick.Dialogs 1.0

FileDialog {
    title: dsTr("Please choose a folder")
    selectExisting: true
    selectFolder: true
    selectMultiple: false
}
