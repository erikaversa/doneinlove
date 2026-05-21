import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    height: 56
    color: "#ffffff"
    border.color: "#e8ddd4"
    border.width: 1

    property string currentPage: "memories"

    signal goToMemories()
    signal goToMemorials()
    signal goToFamily()
    signal goToWill()
    signal goToSettings()
    signal signOut()

    Row {
        anchors.fill: parent

        Repeater {
            model: [
                { id: "memories",  label: "Memories",  icon: "♡" },
                { id: "memorials", label: "Invitations", icon: "✦" },
                { id: "family",    label: "Family",    icon: "✉" },
                { id: "will",      label: "Will",      icon: "✎" },
                { id: "settings",  label: "Settings",  icon: "⚙" }
            ]

            Rectangle {
                width: root.width / 5
                height: root.height
                color: navMouse.containsMouse ? "#fdf0eb" : "transparent"
                Behavior on color { ColorAnimation { duration: 120 } }

                Column {
                    anchors.centerIn: parent
                    spacing: 2

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: modelData.icon
                        font.pixelSize: 18
                        color: root.currentPage === modelData.id ? "#b87057" : "#a89880"
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: modelData.label
                        font.pixelSize: 10
                        color: root.currentPage === modelData.id ? "#b87057" : "#a89880"
                    }
                }

                Rectangle {
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 24
                    height: 2
                    radius: 1
                    color: "#b87057"
                    visible: root.currentPage === modelData.id
                }

                MouseArea {
                    id: navMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if      (modelData.id === "memories")  root.goToMemories()
                        else if (modelData.id === "memorials") root.goToMemorials()
                        else if (modelData.id === "family")    root.goToFamily()
                        else if (modelData.id === "will")      root.goToWill()
                        else if (modelData.id === "settings")  root.goToSettings()
                    }
                }
            }
        }
    }
}
