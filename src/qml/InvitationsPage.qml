
import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    property string userId: ""
    signal openMemories(string ownerId)
    signal goBack()

    property bool loading: true
    property var memorials: []

    function load() {
        root.loading = true
        MemorialService.loadMemorials(root.userId)
    }

    Component.onCompleted: {
        if (root.userId.length > 0) root.load()
    }

    Connections {
        target: MemorialService
        function onMemorialsLoaded(data) {
            root.memorials = data
            root.loading = false
        }
        function onMemorialsLoadFailed(error) {
            root.loading = false
            statusText.text = error
        }
        function onCrewLeft() {
            root.load()
        }
    }

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
                topPadding: 40

                // ── HEADER ───────────────────────────────────────────
                Column {
                    width: parent.width
                    spacing: 8

                    Text {
                        text: "invitations"
                        font.family: "Georgia"
                        font.pixelSize: 22
                        font.italic: true
                        color: "#b87057"
                    }

                    Text {
                        text: "Spaces you're part of"
                        font.family: "Georgia"
                        font.pixelSize: 32
                        color: "#2c1f14"
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }

                    Text {
                        width: parent.width
                        text: "People who chose to bring you in. Content is shared securely through private invitations."
                        font.pixelSize: 14
                        color: "#7a6a5a"
                        wrapMode: Text.WordWrap
                        lineHeight: 1.6
                    }
                }

                // ── STATUS TEXT ──────────────────────────────────────
                Text {
                    id: statusText
                    width: parent.width
                    text: ""
                    font.pixelSize: 14
                    color: "#E24B4A"
                    wrapMode: Text.WordWrap
                    visible: text.length > 0
                }

                // ── LOADING ──────────────────────────────────────────
                Text {
                    visible: root.loading
                    text: "Looking…"
                    font.pixelSize: 14
                    color: "#a89880"
                    font.italic: true
                }

                // ── EMPTY STATE ──────────────────────────────────────
                Text {
                    visible: !root.loading && root.memorials.length === 0
                    text: "Nobody has invited you yet."
                    font.pixelSize: 14
                    color: "#a89880"
                    font.italic: true
                }

                // ── MEMORIAL LIST ────────────────────────────────────
                Column {
                    width: parent.width
                    spacing: 12
                    visible: !root.loading && root.memorials.length > 0

                    Repeater {
                        model: root.memorials

                        Rectangle {
                            width: parent.width
                            height: rowContent.implicitHeight + 32
                            radius: 12
                            color: "#ffffff"
                            border.color: "#e8ddd4"
                            border.width: 1

                            Row {
                                id: rowContent
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    verticalCenter: parent.verticalCenter
                                    leftMargin: 16
                                    rightMargin: 16
                                }
                                spacing: 12

                                Text {
                                    text: modelData.owner_name
                                    font.family: "Georgia"
                                    font.pixelSize: 20
                                    color: "#2c1f14"
                                    width: parent.width - 160
                                    elide: Text.ElideRight
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Rectangle {
                                    width: 70
                                    height: 36
                                    radius: 8
                                    color: openMouse.containsMouse ? "#a0614a" : "#b87057"
                                    anchors.verticalCenter: parent.verticalCenter
                                    Behavior on color { ColorAnimation { duration: 150 } }

                                    Text {
                                        anchors.centerIn: parent
                                        text: "Open"
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                        color: "#ffffff"
                                    }

                                    MouseArea {
                                        id: openMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: root.openMemories(modelData.owner_id)
                                    }
                                }

                                Rectangle {
                                    width: 60
                                    height: 36
                                    radius: 8
                                    color: leaveMouse.containsMouse ? "#fdf0eb" : "#ffffff"
                                    border.color: "#e8ddd4"
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Behavior on color { ColorAnimation { duration: 150 } }

                                    Text {
                                        anchors.centerIn: parent
                                        text: "leave"
                                        font.pixelSize: 12
                                        color: leaveMouse.containsMouse ? "#E24B4A" : "#a89880"
                                    }

                                    MouseArea {
                                        id: leaveMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: leaveDialog.open(modelData)
                                    }
                                }
                            }
                        }
                    }
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


    // ── LEAVE CONFIRMATION DIALOG ─────────────────────────────────────
    Rectangle {
        id: leaveDialog
        anchors.fill: parent
        color: "#000000"
        opacity: 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 200 } }

        property var memorial: null

        function open(m) {
            leaveDialog.memorial = m
            leaveDialogName.text = "Leave " + m.owner_name + "'s family space?\n\nYour letters tied to this memorial will be deleted."
            leaveDialog.opacity = 0.5
            leaveDialogBox.opacity = 1
        }

        function close() {
            leaveDialog.opacity = 0
            leaveDialogBox.opacity = 0
        }

        MouseArea {
            anchors.fill: parent
            onClicked: leaveDialog.close()
        }
    }

    Rectangle {
        id: leaveDialogBox
        anchors.centerIn: parent
        width: Math.min(parent.width - 48, 360)
        height: dialogColumn.implicitHeight + 48
        radius: 16
        color: "#ffffff"
        opacity: 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 200 } }

        Column {
            id: dialogColumn
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 24
            }
            spacing: 16

            Text {
                id: leaveDialogName
                width: parent.width
                text: ""
                font.pixelSize: 15
                color: "#2c1f14"
                wrapMode: Text.WordWrap
                lineHeight: 1.6
            }

            Rectangle {
                width: parent.width
                height: 48
                radius: 8
                color: confirmLeaveMouse.containsMouse ? "#c0392b" : "#E24B4A"
                Behavior on color { ColorAnimation { duration: 150 } }

                Text {
                    anchors.centerIn: parent
                    text: "Yes, leave"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: "#ffffff"
                }

                MouseArea {
                    id: confirmLeaveMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        MemorialService.leaveCrew(leaveDialog.memorial.owner_id)
                        leaveDialog.close()
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 48
                radius: 8
                color: cancelMouse.containsMouse ? "#e8ddd4" : "#ffffff"
                border.color: "#e8ddd4"
                border.width: 1
                Behavior on color { ColorAnimation { duration: 150 } }

                Text {
                    anchors.centerIn: parent
                    text: "Cancel"
                    font.pixelSize: 14
                    color: "#2c1f14"
                }

                MouseArea {
                    id: cancelMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: leaveDialog.close()
                }
            }
        }
    }
}
}
}
}
