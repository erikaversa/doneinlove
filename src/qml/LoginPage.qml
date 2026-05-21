import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    signal goToSignup()
    signal goToForgotPassword()
    signal loginSuccess()

    // Listen to auth results
    Connections {
        target: Auth
        function onLoginSuccess(user) {
            statusText.color = "#1D9E75"
            statusText.text = "Welcome back!"
            root.loginSuccess()
        }
        function onLoginFailed(error) {
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
                        text: "Welcome back"
                        font.pixelSize: 26
                        font.weight: Font.Medium
                        color: "#2c1f14"
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Sign in to continue."
                        font.pixelSize: 14
                        color: "#7a6a5a"
                        bottomPadding: 8
                    }

                    // Status message
                    Text {
                        id: statusText
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: ""
                        font.pixelSize: 13
                        visible: text.length > 0
                    }

                    // Email field
                    Rectangle {
                        width: parent.width
                        height: 52
                        radius: 10
                        color: "#f5ede4"
                        border.color: emailField.activeFocus ? "#b87057" : "transparent"
                        border.width: 1
                        Text {
                            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 16 }
                            text: "Email"
                            color: "#a89880"
                            font.pixelSize: 15
                            visible: emailField.text.length === 0
                        }
                        TextInput {
                            id: emailField
                            anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: 16; rightMargin: 16 }
                            font.pixelSize: 15
                            color: "#2c1f14"
                            inputMethodHints: Qt.ImhEmailCharactersOnly
                        }
                    }

                    // Password field
                    Rectangle {
                        width: parent.width
                        height: 52
                        radius: 10
                        color: "#f5ede4"
                        border.color: passwordField.activeFocus ? "#b87057" : "transparent"
                        border.width: 1
                        Text {
                            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 16 }
                            text: "Password"
                            color: "#a89880"
                            font.pixelSize: 15
                            visible: passwordField.text.length === 0
                        }
                        TextInput {
                            id: passwordField
                            anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: 16; rightMargin: 16 }
                            font.pixelSize: 15
                            color: "#2c1f14"
                            echoMode: TextInput.Password
                        }
                    }

                    // Sign in button
                    Rectangle {
                        width: parent.width
                        height: 52
                        radius: 10
                        color: signInMouse.containsMouse ? "#a0614a" : "#b87057"
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Text {
                            anchors.centerIn: parent
                            text: "Sign in"
                            font.pixelSize: 16
                            font.weight: Font.Medium
                            color: "#ffffff"
                        }
                        MouseArea {
                            id: signInMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: Auth.signIn(emailField.text, passwordField.text)
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Forgot your password?"
                        font.pixelSize: 14
                        color: "#b87057"
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.goToForgotPassword()
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Have an invitation? Create an account"
                        font.pixelSize: 14
                        color: "#7a6a5a"
                        bottomPadding: 8
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.goToSignup()
                        }
                    }
                }
            }
        }
    }
}
