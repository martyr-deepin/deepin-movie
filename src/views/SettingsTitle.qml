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

Row {
	clip: true
	height: txt.implicitHeight
	spacing: 2

	property alias title: txt.text
	property alias showSep: sep.visible

	DssH2 { 
		id: txt
		text: "hello"
	}

	DSeparatorHorizontal { 
		id: sep
		width: 1000 
		anchors.verticalCenter: parent.verticalCenter
	}
}