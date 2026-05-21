
import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    property string userId: ""
    property bool isLoggedIn: userId.length > 0

    signal openMemories()
    signal openInvitations()
    signal openStory()
    signal openLegal()
    signal openUpdates()
    signal openSettings()
    signal openWill()
    signal openFamily()

    Rectangle {
        anchors.fill: parent
        color: "#f5ede4"

        Flickable {
            anchors.fill: parent
            contentHeight: mainColumn.implicitHeight
            clip: true

            Column {
                id: mainColumn
                width: parent.width

                // ── NAV ──────────────────────────────────────────────
                Rectangle {
                    width: parent.width
                    height: 56
                    color: "#f5ede4"
                    border.color: "#e8ddd4"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "Done In Love."
                        font.family: "Georgia"
                        font.pixelSize: 20
                        font.italic: true
                        color: "#2c1f14"
                    }
                }

                // ── HERO ─────────────────────────────────────────────
                Column {
                    width: Math.min(parent.width - 48, 480)
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 24
                    topPadding: 40
                    bottomPadding: 40

                    Image {
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: "../assets/done-in-love-logo.png"
                        width: Math.min(parent.width - 48, 320)
                        height: width
                        fillMode: Image.PreserveAspectFit
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "for the people I love most"
                        font.family: "Georgia"
                        font.pixelSize: 22
                        font.italic: true
                        color: "#b87057"
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "A letter that listens."
                        font.family: "Georgia"
                        font.pixelSize: 36
                        font.italic: true
                        color: "#2c1f14"
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }

                    Column {
                        width: parent.width
                        spacing: 12

                        Repeater {
                            model: [
                                "A quiet place to come back to.",
                                "Ask anything. Tell me how your day went. Read the things I wrote down so you'd know.",
                                "My body is gone, I know. But I thought of you so many times, in so many ways — and that doesn't disappear. It lives here, in these words.",
                                "One thing I'm asking: smile before you start. Not because it's easy — it's not, and I know that. But because that's exactly how I pictured you when I wrote all of this."
                            ]
                            Text {
                                width: parent.width
                                text: modelData
                                font.pixelSize: 15
                                color: "#7a6a5a"
                                wrapMode: Text.WordWrap
                                lineHeight: 1.6
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Smiling. And here with me."
                        font.family: "Georgia"
                        font.pixelSize: 22
                        font.italic: true
                        color: "#b87057"
                    }

                    // ── BUTTONS ──────────────────────────────────────
                    Column {
                        width: parent.width
                        spacing: 12

                        Rectangle {
                            width: parent.width
                            height: 52
                            radius: 10
                            color: primaryMouse.containsMouse ? "#a0614a" : "#b87057"
                            Behavior on color { ColorAnimation { duration: 150 } }
                            Text {
                                anchors.centerIn: parent
                                text: root.isLoggedIn ? "Open our memories" : "Sign in to begin"
                                font.pixelSize: 16
                                font.weight: Font.Medium
                                color: "#ffffff"
                            }
                            MouseArea {
                                id: primaryMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: root.openMemories()
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 52
                            radius: 10
                            color: memorialsMouse.containsMouse ? "#e8ddd4" : "#ffffff"
                            border.color: "#e8ddd4"
                            border.width: 1
                            visible: root.isLoggedIn
                            Behavior on color { ColorAnimation { duration: 150 } }
                            Text {
                                anchors.centerIn: parent
                                text: "Invitations"
                                font.pixelSize: 16
                                color: "#2c1f14"
                            }
                            MouseArea {
                                id: memorialsMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: root.openInvitations()
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 52
                            radius: 10
                            color: storyMouse.containsMouse ? "#a0614a" : "#b87057"
                            Behavior on color { ColorAnimation { duration: 150 } }
                            Text {
                                anchors.centerIn: parent
                                text: "Story & Donation"
                                font.pixelSize: 16
                                font.weight: Font.Medium
                                color: "#ffffff"
                            }
                            MouseArea {
                                id: storyMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: root.openStory()
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 52
                            radius: 10
                            visible: root.isLoggedIn
                            color: settingsMouse.containsMouse ? "#e8ddd4" : "#ffffff"
                            border.color: "#e8ddd4"
                            border.width: 1
                            Behavior on color { ColorAnimation { duration: 150 } }
                            Text {
                                anchors.centerIn: parent
                                text: "Settings"
                                font.pixelSize: 16
                                color: "#2c1f14"
                            }
                            MouseArea {
                                id: settingsMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: root.openSettings()
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 52
                            radius: 10
                            visible: root.isLoggedIn
                            color: willMouse.containsMouse ? "#a0614a" : "#b87057"
                            Behavior on color { ColorAnimation { duration: 150 } }
                            Text {
                                anchors.centerIn: parent
                                text: "Your Will"
                                font.pixelSize: 16
                                font.weight: Font.Medium
                                color: "#ffffff"
                            }
                            MouseArea {
                                id: willMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: root.openWill()
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 52
                            radius: 10
                            visible: root.isLoggedIn
                            color: familyMouse.containsMouse ? "#e8ddd4" : "#ffffff"
                            border.color: "#e8ddd4"
                            border.width: 1
                            Behavior on color { ColorAnimation { duration: 150 } }
                            Text {
                                anchors.centerIn: parent
                                text: "Family"
                                font.pixelSize: 16
                                color: "#2c1f14"
                            }
                            MouseArea {
                                id: familyMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: root.openFamily()
                            }
                        }

                    }
                }

                // ── QUIET GIFT ───────────────────────────────────────
                Item {
                    width: parent.width
                    height: 80
                    Text {
                        anchors.centerIn: parent
                        text: "— a quiet gift —"
                        font.family: "Georgia"
                        font.pixelSize: 20
                        font.italic: true
                        color: "#8a9e8a"
                    }
                }

                // ── FOOTER ───────────────────────────────────────────
                Rectangle {
                    width: parent.width
                    height: 80
                    color: "#f5ede4"
                    border.color: "#e8ddd4"
                    border.width: 1

                    Column {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "© 2026 Erika Aversa — demo version of Done In Love."
                            font.pixelSize: 11
                            color: "#a89880"
                        }

                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 16

                            Repeater {
                                model: ["Story & Donation", "Privacy & Terms", "Updates"]
                                Text {
                                    text: modelData
                                    font.pixelSize: 11
                                    color: "#b87057"
                                    font.underline: true
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (index === 0) root.openStory()
                                            if (index === 1) root.openLegal()
                                            if (index === 2) root.openUpdates()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}