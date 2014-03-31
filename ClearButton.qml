import QtQuick 2.1

MouseArea {
    state: "normal"
    width: row.width
    height: row.height
    hoverEnabled: true

    states: [
        State {
            name: "normal"
            PropertyChanges {
                target: icn
                source: "image/trash_normal.png"
            }
            PropertyChanges {
                target: lab
                color: program_constants.normalColor
            }
        },
        State {
            name: "hover"
            PropertyChanges {
                target: icn
                source: "image/trash_hover.png"
            }
            PropertyChanges {
                target: lab
                color: program_constants.hoverColor
            }
        },
        State {
            name: "pressed"
            PropertyChanges {
                target: icn
                source: "image/trash_pressed.png"
            }
            PropertyChanges {
                target: lab
                color: program_constants.pressedColor
            }
        }
    ]

    Row {
        id: row
        spacing: 5

        Image { id: icn }
        Text { 
            id: lab; 
            text: "清空" 
            font.pixelSize: 12
        }
    }
    
    onPressed: state = "pressed"
    onReleased: state = "hover"
    onEntered: state = "hover"
    onExited: state = "normal"
}
