import QtQuick 2.1
import Deepin.Widgets 1.0

DPreferenceWindow {
	id: info_window
	width: 400
	height: 210

	property string fileTitle
	property string fileType
	property string fileSize
	property string movieResolution
	property string movieDuration
	property string filePath

	signal copyToClipboard (string text)

	content: Column {
		spacing: 5
		anchors.left: parent.left
		anchors.leftMargin: 15
		anchors.right: parent.right
		anchors.rightMargin: 15

		Text {
			id: file_title
			font.pixelSize: 12
			font.bold: true
			color: "#b4b4b4"
			width: parent.width
			elide: Text.ElideRight
			text: info_window.fileTitle
		}

		Space { width: parent.width; height: 5}

		Text {
			id: file_type
			font.pixelSize: 12
			color: "#b4b4b4"
			text: dsTr("File type") + ": " + info_window.fileType
		}

		Text {
			id: file_size
			font.pixelSize: 12
			color: "#b4b4b4"
			text: dsTr("File size") + ": " + info_window.fileSize
		}

		Text {
			id: movie_resolution
			font.pixelSize: 12
			color: "#b4b4b4"
			text: dsTr("Resolution") + ": " + info_window.movieResolution
		}

		Text {
			id: movie_duration
			font.pixelSize: 12
			color: "#b4b4b4"
			text: dsTr("Movie duration") + ": " + info_window.movieDuration
		}	

		Text {
			id: file_path
			font.pixelSize: 12
			color: "#b4b4b4"
			width: parent.width
			elide: Text.ElideRight
			text: dsTr("File path") + ": " + info_window.filePath
		}

		Item {
			width: parent.width
			height: 30

			DTextButton {
				id: copy_button
				text: dsTr("Copy to clipboard")
				anchors.right: confirm_button.left
				anchors.rightMargin: 15
				anchors.bottom: parent.bottom

				onClicked: info_window.copyToClipboard(file_title.text + "\n"
					+ file_type.text + "\n"
					+ file_size.text + "\n"
					+ movie_resolution.text + "\n"
					+ movie_duration.text + "\n"
					+ file_path.text)
			}

			DTextButton {
				id: confirm_button
				text: dsTr("Confirm")
				anchors.right: parent.right
				anchors.bottom: parent.bottom

				onClicked: info_window.hide()
			}
		}
	}
}