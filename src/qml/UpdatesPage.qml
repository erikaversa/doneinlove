import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    signal goBack()
    signal goToLegal()

    Rectangle {
        anchors.fill: parent
        color: "#f5ede4"

        Flickable {
            anchors.fill: parent
            contentHeight: mainColumn.implicitHeight + 60
            clip: true

            Column {
                id: mainColumn
                width: Math.min(parent.width - 48, 640)
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 24

                // ── HEADER ───────────────────────────────────────────
                Item {
                    width: parent.width
                    height: 64

                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Done In Love."
                        font.family: "Georgia"
                        font.pixelSize: 18
                        font.italic: true
                        color: "#2c1f14"
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.goBack()
                        }
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Privacy & Terms"
                        font.pixelSize: 13
                        color: "#b87057"
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.goToLegal()
                        }
                    }
                }

                // ── HANDWRITTEN TITLE ────────────────────────────────
                Text {
                    width: parent.width
                    text: "updates page of the service"
                    font.family: "Georgia"
                    font.pixelSize: 26
                    font.italic: true
                    color: "#b87057"
                    horizontalAlignment: Text.AlignHCenter
                }

                // ── MAIN TITLE ───────────────────────────────────────
                Text {
                    width: parent.width
                    text: "Updates"
                    font.family: "Georgia"
                    font.pixelSize: 36
                    color: "#2c1f14"
                    horizontalAlignment: Text.AlignHCenter
                }

                // ── DATE ─────────────────────────────────────────────
                Text {
                    width: parent.width
                    text: "Last updated: 9 May 2026"
                    font.pixelSize: 13
                    color: "#a89880"
                    horizontalAlignment: Text.AlignHCenter
                }

                // ── SECTION 15 ───────────────────────────────────────
                Column {
                    width: parent.width
                    spacing: 8

                    Text {
                        width: parent.width
                        text: "15. Changes to these terms"
                        font.family: "Georgia"
                        font.pixelSize: 22
                        color: "#2c1f14"
                        wrapMode: Text.WordWrap
                    }

                    Text {
                        width: parent.width
                        text: "We may update these terms at any time. Notice of all changes will be posted on the Updates page of the service. We will not send email notifications for updates.\n\nFor direct enquiries about changes, contact: rcsc.erikaaversa@outlook.com"
                        font.pixelSize: 14
                        color: "#7a6a5a"
                        wrapMode: Text.WordWrap
                        lineHeight: 1.7
                    }

                    // Email link
                    Text {
                        text: "rcsc.erikaaversa@outlook.com"
                        font.pixelSize: 14
                        color: "#b87057"
                        font.underline: true
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Qt.openUrlExternally("mailto:rcsc.erikaaversa@outlook.com")
                        }
                    }
                }

                // ── DIVIDER ──────────────────────────────────────────
                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#e8ddd4"
                }

                // ── BACK BUTTON ──────────────────────────────────────
                Rectangle {
                    width: parent.width
                    height: 52
                    radius: 10
                    color: backMouse.containsMouse ? "#e8ddd4" : "#ffffff"
                    border.color: "#e8ddd4"
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text: "Back home"
                        font.pixelSize: 15
                        color: "#2c1f14"
                    }

                    MouseArea {
                        id: backMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.goBack()
                    }
                }

                Item { width: parent.width; height: 48 }
            }
        }
    }
}
