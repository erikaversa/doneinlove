import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    signal goBack()

    // ── State ──────────────────────────────────────────────────────────
    property bool waiting: false

    ListModel { id: messages }

    // ── AI signals ─────────────────────────────────────────────────────
    Connections {
        target: DirectChatService
        function onMessageReceived(text) {
            messages.append({ role: "assistant", content: text })
            root.waiting = false
            listView.positionViewAtEnd()
        }
        function onMessageFailed(err) {
            messages.append({ role: "assistant", content: "⚠ " + err })
            root.waiting = false
            listView.positionViewAtEnd()
        }
    }

    // ── Layout ─────────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: "#f5ede4"

        // Header
        Rectangle {
            id: header
            width: parent.width
            height: 56
            color: "#f5ede4"
            border.color: "#e8ddd4"
            border.width: 1
            z: 2

            Text {
                anchors.centerIn: parent
                text: "AI Chat"
                font.family: "Georgia"
                font.pixelSize: 20
                font.italic: true
                color: "#2c1f14"
            }

            Text {
                anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
                text: "←"
                font.pixelSize: 22
                color: "#b87057"
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.goBack()
                }
            }

            Text {
                anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                text: "Clear"
                font.pixelSize: 13
                color: "#b87057"
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        messages.clear()
                        DirectChatService.clearHistory()
                    }
                }
            }
        }

        // Message list
        ListView {
            id: listView
            anchors {
                top: header.bottom
                left: parent.left
                right: parent.right
                bottom: inputBar.top
            }
            clip: true
            spacing: 8
            topMargin: 12
            bottomMargin: 12
            leftMargin: 16
            rightMargin: 16
            model: messages

            delegate: Item {
                width: listView.width - 32
                height: bubble.implicitHeight + 4

                readonly property bool isUser: model.role === "user"

                Rectangle {
                    id: bubble
                    anchors {
                        right: isUser ? parent.right : undefined
                        left:  isUser ? undefined     : parent.left
                    }
                    width: Math.min(msgText.implicitWidth + 24, parent.width * 0.78)
                    implicitHeight: msgText.implicitHeight + 20
                    radius: 14
                    color: isUser ? "#b87057" : "#ffffff"
                    border.color: isUser ? "transparent" : "#e8ddd4"
                    border.width: isUser ? 0 : 1

                    Text {
                        id: msgText
                        anchors {
                            left: parent.left; leftMargin: 12
                            right: parent.right; rightMargin: 12
                            verticalCenter: parent.verticalCenter
                        }
                        text: model.content
                        font.pixelSize: 14
                        color: isUser ? "#ffffff" : "#2c1f14"
                        wrapMode: Text.WordWrap
                        lineHeight: 1.5
                    }
                }
            }

            // Typing indicator
            footer: Item {
                width: listView.width - 32
                height: root.waiting ? 36 : 0
                visible: root.waiting

                Rectangle {
                    anchors.left: parent.left
                    width: 60
                    height: 28
                    radius: 14
                    color: "#ffffff"
                    border.color: "#e8ddd4"
                    border.width: 1

                    Row {
                        anchors.centerIn: parent
                        spacing: 5

                        Repeater {
                            model: 3
                            Rectangle {
                                width: 6; height: 6; radius: 3
                                color: "#b87057"
                                SequentialAnimation on opacity {
                                    loops: Animation.Infinite
                                    NumberAnimation { to: 0.3; duration: 400 }
                                    NumberAnimation { to: 1.0; duration: 400 }
                                    PauseAnimation  { duration: index * 130 }
                                }
                            }
                        }
                    }
                }
            }

            onCountChanged: positionViewAtEnd()
        }

        // Input bar
        Rectangle {
            id: inputBar
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            height: 64
            color: "#ffffff"
            border.color: "#e8ddd4"
            border.width: 1

            Row {
                anchors {
                    fill: parent
                    leftMargin: 12; rightMargin: 12
                    topMargin: 10; bottomMargin: 10
                }
                spacing: 8

                Rectangle {
                    width: parent.width - sendBtn.width - 8
                    height: parent.height
                    radius: 20
                    color: "#f5ede4"
                    border.color: msgInput.activeFocus ? "#b87057" : "#e8ddd4"
                    border.width: 1

                    TextInput {
                        id: msgInput
                        anchors {
                            fill: parent
                            leftMargin: 14; rightMargin: 14
                        }
                        font.pixelSize: 14
                        color: "#2c1f14"
                        clip: true
                        enabled: !root.waiting

                        Keys.onReturnPressed: sendMsg()
                        Keys.onEnterPressed:  sendMsg()

                        Text {
                            anchors.fill: parent
                            text: "Message Gemini…"
                            font.pixelSize: 14
                            color: "#c0b0a0"
                            visible: msgInput.text.length === 0 && !msgInput.activeFocus
                        }
                    }
                }

                Rectangle {
                    id: sendBtn
                    width: 44; height: parent.height
                    radius: 22
                    color: sendMouse.containsMouse && !root.waiting ? "#a0614a"
                         : root.waiting                             ? "#d0b8aa"
                         : "#b87057"
                    Behavior on color { ColorAnimation { duration: 120 } }

                    Text {
                        anchors.centerIn: parent
                        text: "↑"
                        font.pixelSize: 18
                        color: "#ffffff"
                    }

                    MouseArea {
                        id: sendMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: !root.waiting
                        cursorShape: Qt.PointingHandCursor
                        onClicked: sendMsg()
                    }
                }
            }
        }
    }

    function sendMsg() {
        var text = msgInput.text.trim()
        if (text.length === 0 || root.waiting) return
        messages.append({ role: "user", content: text })
        listView.positionViewAtEnd()
        root.waiting = true
        msgInput.text = ""
        DirectChatService.sendMessage(text)
    }
}
