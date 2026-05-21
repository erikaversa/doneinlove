import QtQuick 2.15
import QtQuick.Controls 2.15
//import QtQuick.Layouts 1.15

Item {
    id: root
    signal goToLogin()
    signal signupSuccess()

    Connections {
        target: Auth
        function onSignupSuccess(user) {
            statusText.color = "#1D9E75"
            statusText.text = "✓ Account created! Check your email to confirm before signing in."
            //root.signupSuccess()
        }
        function onSignupFailed(error) {
            statusText.color = "#E24B4A"
            statusText.text = error
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#f5ede4"

        Column {
            anchors.centerIn: parent
            width: Math.min(parent.width - 48, 480)
            spacing: 32

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Done In Love."
                font.family: "Georgia"
                font.pixelSize: 28
                font.italic: true
                color: "#2c1f14"
            }

            Rectangle {
                width: parent.width
                radius: 16
                color: "#ffffff"
                border.color: "#e8ddd4"
                border.width: 1
                height: cardColumn.implicitHeight + 48

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
                        text: "Come in"
                        font.pixelSize: 26
                        font.weight: Font.Medium
                        color: "#2c1f14"
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Create your private door."
                        font.pixelSize: 14
                        color: "#7a6a5a"
                        bottomPadding: 8
                    }

                    // Status
                    Text {
                        id: statusText
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: ""
                        font.pixelSize: 13
                        visible: text.length > 0
                    }

                    // Nickname
                    Rectangle {
                        width: parent.width
                        height: 52
                        radius: 10
                        color: "#f5ede4"
                        border.color: nicknameField.activeFocus ? "#b87057" : "transparent"
                        border.width: 1

                        Text {
                            z: 0
                            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 16 }
                            text: "Nickname (what loved ones call you)"
                            color: "#a89880"
                            font.pixelSize: 15
                            visible: nicknameField.text.length === 0 && !nicknameField.activeFocus
                        }
                        TextInput {
                            id: nicknameField
                            z: 1
                            anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: 16; rightMargin: 16 }
                            font.pixelSize: 15
                            color: "#2c1f14"
                        }
                    }

                    // Full name
                    Rectangle {
                        width: parent.width
                        height: 52
                        radius: 10
                        color: "#f5ede4"
                        border.color: fullNameField.activeFocus ? "#b87057" : "transparent"
                        border.width: 1

                        Text {
                            z: 0
                            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 16 }
                            text: "Full name (for the record)"
                            color: "#a89880"
                            font.pixelSize: 15
                            visible: fullNameField.text.length === 0 && !fullNameField.activeFocus
                        }
                        TextInput {
                            id: fullNameField
                            z: 1
                            anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: 16; rightMargin: 16 }
                            font.pixelSize: 15
                            color: "#2c1f14"
                        }
                    }

                    // Email
                    Rectangle {
                        width: parent.width
                        height: 52
                        radius: 10
                        color: "#f5ede4"
                        border.color: emailField.activeFocus ? "#b87057" : "transparent"
                        border.width: 1

                        Text {
                            z: 0
                            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 16 }
                            text: "Email"
                            color: "#a89880"
                            font.pixelSize: 15
                            visible: emailField.text.length === 0 && !emailField.activeFocus
                        }
                        TextInput {
                            id: emailField
                            z: 1
                            anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: 16; rightMargin: 16 }
                            font.pixelSize: 15
                            color: "#2c1f14"
                            inputMethodHints: Qt.ImhEmailCharactersOnly
                        }
                    }

                    // Password
                    Rectangle {
                        width: parent.width
                        height: 52
                        radius: 10
                        color: "#f5ede4"
                        border.color: passwordField.activeFocus ? "#b87057" : "transparent"
                        border.width: 1

                        Text {
                            z: 0
                            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 16 }
                            text: "Password"
                            color: "#a89880"
                            font.pixelSize: 15
                            visible: passwordField.text.length === 0 && !passwordField.activeFocus
                        }
                        TextInput {
                            id: passwordField
                            z: 1
                            anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: 16; rightMargin: 16 }
                            font.pixelSize: 15
                            color: "#2c1f14"
                            echoMode: TextInput.Password
                        }
                    }

                    // Create account button
                    Rectangle {
                        width: parent.width
                        height: 52
                        radius: 10
                        color: createMouse.containsMouse ? "#a0614a" : "#b87057"
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Text {
                            anchors.centerIn: parent
                            text: "Create account"
                            font.pixelSize: 16
                            font.weight: Font.Medium
                            color: "#ffffff"
                        }
                        MouseArea {
                            id: createMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: Auth.signUp(
                                emailField.text,
                                passwordField.text,
                                nicknameField.text,
                                fullNameField.text
                            )
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Already have an account? Sign in"
                        font.pixelSize: 14
                        color: "#7a6a5a"
                        bottomPadding: 8
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
