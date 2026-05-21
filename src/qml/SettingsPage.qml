import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    property string userId: ""
    property string successorId: ""
    property var crewMembers: []
    signal goBack()
    signal signedOut()

    property bool busy: false
    property bool deleting: false

    function load() {
        SettingsService.loadProfile(root.userId)
        SettingsService.loadActiveCrew(root.userId)
    }

    Component.onCompleted: {
        if (root.userId.length > 0) root.load()
    }

    Connections {
        target: SettingsService
        function onProfileLoaded(profile) {
            nicknameField.text = profile.nickname || ""
            fullNameField.text = profile.full_name || ""
            root.successorId   = profile.successor_user_id || ""
        }
        function onProfileLoadFailed(error) {
            statusText.color = "#E24B4A"
            statusText.text  = error
        }
        function onCrewLoaded(data) { root.crewMembers = data }
        function onProfileSaved() {
            root.busy = false
            statusText.color = "#1D9E75"
            statusText.text  = "Saved."
        }
        function onProfileSaveFailed(error) {
            root.busy = false
            statusText.color = "#E24B4A"
            statusText.text  = error
        }
        function onSuccessorSaved() {
            root.busy = false
            statusText.color = "#1D9E75"
            statusText.text  = "Admin set."
        }
        function onSuccessorSaveFailed(error) {
            root.busy = false
            statusText.color = "#E24B4A"
            statusText.text  = error
        }
    }

    Connections {
        target: Auth
        function onAccountDeleted()           { root.deleting = false; root.signedOut() }
        function onAccountDeleteFailed(error) {
            root.deleting = false
            statusText.color = "#E24B4A"
            statusText.text  = error
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
                spacing: 32
                topPadding: 40

                Text {
                    id: statusText
                    width: parent.width
                    text: ""
                    font.pixelSize: 13
                    color: "#1D9E75"
                    wrapMode: Text.WordWrap
                    visible: text.length > 0
                }
                // ── YOUR NAME ─────────────────────────────────────────
                Column {
                    width: parent.width
                    spacing: 16

                    Column {
                        width: parent.width
                        spacing: 4
                        Text { text: "your name"; font.family: "Georgia"; font.pixelSize: 22; font.italic: true; color: "#b87057" }
                        Text { text: "How you appear"; font.family: "Georgia"; font.pixelSize: 28; color: "#2c1f14" }
                    }

                    Column {
                        width: parent.width
                        spacing: 6
                        Text { text: "Nickname (used in letters)"; font.pixelSize: 13; color: "#7a6a5a" }
                        Rectangle {
                            width: parent.width; height: 48; radius: 8; color: "#ffffff"
                            border.color: nicknameField.activeFocus ? "#b87057" : "#e8ddd4"; border.width: 1
                            TextInput {
                                id: nicknameField
                                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: 12; rightMargin: 12 }
                                font.pixelSize: 15; color: "#2c1f14"
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: 6
                        Text { text: "Full name (for the record)"; font.pixelSize: 13; color: "#7a6a5a" }
                        Rectangle {
                            width: parent.width; height: 48; radius: 8; color: "#ffffff"
                            border.color: fullNameField.activeFocus ? "#b87057" : "#e8ddd4"; border.width: 1
                            TextInput {
                                id: fullNameField
                                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: 12; rightMargin: 12 }
                                font.pixelSize: 15; color: "#2c1f14"
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width; height: 48; radius: 8
                        color: root.busy ? "#d4a898" : (saveMouse.containsMouse ? "#a0614a" : "#b87057")
                        opacity: root.busy ? 0.6 : 1.0
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Text { anchors.centerIn: parent; text: root.busy ? "..." : "Save"; font.pixelSize: 15; font.weight: Font.Medium; color: "#ffffff" }
                        MouseArea {
                            id: saveMouse; anchors.fill: parent; hoverEnabled: true; enabled: !root.busy
                            onClicked: {
                                root.busy = true; statusText.text = ""
                                SettingsService.saveProfile(root.userId, fullNameField.text.trim(), nicknameField.text.trim())
                            }
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: "#e8ddd4" }

                // ── YOUR ADMIN ────────────────────────────────────────
                Column {
                    width: parent.width
                    spacing: 16

                    Column {
                        width: parent.width
                        spacing: 4
                        Text { text: "your admin"; font.family: "Georgia"; font.pixelSize: 22; font.italic: true; color: "#b87057" }
                        Text { text: "Choose your admin"; font.family: "Georgia"; font.pixelSize: 24; color: "#2c1f14"; wrapMode: Text.WordWrap; width: parent.width }
                        Text {
                            width: parent.width
                            text: "Your admin is one of your active family members. They can manage your family and close the space if needed."
                            font.pixelSize: 13; color: "#7a6a5a"; wrapMode: Text.WordWrap; lineHeight: 1.6
                        }
                    }

                    Text {
                        visible: root.crewMembers.length === 0
                        text: "Add active family members first, then choose your admin."
                        font.pixelSize: 13; color: "#a89880"; font.italic: true; width: parent.width; wrapMode: Text.WordWrap
                    }

                    Column {
                        width: parent.width; spacing: 12
                        visible: root.crewMembers.length > 0

                        Repeater {
                            model: root.crewMembers
                            Rectangle {
                                width: parent.width; height: 52; radius: 8
                                color: root.successorId === modelData.member_user_id ? "#fdf0eb" : "#ffffff"
                                border.color: root.successorId === modelData.member_user_id ? "#b87057" : "#e8ddd4"; border.width: 1
                                Behavior on color { ColorAnimation { duration: 150 } }
                                Row {
                                    anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: 16; rightMargin: 16 }
                                    spacing: 12
                                    Rectangle {
                                        width: 18; height: 18; radius: 9
                                        color: root.successorId === modelData.member_user_id ? "#b87057" : "transparent"
                                        border.color: root.successorId === modelData.member_user_id ? "#b87057" : "#a89880"; border.width: 2
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text { text: modelData.member_name; font.pixelSize: 15; color: "#2c1f14"; anchors.verticalCenter: parent.verticalCenter }
                                }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.successorId = modelData.member_user_id }
                            }
                        }

                        Rectangle {
                            width: parent.width; height: 48; radius: 8
                            color: (root.busy || root.successorId.length === 0) ? "#d4a898" : (successorMouse.containsMouse ? "#a0614a" : "#b87057")
                            opacity: (root.busy || root.successorId.length === 0) ? 0.6 : 1.0
                            Behavior on color { ColorAnimation { duration: 150 } }
                            Text { anchors.centerIn: parent; text: root.busy ? "..." : "Save"; font.pixelSize: 15; font.weight: Font.Medium; color: "#ffffff" }
                            MouseArea {
                                id: successorMouse; anchors.fill: parent; hoverEnabled: true
                                enabled: !root.busy && root.successorId.length > 0
                                onClicked: { root.busy = true; statusText.text = ""; SettingsService.saveSuccessor(root.successorId) }
                            }
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: "#e8ddd4" }
                // ── DELETE ACCOUNT ────────────────────────────────────
                Column {
                    width: parent.width
                    spacing: 16

                    Column {
                        width: parent.width
                        spacing: 4
                        Text { text: "your account"; font.family: "Georgia"; font.pixelSize: 22; font.italic: true; color: "#b87057" }
                        Text { text: "Delete my account"; font.family: "Georgia"; font.pixelSize: 24; color: "#2c1f14" }
                        Text {
                            width: parent.width
                            text: "This will permanently remove your account, your family, your content, and your conversations. This cannot be undone."
                            font.pixelSize: 13; color: "#7a6a5a"; wrapMode: Text.WordWrap; lineHeight: 1.6
                        }
                    }

                    Rectangle {
                        width: parent.width; height: 48; radius: 8
                        color: "transparent"; border.color: "#E24B4A"; border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text: root.deleting ? "Deleting…" : "Delete my account"
                            font.pixelSize: 15
                            color: deleteMouse.containsMouse ? "#ffffff" : "#E24B4A"
                        }
                        Rectangle {
                            anchors.fill: parent; radius: 8; z: -1
                            color: deleteMouse.containsMouse ? "#E24B4A" : "transparent"
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                        MouseArea {
                            id: deleteMouse; anchors.fill: parent; hoverEnabled: true; enabled: !root.deleting
                            onClicked: deleteDialog.open()
                        }
                    }

                    Rectangle {
                        width: parent.width; height: 48; radius: 8
                        color: signOutMouse.containsMouse ? "#e8ddd4" : "#ffffff"
                        border.color: "#e8ddd4"; border.width: 1
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Text { anchors.centerIn: parent; text: "Sign out"; font.pixelSize: 15; color: "#2c1f14" }
                        MouseArea {
                            id: signOutMouse; anchors.fill: parent; hoverEnabled: true
                            onClicked: { Auth.signOut(); root.signedOut() }
                        }
                    }
                }

                // ── BACK BUTTON ──────────────────────────────────────
                Rectangle {
                    width: parent.width; height: 52; radius: 10
                    color: backMouse.containsMouse ? "#e8ddd4" : "#ffffff"
                    border.color: "#e8ddd4"; border.width: 1
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Text { anchors.centerIn: parent; text: "Back home"; font.pixelSize: 15; color: "#2c1f14" }
                    MouseArea {
                        id: backMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: root.goBack()
                    }
                }

                Item { width: parent.width; height: 48 }
            }
        }
    }

    // ── DELETE DIALOG ─────────────────────────────────────────────────
    Rectangle {
        id: deleteDialog
        anchors.fill: parent; color: "#000000"; opacity: 0; visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        function open()  { deleteDialog.opacity = 0.5; deleteDialogBox.opacity = 1 }
        function close() { deleteDialog.opacity = 0;   deleteDialogBox.opacity = 0 }
        MouseArea { anchors.fill: parent; onClicked: deleteDialog.close() }
    }

    Rectangle {
        id: deleteDialogBox
        anchors.centerIn: parent
        width: Math.min(parent.width - 48, 360)
        height: deleteDialogCol.implicitHeight + 48
        radius: 16; color: "#ffffff"; opacity: 0; visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 200 } }

        Column {
            id: deleteDialogCol
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 24 }
            spacing: 16

            Text {
                width: parent.width
                text: "Permanently delete your account and all your data?\n\nThis cannot be undone."
                font.pixelSize: 15; color: "#2c1f14"; wrapMode: Text.WordWrap; lineHeight: 1.6
            }

            Rectangle {
                width: parent.width; height: 48; radius: 8
                color: confirmMouse.containsMouse ? "#c0392b" : "#E24B4A"
                Behavior on color { ColorAnimation { duration: 150 } }
                Text { anchors.centerIn: parent; text: "Yes, delete everything"; font.pixelSize: 14; font.weight: Font.Medium; color: "#ffffff" }
                MouseArea {
                    id: confirmMouse; anchors.fill: parent; hoverEnabled: true
                    onClicked: { deleteDialog.close(); root.deleting = true; statusText.text = ""; Auth.deleteAccount() }
                }
            }

            Rectangle {
                width: parent.width; height: 48; radius: 8
                color: cancelMouse.containsMouse ? "#e8ddd4" : "#ffffff"
                border.color: "#e8ddd4"; border.width: 1
                Behavior on color { ColorAnimation { duration: 150 } }
                Text { anchors.centerIn: parent; text: "Cancel"; font.pixelSize: 14; color: "#2c1f14" }
                MouseArea { id: cancelMouse; anchors.fill: parent; hoverEnabled: true; onClicked: deleteDialog.close() }
            }
        }
    }
}