import QtQuick 2.1
import Deepin.Widgets 1.0

DFileDialog {
    title: dsTr("Please choose a folder")
    selectExisting: true
    selectFolder: true
    selectMultiple: false
}
