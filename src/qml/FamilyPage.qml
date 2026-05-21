import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    property string userId: ""
    signal goBack()

    property bool loading: true
    property bool busy: false
    property var rows: []
    property var links: ({})
    property int maxSlots: 5

    property string nameInput: ""
    property string emailInput: ""

    function remaining() { return maxSlots - rows.length }

    function linkFor(token) {
        return "https://nevhricmmxnxeeqaagsn.supabase.co/invite/" + token
    }

    function emailTemplate(memberName, link) {
        return "Subject: I made something for you\n\nDear " + (memberName || "[Name]") + ",\n\nI made something I want you to have access to.\n\nIt's a small private space — just for the people closest to me, and you are one of them.\n\nTo get in, just create an account using this link (it expires in 72 hours):\n\n👉 " + link + "\n\nLove,"
    }

    function copyToClipboard(text) {
        clipHelper.text = text
        clipHelper.selectAll()
        clipHelper.copy()
    }

    TextEdit { id: clipHelper; visible: false; width: 0; height: 0 }

    function load() {
        root.loading = true
        CrewService.loadCrew(root.userId)
    }

    Component.onCompleted: {
        if (root.userId.length > 0) root.load()
    }

    Connections {
        target: CrewService
        function onCrewLoaded(data, linkData) {
            root.rows = data
            root.links = linkData
            root.loading = false
        }
        function onCrewLoadFailed(error) {
            root.loading = false
            statusText.text = error
        }
        function onInviteCreated() {
            root.busy = false
            root.nameInput = ""
            root.emailInput = ""
            statusText.color = "#1D9E75"
            statusText.text = "Invitation link ready (valid 72 hours)."
            root.load()
        }
        function onInviteCreateFailed(error) {
            root.busy = false
            statusText.color = "#E24B4A"
            statusText.text = error
        }
        function onMemberRemoved() {
            root.load()
        }
        function onMemberRemoveFailed(error) {
            statusText.color = "#E24B4A"
            statusText.text = error
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
                        text: "your family"
                        font.family: "Georgia"
                        font.pixelSize: 22
                        font.italic: true
                        color: "#b87057"
                    }

                    Text {
                        text: "Up to 5 family members"
                        font.family: "Georgia"
                        font.pixelSize: 32
                        color: "#2c1f14"
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }

                    Text {
                        width: parent.width
                        text: "Invite up to 5 loved ones. Pending invites count toward your 5 slots; expired (72h) unused links free their slot automatically."
                        font.pixelSize: 14
                        color: "#7a6a5a"
                        wrapMode: Text.WordWrap
                        lineHeight: 1.6
                    }
                }

                // ── STATUS ───────────────────────────────────────────
                Text {
                    id: statusText
                    width: parent.width
                    text: ""
                    font.pixelSize: 13
                    color: "#1D9E75"
                    wrapMode: Text.WordWrap
                    visible: text.length > 0
                }

                // ── CREATE INVITATION FORM ────────────────────────────
                Rectangle {
                    width: parent.width
                    height: formColumn.implicitHeight + 40
                    radius: 12
                    color: "#ffffff"
                    border.color: "#e8ddd4"
                    border.width: 1

                    Column {
                        id: formColumn
                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                            margins: 20
                        }
                        spacing: 12

                        // Name field
                        Rectangle {
                            width: parent.width
                            height: 48
                            radius: 8
                            color: "#f5ede4"
                            border.color: nameField.activeFocus ? "#b87057" : "transparent"
                            border.width: 1

                            Text {
                                z: 0
                                anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 12 }
                                text: "Their name"
                                color: "#a89880"
                                font.pixelSize: 14
                                visible: nameField.text.length === 0 && !nameField.activeFocus
                            }
                            TextInput {
                                id: nameField
                                z: 1
                                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: 12; rightMargin: 12 }
                                font.pixelSize: 14
                                color: "#2c1f14"
                                text: root.nameInput
                                onTextChanged: root.nameInput = text
                            }
                        }

                        // Email field
                        Rectangle {
                            width: parent.width
                            height: 48
                            radius: 8
                            color: "#f5ede4"
                            border.color: emailField.activeFocus ? "#b87057" : "transparent"
                            border.width: 1

                            Text {
                                z: 0
                                anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 12 }
                                text: "Their email (optional)"
                                color: "#a89880"
                                font.pixelSize: 14
                                visible: emailField.text.length === 0 && !emailField.activeFocus
                            }
                            TextInput {
                                id: emailField
                                z: 1
                                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: 12; rightMargin: 12 }
                                font.pixelSize: 14
                                color: "#2c1f14"
                                inputMethodHints: Qt.ImhEmailCharactersOnly
                                text: root.emailInput
                                onTextChanged: root.emailInput = text
                            }
                        }

                        // Slots + button row
                        Row {
                            width: parent.width
                            spacing: 12

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: root.remaining() > 0 ? root.remaining() + " of 5 slots left" : "All 5 slots taken."
                                font.pixelSize: 12
                                color: "#a89880"
                                width: parent.width - 160
                                wrapMode: Text.WordWrap
                            }

                            Rectangle {
                                width: 148
                                height: 40
                                radius: 8
                                color: (root.busy || root.remaining() <= 0) ? "#d4a898" : (createMouse.containsMouse ? "#a0614a" : "#b87057")
                                opacity: (root.busy || root.remaining() <= 0) ? 0.6 : 1.0
                                Behavior on color { ColorAnimation { duration: 150 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: root.busy ? "..." : "Create invitation"
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                    color: "#ffffff"
                                }

                                MouseArea {
                                    id: createMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    enabled: !root.busy && root.remaining() > 0
                                    onClicked: {
                                        if (root.nameInput.trim().length === 0) {
                                            statusText.color = "#E24B4A"
                                            statusText.text = "Please enter their name."
                                            return
                                        }
                                        root.busy = true
                                        statusText.text = ""
                                        CrewService.createInvite(root.nameInput.trim(), root.emailInput.trim())
                                    }
                                }
                            }
                        }
                    }
                }

                // ── LOADING ──────────────────────────────────────────
                Text {
                    visible: root.loading
                    text: "Looking…"
                    font.pixelSize: 14
                    color: "#a89880"
                    font.italic: true
                }

                // ── CREW LIST ─────────────────────────────────────────
                Column {
                    width: parent.width
                    spacing: 12
                    visible: !root.loading

                    Repeater {
                        model: root.rows

                        Rectangle {
                            width: parent.width
                            radius: 12
                            color: "#ffffff"
                            border.color: "#e8ddd4"
                            border.width: 1
                            height: crewItemColumn.implicitHeight + 32

                            Column {
                                id: crewItemColumn
                                anchors {
                                    top: parent.top
                                    left: parent.left
                                    right: parent.right
                                    margins: 16
                                }
                                spacing: 10

                                // Name + status + remove
                                Row {
                                    width: parent.width
                                    spacing: 8

                                    Column {
                                        width: parent.width - 70
                                        spacing: 4

                                        Row {
                                            spacing: 8

                                            Text {
                                                text: modelData.member_name
                                                font.family: "Georgia"
                                                font.pixelSize: 18
                                                color: "#2c1f14"
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                            Rectangle {
                                                height: 20
                                                width: statusLabel.implicitWidth + 12
                                                radius: 10
                                                color: modelData.status === "active" ? "#e8f5e9" : "#f5f0e8"
                                                anchors.verticalCenter: parent.verticalCenter

                                                Text {
                                                    id: statusLabel
                                                    anchors.centerIn: parent
                                                    text: modelData.status
                                                    font.pixelSize: 10
                                                    color: modelData.status === "active" ? "#1D9E75" : "#a89880"
                                                }
                                            }
                                        }

                                        Text {
                                            text: modelData.member_email || ""
                                            font.pixelSize: 11
                                            color: "#a89880"
                                            visible: (modelData.member_email || "").length > 0
                                        }
                                    }

                                    Text {
                                        text: modelData.status === "active" ? "remove" : "cancel"
                                        font.pixelSize: 12
                                        color: removeMouse.containsMouse ? "#E24B4A" : "#a89880"
                                        anchors.verticalCenter: parent.verticalCenter

                                        MouseArea {
                                            id: removeMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: removeDialog.open(modelData)
                                        }
                                    }
                                }

                                // Pending invite link section
                                Column {
                                    width: parent.width
                                    spacing: 8
                                    visible: modelData.status === "pending" && root.links[modelData.id] !== undefined

                                    Text {
                                        text: root.links[modelData.id] ? "Expires " + root.links[modelData.id].expires_at : ""
                                        font.pixelSize: 11
                                        color: "#a89880"
                                    }

                                    // Link + copy button
                                    Row {
                                        width: parent.width
                                        spacing: 8

                                        Rectangle {
                                            width: parent.width - 80
                                            height: 36
                                            radius: 8
                                            color: "#f5ede4"
                                            border.color: "#e8ddd4"
                                            border.width: 1

                                            Text {
                                                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: 8; rightMargin: 8 }
                                                text: root.links[modelData.id] ? root.linkFor(root.links[modelData.id].token) : ""
                                                font.pixelSize: 10
                                                color: "#7a6a5a"
                                                elide: Text.ElideRight
                                                font.family: "monospace"
                                            }
                                        }

                                        Rectangle {
                                            width: 68
                                            height: 36
                                            radius: 8
                                            color: copyMouse.containsMouse ? "#e8ddd4" : "#ffffff"
                                            border.color: "#e8ddd4"
                                            border.width: 1
                                            Behavior on color { ColorAnimation { duration: 120 } }

                                            Text {
                                                anchors.centerIn: parent
                                                text: "Copy"
                                                font.pixelSize: 12
                                                color: "#2c1f14"
                                            }

                                            MouseArea {
                                                id: copyMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                onClicked: {
                                                    if (modelData && root.links && root.links[modelData.id]) {
                                                        root.copyToClipboard(root.linkFor(root.links[modelData.id].token))
                                                        statusText.color = "#1D9E75"
                                                        statusText.text = "Link copied."
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    // Copy full message
                                    Text {
                                        text: "Copy the full message to send"
                                        font.pixelSize: 12
                                        color: msgMouse.containsMouse ? "#a0614a" : "#b87057"
                                        font.underline: true

                                        MouseArea {
                                            id: msgMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (modelData && root.links && root.links[modelData.id]) {
                                                    root.copyToClipboard(root.emailTemplate(
                                                        modelData.member_name,
                                                        root.linkFor(root.links[modelData.id].token)
                                                    ))
                                                    statusText.color = "#1D9E75"
                                                    statusText.text = "Message copied."
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // ── EMPTY SLOTS ───────────────────────────────────
                    Repeater {
                        model: Math.max(0, root.maxSlots - root.rows.length)

                        Rectangle {
                            width: parent.width
                            height: 56
                            radius: 12
                            color: "transparent"
                            border.color: "#e8ddd4"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "empty seat"
                                font.family: "Georgia"
                                font.pixelSize: 16
                                font.italic: true
                                color: "#c4b9ae"
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

                Item { width: parent.width; height: 48 }
            }
        }
    }

    // ── REMOVE CONFIRMATION DIALOG ────────────────────────────────────
    Rectangle {
        id: removeDialog
        anchors.fill: parent
        color: "#000000"
        opacity: 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 200 } }

        property var member: null

        function open(m) {
            removeDialog.member = m
            removeDialogText.text = m.status === "active"
                ? "Remove " + m.member_name + " from your family? Their letters tied to your space will be deleted."
                : "Cancel this invitation for " + m.member_name + "?"
            removeDialog.opacity = 0.5
            removeDialogBox.opacity = 1
        }

        function close() {
            removeDialog.opacity = 0
            removeDialogBox.opacity = 0
        }

        MouseArea {
            anchors.fill: parent
            onClicked: removeDialog.close()
        }
    }

    Rectangle {
        id: removeDialogBox
        anchors.centerIn: parent
        width: Math.min(parent.width - 48, 360)
        height: removeDialogColumn.implicitHeight + 48
        radius: 16
        color: "#ffffff"
        opacity: 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 200 } }

        Column {
            id: removeDialogColumn
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 24
            }
            spacing: 16

            Text {
                id: removeDialogText
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
                color: confirmRemoveMouse.containsMouse ? "#c0392b" : "#E24B4A"
                Behavior on color { ColorAnimation { duration: 150 } }

                Text {
                    anchors.centerIn: parent
                    text: "Yes, remove"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: "#ffffff"
                }

                MouseArea {
                    id: confirmRemoveMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        CrewService.removeMember(removeDialog.member.id)
                        removeDialog.close()
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 48
                radius: 8
                color: cancelRemoveMouse.containsMouse ? "#e8ddd4" : "#ffffff"
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
                    id: cancelRemoveMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: removeDialog.close()
                }
            }
        }
    }
}
