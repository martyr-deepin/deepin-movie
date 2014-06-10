import QtQuick 2.1
import Deepin.Widgets 1.0

DImageButton {
    property string imageName

    normal_image: imageName + "_normal.png"
    hover_image: imageName + "_hover.png"
    press_image: imageName + "_press.png"
}
