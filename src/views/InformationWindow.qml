import QtQuick 2.1
import Deepin.Widgets 1.0
import "sources/ui_utils.js" as UIUtils

DDialog {
    id: info_window
    width: 400
    height: column.childrenRect.height + 30 + 20
    modality: Qt.ApplicationModal
    titleContentPadding: 0

    property string fileTitle
    property string fileType
    property string fileSize
    property string movieResolution
    property string movieDuration
    property string filePath

    signal copyToClipboard (string text)

    function showInfo(vinfo) {
        var videoInfo = JSON.parse(vinfo)
        fileTitle = videoInfo.movie_title || dsTr("Unknown")
        fileType = videoInfo.movie_type || dsTr("Unknown")
        fileSize = UIUtils.formatSize(videoInfo.movie_size) || dsTr("Unknown")
        movieResolution = "%1x%2".arg(videoInfo.movie_width).arg(videoInfo.movie_height)
        movieDuration = UIUtils.formatTime(videoInfo.movie_duration)
        filePath = UIUtils.formatFilePath(videoInfo.movie_path)

        info_window.show()
    }

    content: Column {
        id: column
        width: info_window.width - anchors.leftMargin - anchors.rightMargin
        spacing: 10
        anchors.left: parent.left
        anchors.leftMargin: 15
        anchors.right: parent.right
        anchors.rightMargin: 15

        Column {
            width: column.width
            height: childrenRect.height

            Text {
                id: file_title
                font.pixelSize: 12
                font.bold: true
                color: "#b4b4b4"
                width: column.width
                height: implicitHeight
                elide: Text.ElideRight
                text: info_window.fileTitle
            }

            Space { width: column.width; height: 3 }
        }

        Grid {
            id: grid
            columns: 2
            rowSpacing: 8

            property int titleWidth: Math.max(
                file_type_title.implicitWidth,
                file_size_title.implicitWidth,
                movie_resolution_title.implicitWidth,
                movie_duration_title.implicitWidth,
                file_path_title.implicitWidth
                )
            property int valueWidth: column.width - titleWidth

            InformationLabel {
                id: file_type_title
                width: grid.titleWidth
                title: dsTr("File type")
            }
            InformationLabel {
                id: file_type_value
                width: grid.valueWidth
                value: info_window.fileType
            }
            InformationLabel {
                id: file_size_title
                width: grid.titleWidth
                title: dsTr("File size")
            }
            InformationLabel {
                id: file_size_value
                width: grid.valueWidth
                value: info_window.fileSize
            }
            InformationLabel {
                id: movie_resolution_title
                width: grid.titleWidth
                title: dsTr("Resolution")
            }
            InformationLabel {
                id: movie_resolution_value
                width: grid.valueWidth
                value: info_window.movieResolution
            }
            InformationLabel {
                id: movie_duration_title
                width: grid.titleWidth
                title: dsTr("Movie duration")
            }
            InformationLabel {
                id: movie_duration_value
                width: grid.valueWidth
                value: info_window.movieDuration
            }
            InformationLabel {
                id: file_path_title
                width: grid.titleWidth
                title: dsTr("File path")
            }
            InformationLabel {
                id: file_path_value
                width: grid.valueWidth
                value: info_window.filePath
                lineHeight: 17
                lineHeightMode: Text.FixedHeight
            }
        }

        Item {
            width: parent.width
            height: copy_button.height

            DTextButton {
                id: copy_button
                text: dsTr("Copy to clipboard")
                anchors.right: confirm_button.left
                anchors.rightMargin: 15
                anchors.bottom: parent.bottom

                onClicked: info_window.copyToClipboard(file_title.text + "\n"
                    + file_type_title.text + file_type_value.text + "\n"
                    + file_size_title.text + file_size_value.text + "\n"
                    + movie_resolution_title.text + movie_resolution_value.text + "\n"
                    + movie_duration_title.text + movie_duration_value.text + "\n"
                    + file_path_title.text + file_path_value.text)
            }

            DTextButton {
                id: confirm_button
                text: dsTr("Close")

                anchors.right: parent.right
                anchors.bottom: parent.bottom

                onClicked: info_window.hide()
            }
        }
    }
}