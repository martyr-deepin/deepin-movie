/**
 * Copyright (C) 2014 Deepin Technology Co., Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 **/

import QtQuick 2.1
import Deepin.Widgets 1.0

Item {
	width: 370
	height: Math.max(title.implicitHeight, spinner.height)

	property alias title: title.text
	property alias min: spinner.min
	property alias max: spinner.max
	property alias step: spinner.step
	property alias value: spinner.value
	property alias text: spinner.text
	property alias precision: spinner.precision

	Text {
		id: title
		color: "#787878"
		width: 136
		wrapMode: Text.Wrap
		font.pixelSize: 12
		anchors.left: parent.left
		anchors.verticalCenter: parent.verticalCenter
	}

	DSpinner {
		id: spinner
		width: 200
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
	}
}