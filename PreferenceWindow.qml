import QtQuick 2.1
import Deepin.Widgets 1.0

DPreferenceWindow {
    width: 500
    height: 500

    content: DPreferenceView {
        id: preference_view
        
        sections: [
            {
                "sectionId": "id1",
                "sectionName": "First",
                "subSections": [
                    {
                        "sectionId": "id2",
                        "sectionName": "RedRedRed",
                        "subSections": []
                    },
                    {
                        "sectionId": "id3",
                        "sectionName": "Blue",
                        "subSections": []
                    }
                ]
            },
            {
                "sectionId": "id4",
                "sectionName": "Yellow",
                "subSections": []
            },
            {
                "sectionId": "id5",
                "sectionName": "Green",
                "subSections": []
            },
        ]

        Rectangle {
            color: "red"
            width: 300
            height: 300

            property string sectionId: "id2"
        }

        Rectangle {
            color: "blue"
            width: 300
            height: 300

            property string sectionId: "id3"
        }

        Rectangle {
            color: "yellow"
            width: 300
            height: 300

            property string sectionId: "id4"
        }

        Rectangle {
            color: "green"
            width: 300
            height: 300

            property string sectionId: "id5"
        }
    }
}