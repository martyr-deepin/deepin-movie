import QtQuick 2.1
import QtWebKit 3.0
import QtWebKit.experimental 1.0

Item {
	width: 1000; height: 800;

    Rectangle {
        id: myButton
        height: 60
        color: "#ff0000"
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: parent.top
        z: 1
 
        MouseArea {
            id: mouse_area1
            anchors.fill: parent
            onClicked: {
                nami.setCookie("/home/evilbeast/.cache/deepin-movie-plugins/a83677f5fcc7fc9f8360aed4387999fd");
                webView.reload();
            }
 
            Text {
                id: myButtonText
                color: "#fffb00"
                text: qsTr("Clear Coookies and Reload")
                font.bold: true
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 16
            }
 
        }
    }
 
    WebView {
        id: webView
        url: "http://vod.kuaibo.com/play/?vod_id=dedbb34cf9a41dc1a81be4b1d3e9c11f&s=C25817D8C4DE3955DBE83CE4B055C7494A0F33C5&qvod_link=qvod://946032623|6448B79B319C24D30DF2909421051DE27DE879F3|%E7%8B%84%E4%BB%81%E6%9D%B0%E4%B9%8B%E7%A5%9E%E9%83%BD%E9%BE%99%E7%8E%8B%EF%BC%88%E5%9B%BD%E8%AF%AD%E4%B8%AD%E5%AD%97%EF%BC%89|"
        anchors.fill: parent
    }
	
}


