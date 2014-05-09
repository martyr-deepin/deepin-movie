import QtQuick 2.1

Item {
	function respondKey(event) {
		if (event.key == Qt.Key_Escape) { main_controller.normalize(); return }
		if (config.fetchBool("HotkeysPlay", "hotkey_enabled")) {
			for(var i = 0; i < config.hotKeysPlay.length; i++) {
				if (_utils.checkKeySequenceEqual(event.modifiers, event.key, 
					config.hotKeysPlay[i].key)) 
				{
					eval("main_controller." + config.hotKeysPlay[i].command + "()")
				}
			}
		} else if (config.fetchBool("HotkeysOthers", "hotkey_enabled")) {
			for(var i = 0; i < config.hotKeysOthers.length; i++) {
				if (_utils.checkKeySequenceEqual(event.modifiers, event.key, 
					config.hotKeysOthers[i].key)) 
				{
					eval("main_controller." + config.hotKeysPlay[i].command + "()")
				}
			}
		}
	}
}