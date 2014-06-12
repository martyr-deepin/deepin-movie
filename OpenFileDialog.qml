import QtQuick 2.1
import QtQuick.Dialogs 1.0

FileDialog {
    title: dsTr("Please choose one file or more")
    selectExisting: true
    selectFolder: false
    selectMultiple: true
}
