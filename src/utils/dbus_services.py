from PyQt5.QtCore import QObject, Q_CLASSINFO, pyqtSlot
from PyQt5.QtDBus import (QDBusConnection, QDBusAbstractAdaptor,
    QDBusAbstractInterface)

DBUS_NAME = "com.deepin.DeepinMovie"
DBUS_PATH = "/com/deepin/DeepinMovie"
session_bus = QDBusConnection.sessionBus()

def check_multiple_instances():
    return session_bus.registerService(DBUS_NAME)

class DeepinMovieServie(QObject):
    def __init__(self, application):
        super(DeepinMovieServie, self).__init__()
        self.__app = application
        self.__dbusAdaptor = DeepinMovieServiceAdaptor(self)

    def play(self, pathList):
        self.__app._extra_window().undoMinimized()
        self.__app._extra_window().raise_()
        self.__app._extra_window().play(pathList)

class DeepinMovieServiceAdaptor(QDBusAbstractAdaptor):

    Q_CLASSINFO("D-Bus Interface", DBUS_NAME)
    Q_CLASSINFO("D-Bus Introspection",
                '  <interface name="com.deepin.DeepinMovie">\n'
                '    <method name="Play">\n'
                '      <arg direction="in" type="s" name="pathList"/>\n'
                '    </method>\n'
                '  </interface>\n')

    def __init__(self, parent):
        super(DeepinMovieServiceAdaptor, self).__init__(parent)
        self.parent = parent

    @pyqtSlot(str)
    def Play(self, pathList):
        return self.parent.play(pathList)

class DeepinMovieInterface(QDBusAbstractInterface):

    def __init__(self):
        super(DeepinMovieInterface, self).__init__(DBUS_NAME,
                                                   DBUS_PATH,
                                                   DBUS_NAME,
                                                   session_bus,
                                                   None)

    def play(self, file_path):
        self.call('Play', file_path)
