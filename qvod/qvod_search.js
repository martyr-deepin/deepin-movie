function search() {
	var frames = window.frames

	for (var i = 0; i < frames.length; i++) {
		var queryResult = document.querySelector('[classid="clsid:F3D0D36F-23F8-4682-A195-74C92B03D4AF"] param[name="URL"]')
		if (queryResult) {
			alert(queryResult.value)
		}
	}
}
