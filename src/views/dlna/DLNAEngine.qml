import QtQuick 2.2
import Deepin.Widgets 1.0

Item {
	id: root

	property bool sharing: false
	property bool hasDevices: false

	property var __currentRenderer

	Column {
		id: sharing_area
		width: 380
		height: childrenRect.height
		visible: root.sharing
		spacing: 10

		anchors.centerIn: parent

		Text {
			id: sharing_label
			width: parent.width
			color: "white"

			wrapMode: Text.WordWrap

		}

		DTransparentButton {
			id: stop_sharing_button
			text: dsTr("Switch back")
			anchors.horizontalCenter: parent.horizontalCenter

			onClicked: stopSharing()
		}
	}

	function showDevices() {
		var renderers = _dlna_controller.getRenderers()
		renderer_list_dialog.clearRenderers()
		for (var i = 0; i < renderers.length; i++) {
		    renderer_list_dialog.addRenderer(renderers[i])
		}
		renderer_list_dialog.show()
	}

	function shareTo(renderer) {
		__currentRenderer = renderer

		root.sharing = true
		sharing_label.text = dsTr("The movie \"%1\" is being played on \"%2\".")
			      			.arg(player.sourceString)
						    .arg(__currentRenderer.name)

		player.pause()
		player.visible = false
		controlbar.dlnaSharing = true
		__currentRenderer.playPath(player.sourceString)
	}

	function stopSharing() {
		root.sharing = false
		controlbar.dlnaSharing = false
		player.visible = true
		player.play()
		__currentRenderer.removePath(player.sourceString)
		__currentRenderer.stop()
	}

	function play() {
		if (sharing) {
			__currentRenderer.removePath(player.sourceString)
			__currentRenderer.stop()
			shareTo(__currentRenderer)
		}
	}

	Connections {
		target: _dlna_controller

		onFoundRenderer: {
			renderer_list_dialog.addRenderer(renderer)
			root.hasDevices = _dlna_controller.getRenderers().length != 0
		}
		onLostRenderer: {
			renderer_list_dialog.rmRenderer(path)
			root.hasDevices = _dlna_controller.getRenderers().length != 0
		}
	}

	Timer {
		running: true
		repeat: true
		interval: 10 * 1000
		onTriggered: {
			print("tick...")
			_dlna_controller.getVersion()
		}
	}

	RendererListDialog {
	    id: renderer_list_dialog

	    onConfirmed: root.shareTo(renderer)
	}
}