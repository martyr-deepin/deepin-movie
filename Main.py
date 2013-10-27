#! /usr/bin/python
# -*- coding: utf-8 -*-

# Copyright (C) 2011 ~ 2012 Deepin, Inc.
#               2011 ~ 2012 Wang Yong
# 
# Author:     Wang Yong <lazycat.manatee@gmail.com>
# Maintainer: Wang Yong <lazycat.manatee@gmail.com>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

from PyQt5.QtWidgets import QApplication, qApp
from PyQt5.QtQuick import QQuickView, QQuickItem
from PyQt5.QtQml import qmlRegisterType
from PyQt5.QtGui import QSurfaceFormat, QColor, QCloseEvent
from PyQt5 import QtCore, QtQuick
from PyQt5.QtCore import QSize
import os
import sys
import signal
from ImageCanvas import ImageCanvas
from TopRoundRect import TopRoundRect
from Player import Player

if __name__ == "__main__":
    app = QApplication(sys.argv)
    
    qmlRegisterType(ImageCanvas, "ImageCanvas", 1, 0, "ImageCanvas")
    qmlRegisterType(TopRoundRect, "TopRoundRect", 1, 0, "TopRoundRect")
    
    view = QQuickView()
    
    player = Player()
    player.setWindowFlags(QtCore.Qt.FramelessWindowHint)
    player.openFile("/space/data/Video/DoctorWho/1.rmvb")
    player.resize(900, 600)
    
    qml_context = view.rootContext()
    qml_context.setContextProperty("windowView", view)
    qml_context.setContextProperty("qApp", qApp)
    
    def adjustPlayer():
        pages = view.rootObject().findChild(QQuickItem, "pages")
        player.move(
            view.x() + pages.x() + 1,
            view.y() + pages.y(),
            )
        player.resize(
            pages.width() - 2,
            pages.height() - 1,
            )
        
    def quitApp(*args):
        qApp.quit()
        
    def viewEvent(event):
        super(QQuickView, view).event(event)
        
        if event.type() == QCloseEvent().type():
            quitApp()
        
        return False
        
    view.xChanged.connect(lambda x: adjustPlayer())    
    view.yChanged.connect(lambda y: adjustPlayer())
    view.destroyed.connect(quitApp)
    view.event = viewEvent
    
    player.show()
    
# ['ColorSpec', 'CustomColor', 'ManyColor', 'NormalColor', '__class__', '__delattr__', '__dict__', '__doc__', '__format__', '__getattr__', '__getattribute__', '__hash__', '__init__', '__module__', '__new__', '__reduce__', '__reduce_ex__', '__repr__', '__setattr__', '__sizeof__', '__str__', '__subclasshook__', '__weakref__', 'aboutQt', 'aboutToQuit', 'activeModalWidget', 'activePopupWidget', 'activeWindow', 'addLibraryPath', 'alert', 'allWidgets', 'allWindows', 'applicationDirPath', 'applicationDisplayName', 'applicationFilePath', 'applicationName', 'applicationPid', 'applicationVersion', 'arguments', 'autoSipEnabled', 'beep', 'blockSignals', 'changeOverrideCursor', 'childEvent', 'children', 'clipboard', 'closeAllWindows', 'closingDown', 'colorSpec', 'commitDataRequest', 'connectNotify', 'cursorFlashTime', 'customEvent', 'deleteLater', 'desktop', 'desktopSettingsAware', 'destroyed', 'devicePixelRatio', 'disconnect', 'disconnectNotify', 'doubleClickInterval', 'dumpObjectInfo', 'dumpObjectTree', 'dynamicPropertyNames', 'event', 'eventDispatcher', 'eventFilter', 'exec_', 'exit', 'findChild', 'findChildren', 'flush', 'focusChanged', 'focusObject', 'focusObjectChanged', 'focusWidget', 'focusWindow', 'focusWindowChanged', 'font', 'fontDatabaseChanged', 'fontMetrics', 'globalStrut', 'hasPendingEvents', 'inherits', 'installEventFilter', 'installNativeEventFilter', 'installTranslator', 'instance', 'isEffectEnabled', 'isLeftToRight', 'isQuitLockEnabled', 'isRightToLeft', 'isSavingSession', 'isSessionRestored', 'isSignalConnected', 'isWidgetType', 'isWindowType', 'keyboardInputInterval', 'keyboardModifiers', 'killTimer', 'lastWindowClosed', 'layoutDirection', 'libraryPaths', 'metaObject', 'modalWindow', 'mouseButtons', 'moveToThread', 'notify', 'objectName', 'objectNameChanged', 'organizationDomain', 'organizationName', 'overrideCursor', 'palette', 'parent', 'platformName', 'postEvent', 'primaryScreen', 'processEvents', 'property', 'pyqtConfigure', 'queryKeyboardModifiers', 'quit', 'quitOnLastWindowClosed', 'receivers', 'removeEventFilter', 'removeLibraryPath', 'removeNativeEventFilter', 'removePostedEvents', 'removeTranslator', 'restoreOverrideCursor', 'saveStateRequest', 'screenAdded', 'screens', 'sendEvent', 'sendPostedEvents', 'sender', 'senderSignalIndex', 'sessionId', 'sessionKey', 'setActiveWindow', 'setApplicationDisplayName', 'setApplicationName', 'setApplicationVersion', 'setAttribute', 'setAutoSipEnabled', 'setColorSpec', 'setCursorFlashTime', 'setDesktopSettingsAware', 'setDoubleClickInterval', 'setEffectEnabled', 'setEventDispatcher', 'setFont', 'setGlobalStrut', 'setKeyboardInputInterval', 'setLayoutDirection', 'setLibraryPaths', 'setObjectName', 'setOrganizationDomain', 'setOrganizationName', 'setOverrideCursor', 'setPalette', 'setParent', 'setProperty', 'setQuitLockEnabled', 'setQuitOnLastWindowClosed', 'setStartDragDistance', 'setStartDragTime', 'setStyle', 'setStyleSheet', 'setWheelScrollLines', 'setWindowIcon', 'signalsBlocked', 'startDragDistance', 'startDragTime', 'startTimer', 'startingUp', 'staticMetaObject', 'style', 'styleSheet', 'testAttribute', 'thread', 'timerEvent', 'topLevelAt', 'topLevelWidgets', 'topLevelWindows', 'tr', 'translate', 'wheelScrollLines', 'widgetAt', 'windowIcon']
# [NULL @ 0x7f18440350e0] Unsupported video codec
    

# ['__class__', '__delattr__', '__dict__', '__doc__', '__format__', '__getattr__', '__getattribute__', '__hash__', '__init__', '__module__', '__new__', '__reduce__', '__reduce_ex__', '__repr__', '__setattr__', '__sizeof__', '__str__', '__subclasshook__', '__weakref__', 'baseUrl', 'blockSignals', 'childEvent', 'children', 'connectNotify', 'contextObject', 'contextProperty', 'customEvent', 'deleteLater', 'destroyed', 'disconnect', 'disconnectNotify', 'dumpObjectInfo', 'dumpObjectTree', 'dynamicPropertyNames', 'engine', 'event', 'eventFilter', 'findChild', 'findChildren', 'inherits', 'installEventFilter', 'isSignalConnected', 'isValid', 'isWidgetType', 'isWindowType', 'killTimer', 'metaObject', 'moveToThread', 'nameForObject', 'objectName', 'objectNameChanged', 'parent', 'parentContext', 'property', 'pyqtConfigure', 'receivers', 'removeEventFilter', 'resolvedUrl', 'sender', 'senderSignalIndex', 'setBaseUrl', 'setContextObject', 'setContextProperty', 'setObjectName', 'setParent', 'setProperty', 'signalsBlocked', 'startTimer', 'staticMetaObject', 'thread', 'timerEvent', 'tr']
    
    view.setResizeMode(QtQuick.QQuickView.SizeRootObjectToView)
    view.setMinimumSize(QSize(900, 600))
    
    surface_format = QSurfaceFormat()
    surface_format.setAlphaBufferSize(8)
    view.setFormat(surface_format)
    
    view.setColor(QColor(0, 0, 0, 0))
    view.setFlags(QtCore.Qt.FramelessWindowHint)
    view.setSource(QtCore.QUrl.fromLocalFile(os.path.join(os.path.dirname(__file__), 'Main.qml')))
    view.show()
    
    # test = qml_context.contextProperty
    # test = view.rootObject()
    # print test.frame
    
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    sys.exit(app.exec_())

# ['AllowNestedDocks', 'AllowTabbedDocks', 'AnimatedDocks', 'DockOption', 'DockOptions', 'DrawChildren', 'DrawWindowBackground', 'ForceTabbedDocks', 'IgnoreMask', 'OpenFile', 'PaintDeviceMetric', 'PdmDepth', 'PdmDpiX', 'PdmDpiY', 'PdmHeight', 'PdmHeightMM', 'PdmNumColors', 'PdmPhysicalDpiX', 'PdmPhysicalDpiY', 'PdmWidth', 'PdmWidthMM', 'RenderFlag', 'RenderFlags', 'VerticalTabs', '__class__', '__delattr__', '__dict__', '__doc__', '__format__', '__getattr__', '__getattribute__', '__hash__', '__init__', '__module__', '__new__', '__reduce__', '__reduce_ex__', '__repr__', '__setattr__', '__sizeof__', '__str__', '__subclasshook__', '__weakref__', 'acceptDrops', 'accessibleDescription', 'accessibleName', 'actionEvent', 'actions', 'activateWindow', 'addAction', 'addActions', 'addDockWidget', 'addToolBar', 'addToolBarBreak', 'adjustSize', 'autoFillBackground', 'backgroundRole', 'baseSize', 'blockSignals', 'centralWidget', 'changeEvent', 'childAt', 'childEvent', 'children', 'childrenRect', 'childrenRegion', 'clearFocus', 'clearMask', 'close', 'closeEvent', 'colorCount', 'connectNotify', 'contentsMargins', 'contentsRect', 'contextMenuEvent', 'contextMenuPolicy', 'corner', 'create', 'createPopupMenu', 'cursor', 'customContextMenuRequested', 'customEvent', 'deleteLater', 'depth', 'destroy', 'destroyed', 'devType', 'disconnect', 'disconnectNotify', 'dockOptions', 'dockWidgetArea', 'documentMode', 'dragEnterEvent', 'dragLeaveEvent', 'dragMoveEvent', 'dropEvent', 'dumpObjectInfo', 'dumpObjectTree', 'dynamicPropertyNames', 'effectiveWinId', 'ensurePolished', 'enterEvent', 'event', 'eventFilter', 'find', 'findChild', 'findChildren', 'focusInEvent', 'focusNextChild', 'focusNextPrevChild', 'focusOutEvent', 'focusPolicy', 'focusPreviousChild', 'focusProxy', 'focusWidget', 'font', 'fontInfo', 'fontMetrics', 'foregroundRole', 'frameGeometry', 'frameSize', 'geometry', 'getContentsMargins', 'grab', 'grabGesture', 'grabKeyboard', 'grabMouse', 'grabShortcut', 'graphicsEffect', 'graphicsProxyWidget', 'hasFocus', 'hasHeightForWidth', 'hasMouseTracking', 'height', 'heightForWidth', 'heightMM', 'hide', 'hideEvent', 'iconSize', 'iconSizeChanged', 'inherits', 'initPainter', 'inputMethodEvent', 'inputMethodHints', 'inputMethodQuery', 'insertAction', 'insertActions', 'insertToolBar', 'insertToolBarBreak', 'installEventFilter', 'instance', 'isActiveWindow', 'isAncestorOf', 'isAnimated', 'isDockNestingEnabled', 'isEnabled', 'isEnabledTo', 'isFullScreen', 'isHidden', 'isLeftToRight', 'isMaximized', 'isMinimized', 'isModal', 'isRightToLeft', 'isSeparator', 'isSignalConnected', 'isVisible', 'isVisibleTo', 'isWidgetType', 'isWindow', 'isWindowModified', 'isWindowType', 'keyPressEvent', 'keyReleaseEvent', 'keyboardGrabber', 'killTimer', 'layout', 'layoutDirection', 'leaveEvent', 'locale', 'logicalDpiX', 'logicalDpiY', 'lower', 'mapFrom', 'mapFromGlobal', 'mapFromParent', 'mapTo', 'mapToGlobal', 'mapToParent', 'mask', 'maximumHeight', 'maximumSize', 'maximumWidth', 'mediaplayer', 'menuBar', 'menuWidget', 'metaObject', 'metric', 'minimumHeight', 'minimumSize', 'minimumSizeHint', 'minimumWidth', 'mouseDoubleClickEvent', 'mouseGrabber', 'mouseMoveEvent', 'mousePressEvent', 'mouseReleaseEvent', 'move', 'moveEvent', 'moveToThread', 'nativeEvent', 'nativeParentWidget', 'nextInFocusChain', 'normalGeometry', 'objectName', 'objectNameChanged', 'overrideWindowFlags', 'overrideWindowState', 'paintEngine', 'paintEvent', 'paintingActive', 'palette', 'parent', 'parentWidget', 'physicalDpiX', 'physicalDpiY', 'pos', 'previousInFocusChain', 'property', 'pyqtConfigure', 'raise_', 'receivers', 'rect', 'redirected', 'releaseKeyboard', 'releaseMouse', 'releaseShortcut', 'removeAction', 'removeDockWidget', 'removeEventFilter', 'removeToolBar', 'removeToolBarBreak', 'render', 'repaint', 'resize', 'resizeEvent', 'restoreDockWidget', 'restoreGeometry', 'restoreState', 'saveGeometry', 'saveState', 'scroll', 'sender', 'senderSignalIndex', 'setAcceptDrops', 'setAccessibleDescription', 'setAccessibleName', 'setAnimated', 'setAttribute', 'setAutoFillBackground', 'setBackgroundRole', 'setBaseSize', 'setCentralWidget', 'setContentsMargins', 'setContextMenuPolicy', 'setCorner', 'setCursor', 'setDisabled', 'setDockNestingEnabled', 'setDockOptions', 'setDocumentMode', 'setEnabled', 'setFixedHeight', 'setFixedSize', 'setFixedWidth', 'setFocus', 'setFocusPolicy', 'setFocusProxy', 'setFont', 'setForegroundRole', 'setGeometry', 'setGraphicsEffect', 'setHidden', 'setIconSize', 'setInputMethodHints', 'setLayout', 'setLayoutDirection', 'setLocale', 'setMask', 'setMaximumHeight', 'setMaximumSize', 'setMaximumWidth', 'setMenuBar', 'setMenuWidget', 'setMinimumHeight', 'setMinimumSize', 'setMinimumWidth', 'setMouseTracking', 'setObjectName', 'setPalette', 'setParent', 'setProperty', 'setShortcutAutoRepeat', 'setShortcutEnabled', 'setSizeIncrement', 'setSizePolicy', 'setStatusBar', 'setStatusTip', 'setStyle', 'setStyleSheet', 'setTabOrder', 'setTabPosition', 'setTabShape', 'setToolButtonStyle', 'setToolTip', 'setUpdatesEnabled', 'setVisible', 'setWhatsThis', 'setWindowFilePath', 'setWindowFlags', 'setWindowIcon', 'setWindowIconText', 'setWindowModality', 'setWindowModified', 'setWindowOpacity', 'setWindowRole', 'setWindowState', 'setWindowTitle', 'sharedPainter', 'show', 'showEvent', 'showFullScreen', 'showMaximized', 'showMinimized', 'showNormal', 'signalsBlocked', 'size', 'sizeHint', 'sizeIncrement', 'sizePolicy', 'splitDockWidget', 'stackUnder', 'startTimer', 'staticMetaObject', 'statusBar', 'statusTip', 'style', 'styleSheet', 'tabPosition', 'tabShape', 'tabifiedDockWidgets', 'tabifyDockWidget', 'tabletEvent', 'testAttribute', 'thread', 'timerEvent', 'toolBarArea', 'toolBarBreak', 'toolButtonStyle', 'toolButtonStyleChanged', 'toolTip', 'tr', 'underMouse', 'ungrabGesture', 'unsetCursor', 'unsetLayoutDirection', 'unsetLocale', 'update', 'updateGeometry', 'updateMicroFocus', 'updatesEnabled', 'videoframe', 'visibleRegion', 'whatsThis', 'wheelEvent', 'width', 'widthMM', 'winId', 'window', 'windowFilePath', 'windowFlags', 'windowIcon', 'windowIconText', 'windowModality', 'windowOpacity', 'windowRole', 'windowState', 'windowTitle', 'windowType', 'x', 'y']
    
# ['AncestorMode', 'CreateTextureOption', 'CreateTextureOptions', 'Error', 'ExcludeTransients', 'IncludeTransients', 'Loading', 'Null', 'OpenGLSurface', 'RasterSurface', 'Ready', 'ResizeMode', 'SizeRootObjectToView', 'SizeViewToRootObject', 'Status', 'SurfaceClass', 'SurfaceType', 'TextureHasAlphaChannel', 'TextureHasMipmaps', 'TextureOwnsGLTexture', 'Window', '__class__', '__delattr__', '__dict__', '__doc__', '__format__', '__getattr__', '__getattribute__', '__hash__', '__init__', '__module__', '__new__', '__reduce__', '__reduce_ex__', '__repr__', '__setattr__', '__sizeof__', '__str__', '__subclasshook__', '__weakref__', 'activeFocusItem', 'afterRendering', 'baseSize', 'beforeRendering', 'beforeSynchronizing', 'blockSignals', 'childEvent', 'children', 'clearBeforeRendering', 'close', 'color', 'colorChanged', 'connectNotify', 'contentItem', 'contentOrientation', 'contentOrientationChanged', 'create', 'createTextureFromId', 'createTextureFromImage', 'cursor', 'customEvent', 'deleteLater', 'destroy', 'destroyed', 'devicePixelRatio', 'disconnect', 'disconnectNotify', 'dumpObjectInfo', 'dumpObjectTree', 'dynamicPropertyNames', 'engine', 'errors', 'event', 'eventFilter', 'exposeEvent', 'filePath', 'findChild', 'findChildren', 'flags', 'focusInEvent', 'focusObject', 'focusObjectChanged', 'focusOutEvent', 'format', 'frameGeometry', 'frameMargins', 'framePosition', 'frameSwapped', 'geometry', 'grabWindow', 'height', 'heightChanged', 'hide', 'hideEvent', 'icon', 'incubationController', 'inherits', 'initialSize', 'installEventFilter', 'isActive', 'isAncestorOf', 'isExposed', 'isModal', 'isPersistentOpenGLContext', 'isPersistentSceneGraph', 'isSignalConnected', 'isTopLevel', 'isVisible', 'isWidgetType', 'isWindowType', 'keyPressEvent', 'keyReleaseEvent', 'killTimer', 'lower', 'mapFromGlobal', 'mapToGlobal', 'maximumHeight', 'maximumHeightChanged', 'maximumSize', 'maximumWidth', 'maximumWidthChanged', 'metaObject', 'minimumHeight', 'minimumHeightChanged', 'minimumSize', 'minimumWidth', 'minimumWidthChanged', 'modality', 'modalityChanged', 'mouseDoubleClickEvent', 'mouseGrabberItem', 'mouseMoveEvent', 'mousePressEvent', 'mouseReleaseEvent', 'moveEvent', 'moveToThread', 'objectName', 'objectNameChanged', 'openglContext', 'parent', 'position', 'property', 'pyqtConfigure', 'raise_', 'receivers', 'releaseResources', 'removeEventFilter', 'renderTarget', 'renderTargetId', 'renderTargetSize', 'reportContentOrientationChange', 'requestActivate', 'requestedFormat', 'resize', 'resizeEvent', 'resizeMode', 'rootContext', 'rootObject', 'sceneGraphInitialized', 'sceneGraphInvalidated', 'screen', 'screenChanged', 'sendEvent', 'sender', 'senderSignalIndex', 'setBaseSize', 'setClearBeforeRendering', 'setColor', 'setCursor', 'setFilePath', 'setFlags', 'setFormat', 'setFramePosition', 'setGeometry', 'setHeight', 'setIcon', 'setKeyboardGrabEnabled', 'setMaximumHeight', 'setMaximumSize', 'setMaximumWidth', 'setMinimumHeight', 'setMinimumSize', 'setMinimumWidth', 'setModality', 'setMouseGrabEnabled', 'setObjectName', 'setOpacity', 'setParent', 'setPersistentOpenGLContext', 'setPersistentSceneGraph', 'setPosition', 'setProperty', 'setRenderTarget', 'setResizeMode', 'setScreen', 'setSizeIncrement', 'setSource', 'setSurfaceType', 'setTitle', 'setTransientParent', 'setVisible', 'setWidth', 'setWindowState', 'setX', 'setY', 'show', 'showEvent', 'showFullScreen', 'showMaximized', 'showMinimized', 'showNormal', 'signalsBlocked', 'size', 'sizeIncrement', 'source', 'startTimer', 'staticMetaObject', 'status', 'statusChanged', 'surfaceClass', 'surfaceType', 'tabletEvent', 'thread', 'timerEvent', 'title', 'touchEvent', 'tr', 'transientParent', 'type', 'unsetCursor', 'update', 'visibleChanged', 'wheelEvent', 'width', 'widthChanged', 'winId', 'windowState', 'windowStateChanged', 'x', 'xChanged', 'y', 'yChanged']
# Number of leaked pixmaps: 4


# ['AncestorMode', 'CreateTextureOption', 'CreateTextureOptions', 'Error', 'ExcludeTransients', 'IncludeTransients', 'Loading', 'Null', 'OpenGLSurface', 'RasterSurface', 'Ready', 'ResizeMode', 'SizeRootObjectToView', 'SizeViewToRootObject', 'Status', 'SurfaceClass', 'SurfaceType', 'TextureHasAlphaChannel', 'TextureHasMipmaps', 'TextureOwnsGLTexture', 'Window', '__class__', '__delattr__', '__dict__', '__doc__', '__format__', '__getattr__', '__getattribute__', '__hash__', '__init__', '__module__', '__new__', '__reduce__', '__reduce_ex__', '__repr__', '__setattr__', '__sizeof__', '__str__', '__subclasshook__', '__weakref__', 'activeFocusItem', 'afterRendering', 'baseSize', 'beforeRendering', 'beforeSynchronizing', 'blockSignals', 'childEvent', 'children', 'clearBeforeRendering', 'close', 'color', 'colorChanged', 'connectNotify', 'contentItem', 'contentOrientation', 'contentOrientationChanged', 'create', 'createTextureFromId', 'createTextureFromImage', 'cursor', 'customEvent', 'deleteLater', 'destroy', 'destroyed', 'devicePixelRatio', 'disconnect', 'disconnectNotify', 'dumpObjectInfo', 'dumpObjectTree', 'dynamicPropertyNames', 'engine', 'errors', 'event', 'eventFilter', 'exposeEvent', 'filePath', 'findChild', 'findChildren', 'flags', 'focusInEvent', 'focusObject', 'focusObjectChanged', 'focusOutEvent', 'format', 'frameGeometry', 'frameMargins', 'framePosition', 'frameSwapped', 'geometry', 'grabWindow', 'height', 'heightChanged', 'hide', 'hideEvent', 'icon', 'incubationController', 'inherits', 'initialSize', 'installEventFilter', 'isActive', 'isAncestorOf', 'isExposed', 'isModal', 'isPersistentOpenGLContext', 'isPersistentSceneGraph', 'isSignalConnected', 'isTopLevel', 'isVisible', 'isWidgetType', 'isWindowType', 'keyPressEvent', 'keyReleaseEvent', 'killTimer', 'lower', 'mapFromGlobal', 'mapToGlobal', 'maximumHeight', 'maximumHeightChanged', 'maximumSize', 'maximumWidth', 'maximumWidthChanged', 'metaObject', 'minimumHeight', 'minimumHeightChanged', 'minimumSize', 'minimumWidth', 'minimumWidthChanged', 'modality', 'modalityChanged', 'mouseDoubleClickEvent', 'mouseGrabberItem', 'mouseMoveEvent', 'mousePressEvent', 'mouseReleaseEvent', 'moveEvent', 'moveToThread', 'objectName', 'objectNameChanged', 'openglContext', 'parent', 'position', 'property', 'pyqtConfigure', 'raise_', 'receivers', 'releaseResources', 'removeEventFilter', 'renderTarget', 'renderTargetId', 'renderTargetSize', 'reportContentOrientationChange', 'requestActivate', 'requestedFormat', 'resize', 'resizeEvent', 'resizeMode', 'rootContext', 'rootObject', 'sceneGraphInitialized', 'sceneGraphInvalidated', 'screen', 'screenChanged', 'sendEvent', 'sender', 'senderSignalIndex', 'setBaseSize', 'setClearBeforeRendering', 'setColor', 'setCursor', 'setFilePath', 'setFlags', 'setFormat', 'setFramePosition', 'setGeometry', 'setHeight', 'setIcon', 'setKeyboardGrabEnabled', 'setMaximumHeight', 'setMaximumSize', 'setMaximumWidth', 'setMinimumHeight', 'setMinimumSize', 'setMinimumWidth', 'setModality', 'setMouseGrabEnabled', 'setObjectName', 'setOpacity', 'setParent', 'setPersistentOpenGLContext', 'setPersistentSceneGraph', 'setPosition', 'setProperty', 'setRenderTarget', 'setResizeMode', 'setScreen', 'setSizeIncrement', 'setSource', 'setSurfaceType', 'setTitle', 'setTransientParent', 'setVisible', 'setWidth', 'setWindowState', 'setX', 'setY', 'show', 'showEvent', 'showFullScreen', 'showMaximized', 'showMinimized', 'showNormal', 'signalsBlocked', 'size', 'sizeIncrement', 'source', 'startTimer', 'staticMetaObject', 'status', 'statusChanged', 'surfaceClass', 'surfaceType', 'tabletEvent', 'thread', 'timerEvent', 'title', 'touchEvent', 'tr', 'transientParent', 'type', 'unsetCursor', 'update', 'visibleChanged', 'wheelEvent', 'width', 'widthChanged', 'winId', 'windowState', 'windowStateChanged', 'x', 'xChanged', 'y', 'yChanged']
