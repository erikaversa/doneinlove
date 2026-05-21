import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    signal goToLogin()

    property bool sent: false
    property bool busy: false

    Connections {
        target: Auth
        function onPasswordResetSent() {
            root.busy = false
            root.sent = true
        }
        function onPasswordResetFailed(error) {
            root.busy = false
            statusText.color = "#E24B4A"
            statusText.text = error
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
                    onClicked: root.goToLogin()
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
                        text: "Reset your password"
                        font.family: "Georgia"
                        font.pixelSize: 24
                        color: "#2c1f14"
                    }

                    // ── Sent confirmation ──────────────────────────────────
                    Column {
                        width: parent.width
                        spacing: 16
                        visible: root.sent

                        Text {
                            width: parent.width
                            text: "Check your email — we've sent you a password reset link."
                            font.pixelSize: 14
                            color: "#1D9E75"
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Back to sign in"
                            font.pixelSize: 14
                            color: "#b87057"
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.goToLogin()
                            }
                        }
                    }

                    // ── Request form ───────────────────────────────────────
                    Column {
                        width: parent.width
                        spacing: 16
                        visible: !root.sent

                        Text {
                            width: parent.width
                            text: "Enter your email address and we'll send you a link to reset your password."
                            font.pixelSize: 14
                            color: "#7a6a5a"
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                            bottomPadding: 4
                        }

                        Text {
                            id: statusText
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: ""
                            font.pixelSize: 13
                            visible: text.length > 0
                        }

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

                        Rectangle {
                            width: parent.width
                            height: 52
                            radius: 10
                            color: root.busy ? "#d4a898" : (sendMouse.containsMouse ? "#a0614a" : "#b87057")
                            opacity: root.busy ? 0.6 : 1.0
                            Behavior on color { ColorAnimation { duration: 150 } }

                            Text {
                                anchors.centerIn: parent
                                text: root.busy ? "..." : "Send reset link"
                                font.pixelSize: 16
                                font.weight: Font.Medium
                                color: "#ffffff"
                            }

                            MouseArea {
                                id: sendMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                enabled: !root.busy
                                onClicked: {
                                    if (emailField.text.length === 0) {
                                        statusText.color = "#E24B4A"
                                        statusText.text = "Please enter your email address."
                                        return
                                    }
                                    root.busy = true
                                    statusText.text = ""
                                    Auth.requestPasswordReset(emailField.text)
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
}
