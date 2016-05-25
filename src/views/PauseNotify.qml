import QtQuick 2.1

Image {
    id: pauseNotify
    sourceSize.width: 96
    sourceSize.height: 96
    source: "image/pause_notify.svg"
    
    function notify() {
        pauseNotify.visible = true
        movePauseNotify.start()
    }

    SequentialAnimation {
        id: movePauseNotify

        ParallelAnimation {
            PropertyAnimation {
                target: pauseNotify
                property: "scale"
                to: 1
                duration: 100
                easing.type: Easing.OutQuint
            }

            PropertyAnimation {
                target: pauseNotify
                property: "opacity"
                to: 1
                duration: 100
                easing.type: Easing.OutQuint
            }
        }

        PauseAnimation {
            duration: 500
        }

        ParallelAnimation {
            PropertyAnimation {
                target: pauseNotify
                property: "scale"
                to: 0.6
                duration: 650
                easing.type: Easing.OutQuint
            }

            PropertyAnimation {
                target: pauseNotify
                property: "opacity"
                to: 0
                duration: 650
                easing.type: Easing.OutQuint
            }
        }
        
        onStopped: { pauseNotify.visible = false }
    }
}