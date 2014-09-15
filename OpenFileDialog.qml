import QtQuick 2.1
import QtQuick.Dialogs 1.0

FileDialog {
	title: dsTr("Please choose one file or more")
	folder: database.lastOpenedPath || _utils.homeDir
	nameFilters: [ videoFilter, "(*)"]
	selectMultiple: true
	selectExisting: true
    selectFolder: false

    property string videoFilter: "(*.3g2 *.3gp *.3gp2 *.3gpp *.amv
                    *.asf *.avi *.bin *.divx *.drc
                    *.dv *.f4v *.flv *.gvi *.gxf *.iso
                    *.m1v *.m2v *.m2t *.m2ts *.m4v *.mkv
                    *.mov *.mp2 *.mp2v *.mp4 *.mp4v *.mpe
                    *.mpeg *.mpeg1 *.mpeg2 *.mpeg4 *.mpg
                    *.mpv2 *.mts *.mtv *.mxf *.mxg *.nsv
                    *.nuv *.ogg *.ogm *.ogv *.ogx *.ps
                    *.rec *.rm *.rmvb *.tod *.ts *.tts
                    *.vob *.vro *.webm *.wm *.wmv *.wtv
                    *.xesc)"
	property string state: "open_video_file"

	onStateChanged: {
		switch(state) {
			case "open_video_file":
			title = dsTr("Please choose one file or more")
			folder = database.lastOpenedPath || _utils.homeDir
			nameFilters = [ videoFilter, "(*)"]
			selectMultiple = true
			selectExisting = true
			break

			case "open_subtitle_file":
			title = dsTr("Please choose one file")
			folder = database.lastOpenedPath || _utils.homeDir
			nameFilters = [ "(*.srt, *.ass, *.ssa)", "(*)"]
			selectMultiple = false
			selectExisting = true
			break

			case "add_playlist_item":
			title = dsTr("Please choose one file or more")
			folder = database.lastOpenedPath || _utils.homeDir
			nameFilters = [ videoFilter, "(*)" ]
			selectMultiple = true
			selectExisting = true
			break

			case "import_playlist":
			title = dsTr("Please choose one file")
			folder = database.lastOpenedPlaylistPath || _utils.homeDir
			nameFilters = [ "(*.dmpl)", "(*)" ]
			selectMultiple = false
			selectExisting = true
			break

			case "export_playlist":
			title = dsTr("Save as")
			folder = database.lastOpenedPlaylistPath || _utils.homeDir
			nameFilters = [ "(*.dmpl)", "(*)" ]
			selectMultiple = true
			selectExisting = false
		}
	}
}
