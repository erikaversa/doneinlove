import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    signal goBack()
    signal goToLogin()

    property bool busy: false
    property string statusMsg: ""
    property string statusColor: "#a89880"

    Connections {
        target: Auth
        function onPasswordUpdated() {
            root.busy = false
            root.statusMsg = "Password updated. Welcome back."
            root.statusColor = "#1D9E75"
            root.goToLogin()
        }
        function onPasswordUpdateFailed(error) {
            root.busy = false
            root.statusMsg = error
            root.statusColor = "#E24B4A"
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#f5ede4"

        Column {
            anchors.centerIn: parent
            width: Math.min(parent.width - 48, 400)
            spacing: 24

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Done In Love."
                font.family: "Georgia"
                font.pixelSize: 26
                font.italic: true
                color: "#2c1f14"
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.goBack()
                }
            }

            Rectangle {
                width: parent.width
                height: cardColumn.implicitHeight + 48
                radius: 16
                color: "#ffffff"
                border.color: "#e8ddd4"
                border.width: 1

                Column {
                    id: cardColumn
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        margins: 24
                    }
                    spacing: 16

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Set a new password"
                        font.family: "Georgia"
                        font.pixelSize: 24
                        color: "#2c1f14"
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width
                        text: root.statusMsg
                        font.pixelSize: 13
                        color: root.statusColor
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }

                    // New password
                    Rectangle {
                        width: parent.width
                        height: 52
                        radius: 10
                        color: "#f5ede4"
                        border.color: newPassField.activeFocus ? "#b87057" : "transparent"
                        border.width: 1
                        Text {
                            z: 0
                            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 16 }
                            text: "New password"
                            color: "#a89880"
                            font.pixelSize: 15
                            visible: newPassField.text.length === 0 && !newPassField.activeFocus
                        }
                        TextInput {
                            id: newPassField
                            z: 1
                            anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: 16; rightMargin: 16 }
                            font.pixelSize: 15
                            color: "#2c1f14"
                            echoMode: TextInput.Password
                        }
                    }

                    // Confirm password
                    Rectangle {
                        width: parent.width
                        height: 52
                        radius: 10
                        color: "#f5ede4"
                        border.color: confirmField.activeFocus ? "#b87057" : "transparent"
                        border.width: 1
                        Text {
                            z: 0
                            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 16 }
                            text: "Confirm new password"
                            color: "#a89880"
                            font.pixelSize: 15
                            visible: confirmField.text.length === 0 && !confirmField.activeFocus
                        }
                        TextInput {
                            id: confirmField
                            z: 1
                            anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: 16; rightMargin: 16 }
                            font.pixelSize: 15
                            color: "#2c1f14"
                            echoMode: TextInput.Password
                        }
                    }

                    // Update button
                    Rectangle {
                        width: parent.width
                        height: 52
                        radius: 10
                        color: root.busy ? "#d4a898" : (updateMouse.containsMouse ? "#a0614a" : "#b87057")
                        opacity: root.busy ? 0.6 : 1.0
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Text {
                            anchors.centerIn: parent
                            text: root.busy ? "..." : "Update password"
                            font.pixelSize: 16
                            font.weight: Font.Medium
                            color: "#ffffff"
                        }

                        MouseArea {
                            id: updateMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: !root.busy
                            onClicked: {
                                if (newPassField.text.length < 6) {
                                    root.statusMsg = "Password must be at least 6 characters."
                                    root.statusColor = "#E24B4A"
                                    return
                                }
                                if (newPassField.text !== confirmField.text) {
                                    root.statusMsg = "Passwords don't match."
                                    root.statusColor = "#E24B4A"
                                    return
                                }
                                root.busy = true
                                root.statusMsg = "Updating..."
                                root.statusColor = "#a89880"
                                Auth.updatePassword(newPassField.text)
                            }
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Back to sign in"
                        font.pixelSize: 13
                        color: "#a89880"
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.goToLogin()
                        }
                    }
                }
            }
        }
    }
}
