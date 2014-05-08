import QtQuick 2.1

Item {
    property int titlebarHeight: 80
    property int titlebarTriggerThreshold: 50
    property int controlbarHeight: 64
    property int controlbarTriggerThreshold: 50
    
    property int playlistWidth: 200
    property int playlistTriggerThreshold: 50
    
    property int windowRadius: 3
    property int windowGlowRadius: windowView.windowGlowRadius
    
    property color normalColor: "#B4B4B4"
    property color hoverColor: "#FFFFFF"
    property color pressedColor: "#00BDFF"
    
    property color bgDarkColor: "#131414"
}