import QtQuick 2.1

Item {
    width: txt.implicitWidth
    height: txt.implicitHeight

    property string title: ""
    property string value: ""
    property alias text: txt.text
    property alias lineHeightMode: txt.lineHeightMode
    property alias lineHeight: txt.lineHeight
    property int implicitWidth: txt.implicitWidth

    Text {
        id: txt
        width: parent.title ? implicitWidth : parent.width
        font.pixelSize: 12
        color: "#b4b4b4"
        wrapMode: Text.WrapAnywhere
        text: parent.title ? parent.title + dsTr(":") : parent.value

        anchors.right: parent.title ? parent.right : undefined
        anchors.verticalCenter: parent.verticalCenter
    }
}
