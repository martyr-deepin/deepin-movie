import QtQuick 2.1
import Deepin.Widgets 1.0

DPreferenceWindow {
	id: info_window
	width: 400
	height: 200
	flags: Qt.BypassWindowManagerHint
	titleContentPadding: 0

	property string fileTitle
	property string fileType
	property string fileSize
	property string movieResolution
	property string movieDuration
	property string filePath

	signal copyToClipboard (string text)

	function showContent(content) {
		if (!content) return

		var movieInfo = JSON.parse(content)
		fileTitle = movieInfo.movie_title
		fileType = movieInfo.movie_type
		fileSize = formatSize(parseInt(movieInfo.movie_size))
		movieResolution = "%1x%2".arg(movieInfo.movie_width).arg(movieInfo.movie_height)
		movieDuration = formatTime(parseInt(movieInfo.movie_duration))
		filePath = formatFilePath(movieInfo.movie_path)

		info_window.show()
	}

	content: Column {
		id: column
		spacing: 10
		anchors.left: parent.left
		anchors.leftMargin: 15
		anchors.right: parent.right
		anchors.rightMargin: 15

		Column {
			width: parent.width
			height: childrenRect.height

			Text {
				id: file_title
				font.pixelSize: 12
				font.bold: true
				color: "#b4b4b4"
				width: parent.width
				height: implicitHeight
				elide: Text.ElideRight
				text: info_window.fileTitle
			}
			Space { width: parent.width; height: 5}
		}

		Text {
			id: file_type
			height: implicitHeight
			font.pixelSize: 12
			color: "#b4b4b4"
			text: dsTr("File type") + ": " + info_window.fileType
		}

		Text {
			id: file_size
			height: implicitHeight
			font.pixelSize: 12
			color: "#b4b4b4"
			text: dsTr("File size") + ": " + info_window.fileSize
		}

		Text {
			id: movie_resolution
			height: implicitHeight
			font.pixelSize: 12
			color: "#b4b4b4"
			text: dsTr("Resolution") + ": " + info_window.movieResolution
		}

		Text {
			id: movie_duration
			height: implicitHeight
			font.pixelSize: 12
			color: "#b4b4b4"
			text: dsTr("Movie duration") + ": " + info_window.movieDuration
		}	

		Item {
			width: parent.width
			height: file_path.height

			Text {
				id: file_path_title
				font.pixelSize: 12
				color: "#b4b4b4"
				width: implicitWidth
				text: dsTr("File path") + ": "
			}
			Text {
				id: file_path
				font.pixelSize: 12
				color: "#b4b4b4"
				width: parent.width - file_path_title.width
				wrapMode: Text.WordWrap
				text: info_window.filePath

				anchors.left: file_path_title.right
			}
		}

		Item {
			width: parent.width
			height: copy_button.height + spc.height

			Space { id: spc; width: parent.width; height: 6 }

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
					+ file_path_title.text + file_path.text)
			}

			DTextButton {
				id: confirm_button
				text: dsTr("Confirm")
				anchors.right: parent.right
				anchors.bottom: parent.bottom

				onClicked: info_window.hide()
			}
		}

		Component.onCompleted: {
			info_window.height = Qt.binding(function() { return childrenRect.height + 50 })
		}
	}
}