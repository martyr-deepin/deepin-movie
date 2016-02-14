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
	height: Math.max(title.implicitHeight, input.height)

	property alias title: title.text
	property alias input: input

	signal menuSelect (int index)

	Text {
		id: title
		color: "#787878"
		width: 136
		wrapMode: Text.Wrap
		font.pixelSize: 12
		anchors.left: parent.left
		anchors.verticalCenter: parent.verticalCenter
	}

	ColorComboBox {
		id: input
		width: 200
		menu.maxHeight: 100
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter

		onMenuSelect: parent.menuSelect(index)
	}
}