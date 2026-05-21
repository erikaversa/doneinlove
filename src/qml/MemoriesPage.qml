import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.platform 1.1 as Platform

Item {
    id: root

    // Properties
    property string ownerId: ""
    property string userId: ""
    property string ownerName: ""
    property bool isOwnSpace: ownerId === userId
    property string currentTab: "notes"
    property var items: []
    property var crewMembers: []
    property bool loading: false
    property bool busy: false

    signal goBack()
    signal goToSettings()
    signal goToFamily()
    signal openAiChat()

    // Load content when tab or owner changes
    function loadContent() {
        root.loading = true
        if (root.currentTab === "chat") {
            root.loading = false
            return
        }
        var kind = root.currentTab === "notes" ? "note"
                 : root.currentTab === "letters" ? "letter"
                 : root.currentTab === "photos" ? "photo"
                 : "recording"
        ContentService.fetchContent(root.ownerId, kind)
    }

    function loadOwnerProfile() {
        ContentService.fetchContent(root.ownerId, "note")
    }

    onCurrentTabChanged: root.loadContent()

    Connections {
        target: ContentService
        function onContentLoaded(data) {
            root.ownerName = data.owner_name || root.ownerName
            root.items     = data.items || []
            root.loading   = false
        }
        function onContentLoadFailed(error) {
            root.loading = false
            spaceStatus.color = "#E24B4A"
            spaceStatus.text  = error
        }
        function onItemSaved(item) {
            root.busy = false
            spaceStatus.color = "#1D9E75"
            spaceStatus.text  = "Saved."
            titleField.text   = ""
            bodyField.text    = ""
            captionField.text = ""
            root.loadContent()
        }
        function onItemSaveFailed(error) {
            root.busy = false
            spaceStatus.color = "#E24B4A"
            spaceStatus.text  = error
        }
        function onItemDeleted(id) {
            spaceStatus.color = "#1D9E75"
            spaceStatus.text  = "Deleted."
            root.loadContent()
        }
    }

    Connections {
        target: CrewService
        function onCrewLoaded(data, linkData) {
            root.crewMembers = data.filter(function(m) { return m.status === "active" })
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#f5ede4"

        Column {
            anchors.fill: parent
            spacing: 0

            // ── HEADER ───────────────────────────────────────────────
            Rectangle {
                width: parent.width
                height: 80
                color: "#f5ede4"
                border.color: "#e8ddd4"
                border.width: 1

                Column {
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: 24
                        rightMargin: 24
                    }
                    spacing: 4

                    Text {
                        text: root.isOwnSpace ? "your space" : "a space"
                        font.family: "Georgia"
                        font.pixelSize: 14
                        font.italic: true
                        color: "#b87057"
                    }

                    Text {
                        text: root.isOwnSpace ? "Our memories" : root.ownerName
                        font.family: "Georgia"
                        font.pixelSize: 24
                        color: "#2c1f14"
                        elide: Text.ElideRight
                        width: parent.width
                    }
                }

                // Back button
                Rectangle {
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        rightMargin: 16
                    }
                    width: 100
                    height: 34
                    radius: 8
                    color: backHeaderMouse.containsMouse ? "#e8ddd4" : "#ffffff"
                    border.color: "#e8ddd4"
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Text {
                        anchors.centerIn: parent
                        text: root.isOwnSpace ? "Back home" : "← Back"
                        font.pixelSize: 13
                        color: "#2c1f14"
                    }
                    MouseArea {
                        id: backHeaderMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.goBack()
                    }
                }
            }

            // ── TABS ─────────────────────────────────────────────────
            Rectangle {
                width: parent.width
                height: 44
                color: "#ffffff"
                border.color: "#e8ddd4"
                border.width: 1

                Row {
                    anchors.fill: parent

                    Repeater {
                        model: root.isOwnSpace
                            ? ["notes", "letters", "photos", "audio", "chat"]
                            : ["notes", "photos", "audio"]

                        Rectangle {
                            width: root.isOwnSpace ? parent.width / 5 : parent.width / 3
                            height: parent.height
                            color: "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: modelData === "notes"   ? "Notes"
                                    : modelData === "letters" ? "Letters"
                                    : modelData === "photos"  ? "Photos"
                                    : modelData === "audio"   ? "Audio"
                                    : "Chat"
                                font.pixelSize: 12
                                font.weight: root.currentTab === modelData ? Font.Medium : Font.Normal
                                color: root.currentTab === modelData ? "#b87057" : "#a89880"
                            }

                            Rectangle {
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: parent.width - 8
                                height: 2
                                radius: 1
                                color: "#b87057"
                                visible: root.currentTab === modelData
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: root.currentTab = modelData
                            }
                        }
                    }
                }
            }

            // ── STATUS ───────────────────────────────────────────────
            Text {
                id: spaceStatus
                width: parent.width
                text: ""
                font.pixelSize: 13
                color: "#1D9E75"
                wrapMode: Text.WordWrap
                visible: text.length > 0
                leftPadding: 24
                rightPadding: 24
                topPadding: 8
            }
            // ── MAIN CONTENT AREA ─────────────────────────────────────
            Flickable {
                width: parent.width
                height: parent.height - 80 - 44 - (spaceStatus.visible ? spaceStatus.height : 0)
                contentHeight: contentColumn.implicitHeight + 60
                clip: true

                Column {
                    id: contentColumn
                    width: Math.min(parent.width - 48, 640)
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 16
                    topPadding: 24

                    // ── MODE A — CREATE FORM ──────────────────────────
                    // Notes form
                    Rectangle {
                        width: parent.width
                        height: noteFormColumn.implicitHeight + 40
                        radius: 12
                        color: "#ffffff"
                        border.color: "#e8ddd4"
                        border.width: 1
                        visible: root.isOwnSpace && root.currentTab === "notes"

                        Column {
                            id: noteFormColumn
                            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 20 }
                            spacing: 12

                            Rectangle {
                                width: parent.width; height: 48; radius: 8; color: "#f5ede4"
                                border.color: titleField.activeFocus ? "#b87057" : "transparent"; border.width: 1
                                Text {
                                    z: 0; anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 12 }
                                    text: "Title"; color: "#a89880"; font.pixelSize: 14
                                    visible: titleField.text.length === 0 && !titleField.activeFocus
                                }
                                TextInput {
                                    id: titleField; z: 1
                                    anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: 12; rightMargin: 12 }
                                    font.pixelSize: 14; color: "#2c1f14"
                                }
                            }

                            Rectangle {
                                width: parent.width; height: 100; radius: 8; color: "#f5ede4"
                                border.color: bodyField.activeFocus ? "#b87057" : "transparent"; border.width: 1
                                Text {
                                    z: 0; anchors { left: parent.left; top: parent.top; leftMargin: 12; topMargin: 12 }
                                    text: "Write something…"; color: "#a89880"; font.pixelSize: 14
                                    visible: bodyField.text.length === 0 && !bodyField.activeFocus
                                }
                                TextEdit {
                                    id: bodyField; z: 1
                                    anchors { fill: parent; margins: 12 }
                                    font.pixelSize: 14; color: "#2c1f14"
                                    wrapMode: TextEdit.Wrap
                                }
                            }

                            Rectangle {
                                width: parent.width; height: 44; radius: 8
                                color: root.busy ? "#d4a898" : (addNoteMouse.containsMouse ? "#a0614a" : "#b87057")
                                Behavior on color { ColorAnimation { duration: 150 } }
                                Text { anchors.centerIn: parent; text: root.busy ? "..." : "Add note"; font.pixelSize: 14; font.weight: Font.Medium; color: "#ffffff" }
                                MouseArea {
                                    id: addNoteMouse; anchors.fill: parent; hoverEnabled: true; enabled: !root.busy
                                    onClicked: {
                                        if (titleField.text.trim().length === 0) return
                                        root.busy = true
                                        spaceStatus.text = ""
                                        ContentService.saveItem(root.userId, "note", titleField.text.trim(), bodyField.text.trim(), "", "")
                                    }
                                }
                            }
                        }
                    }

                    // Letters form
                    Rectangle {
                        width: parent.width
                        height: letterFormColumn.implicitHeight + 40
                        radius: 12
                        color: "#ffffff"
                        border.color: "#e8ddd4"
                        border.width: 1
                        visible: root.isOwnSpace && root.currentTab === "letters"

                        Column {
                            id: letterFormColumn
                            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 20 }
                            spacing: 12

                            Rectangle {
                                width: parent.width; height: 48; radius: 8; color: "#f5ede4"
                                border.color: letterTitleField.activeFocus ? "#b87057" : "transparent"; border.width: 1
                                Text {
                                    z: 0; anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 12 }
                                    text: "Title of your letter"; color: "#a89880"; font.pixelSize: 14
                                    visible: letterTitleField.text.length === 0 && !letterTitleField.activeFocus
                                }
                                TextInput {
                                    id: letterTitleField; z: 1
                                    anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: 12; rightMargin: 12 }
                                    font.pixelSize: 15; font.family: "Georgia"; color: "#2c1f14"
                                }
                            }

                            // Recipient picker
                            Column {
                                width: parent.width
                                spacing: 8

                                Text { text: "For:"; font.pixelSize: 13; color: "#7a6a5a" }

                                Rectangle {
                                    width: parent.width; height: 44; radius: 8
                                    color: everyoneMouse.containsMouse ? "#fdf0eb" : (letterRecipient.text === "" ? "#fdf0eb" : "#f5ede4")
                                    border.color: letterRecipient.text === "" ? "#b87057" : "#e8ddd4"; border.width: 1
                                    property alias currentRecipient: letterRecipient
                                    Text { anchors.centerIn: parent; text: "Everyone in my family"; font.pixelSize: 13; color: "#2c1f14" }
                                    TextInput { id: letterRecipient; visible: false; text: "" }
                                    MouseArea {
                                        id: everyoneMouse; anchors.fill: parent; hoverEnabled: true
                                        onClicked: letterRecipient.text = ""
                                    }
                                }

                                Repeater {
                                    model: root.crewMembers
                                    Rectangle {
                                        width: parent.width; height: 44; radius: 8
                                        color: memberMouse.containsMouse ? "#fdf0eb" : (letterRecipient.text === modelData.member_user_id ? "#fdf0eb" : "#f5ede4")
                                        border.color: letterRecipient.text === modelData.member_user_id ? "#b87057" : "#e8ddd4"; border.width: 1
                                        Text { anchors.centerIn: parent; text: "For " + modelData.member_name; font.pixelSize: 13; color: "#2c1f14" }
                                        MouseArea {
                                            id: memberMouse; anchors.fill: parent; hoverEnabled: true
                                            onClicked: letterRecipient.text = modelData.member_user_id
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                width: parent.width; height: 160; radius: 8; color: "#f5ede4"
                                border.color: letterBodyField.activeFocus ? "#b87057" : "transparent"; border.width: 1
                                Text {
                                    z: 0; anchors { left: parent.left; top: parent.top; leftMargin: 12; topMargin: 12 }
                                    text: "Dear…"; color: "#a89880"; font.pixelSize: 14; font.family: "Georgia"
                                    visible: letterBodyField.text.length === 0 && !letterBodyField.activeFocus
                                }
                                TextEdit {
                                    id: letterBodyField; z: 1
                                    anchors { fill: parent; margins: 12 }
                                    font.pixelSize: 15; font.family: "Georgia"; color: "#2c1f14"
                                    wrapMode: TextEdit.Wrap
                                }
                            }

                            Rectangle {
                                width: parent.width; height: 44; radius: 8
                                color: root.busy ? "#d4a898" : (saveLetterMouse.containsMouse ? "#a0614a" : "#b87057")
                                Behavior on color { ColorAnimation { duration: 150 } }
                                Text { anchors.centerIn: parent; text: root.busy ? "Saving…" : "Save letter"; font.pixelSize: 14; font.weight: Font.Medium; color: "#ffffff" }
                                MouseArea {
                                    id: saveLetterMouse; anchors.fill: parent; hoverEnabled: true; enabled: !root.busy
                                    onClicked: {
                                        if (letterTitleField.text.trim().length === 0 || letterBodyField.text.trim().length === 0) return
                                        root.busy = true
                                        spaceStatus.text = ""
                                        ContentService.saveItem(root.userId, "letter", letterTitleField.text.trim(), letterBodyField.text.trim(), "", letterRecipient.text)
                                    }
                                }
                            }

                            Text {
                                visible: root.crewMembers.length === 0
                                text: "Tip: invite your family in Family to address letters to a specific person."
                                font.pixelSize: 11; color: "#a89880"; wrapMode: Text.WordWrap; width: parent.width
                            }
                        }
                    }

                    // Photos form
                    Rectangle {
                        width: parent.width
                        height: photoFormColumn.implicitHeight + 40
                        radius: 12; color: "#ffffff"
                        border.color: "#e8ddd4"; border.width: 1
                        visible: root.isOwnSpace && root.currentTab === "photos"

                        Column {
                            id: photoFormColumn
                            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 20 }
                            spacing: 12

                            Rectangle {
                                width: parent.width; height: 48; radius: 8; color: "#f5ede4"
                                border.color: captionField.activeFocus ? "#b87057" : "transparent"; border.width: 1
                                Text {
                                    z: 0; anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 12 }
                                    text: "Caption (optional)"; color: "#a89880"; font.pixelSize: 14
                                    visible: captionField.text.length === 0 && !captionField.activeFocus
                                }
                                TextInput {
                                    id: captionField; z: 1
                                    anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: 12; rightMargin: 12 }
                                    font.pixelSize: 14; color: "#2c1f14"
                                }
                            }

                            Rectangle {
                                width: parent.width; height: 44; radius: 8
                                color: root.busy ? "#d4a898" : (uploadPhotoMouse.containsMouse ? "#a0614a" : "#b87057")
                                Behavior on color { ColorAnimation { duration: 150 } }
                                Text { anchors.centerIn: parent; text: root.busy ? "Uploading…" : "Choose photo"; font.pixelSize: 14; font.weight: Font.Medium; color: "#ffffff" }
                                MouseArea {
                                    id: uploadPhotoMouse; anchors.fill: parent; hoverEnabled: true; enabled: !root.busy
                                    onClicked: photoPicker.open()
                                }
                            }
                        }
                    }

                    // Audio form
                    Rectangle {
                        width: parent.width
                        height: audioFormColumn.implicitHeight + 40
                        radius: 12; color: "#ffffff"
                        border.color: "#e8ddd4"; border.width: 1
                        visible: root.isOwnSpace && root.currentTab === "audio"

                        Column {
                            id: audioFormColumn
                            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 20 }
                            spacing: 12

                            Text { text: "Upload a voicenote"; font.family: "Georgia"; font.pixelSize: 18; color: "#2c1f14" }
                            Text { text: "MP3 or MP4, max 20 MB."; font.pixelSize: 12; color: "#a89880" }

                            Rectangle {
                                width: parent.width; height: 48; radius: 8; color: "#f5ede4"
                                border.color: audioCaptionField.activeFocus ? "#b87057" : "transparent"; border.width: 1
                                Text {
                                    z: 0; anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 12 }
                                    text: "Caption (optional)"; color: "#a89880"; font.pixelSize: 14
                                    visible: audioCaptionField.text.length === 0 && !audioCaptionField.activeFocus
                                }
                                TextInput {
                                    id: audioCaptionField; z: 1
                                    anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: 12; rightMargin: 12 }
                                    font.pixelSize: 14; color: "#2c1f14"
                                }
                            }

                            Rectangle {
                                width: parent.width; height: 44; radius: 8
                                color: root.busy ? "#d4a898" : (uploadAudioMouse.containsMouse ? "#a0614a" : "#b87057")
                                Behavior on color { ColorAnimation { duration: 150 } }
                                Text { anchors.centerIn: parent; text: root.busy ? "Uploading…" : "Choose audio file"; font.pixelSize: 14; font.weight: Font.Medium; color: "#ffffff" }
                                MouseArea {
                                    id: uploadAudioMouse; anchors.fill: parent; hoverEnabled: true; enabled: !root.busy
                                    onClicked: audioPicker.open()
                                }
                            }
                        }
                    }

                    // Chat entry for owner
                    Rectangle {
                        width: parent.width
                        height: chatEntryColumn.implicitHeight + 48
                        radius: 12
                        color: "#ffffff"; border.color: "#e8ddd4"; border.width: 1
                        visible: root.isOwnSpace && root.currentTab === "chat"

                        Column {
                            id: chatEntryColumn
                            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 24 }
                            spacing: 12

                            Text {
                                text: "Chat with Gemini"
                                font.family: "Georgia"; font.pixelSize: 22; color: "#2c1f14"
                            }
                            Text {
                                text: "Ask anything — Gemini is here to help."
                                font.pixelSize: 13; color: "#a89880"; font.italic: true
                                width: parent.width; wrapMode: Text.WordWrap
                            }
                            Rectangle {
                                width: parent.width; height: 44; radius: 8
                                color: openChatMouse.containsMouse ? "#a0614a" : "#b87057"
                                Behavior on color { ColorAnimation { duration: 150 } }
                                Text {
                                    anchors.centerIn: parent
                                    text: "Open AI Chat"
                                    font.pixelSize: 14; font.weight: Font.Medium; color: "#ffffff"
                                }
                                MouseArea {
                                    id: openChatMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.openAiChat()
                                }
                            }
                        }
                    }
                    // ── MODE B — WRITE TO OWNER ───────────────────────
                    // Memories section (shown first in Mode B)
                    Column {
                        width: parent.width
                        spacing: 16
                        visible: !root.isOwnSpace && root.currentTab !== "chat"

                        // Loading
                        Text {
                            visible: root.loading
                            text: "Looking…"
                            font.pixelSize: 14; color: "#a89880"; font.italic: true
                        }

                        // Empty
                        Text {
                            visible: !root.loading && root.items.length === 0
                            text: "Nothing here yet."
                            font.pixelSize: 14; color: "#a89880"; font.italic: true
                        }

                        // Items list
                        Repeater {
                            model: root.items

                            Rectangle {
                                width: parent.width
                                height: itemColumn.implicitHeight + 32
                                radius: 12; color: "#ffffff"
                                border.color: "#e8ddd4"; border.width: 1

                                Column {
                                    id: itemColumn
                                    anchors { top: parent.top; left: parent.left; right: parent.right; margins: 16 }
                                    spacing: 8

                                    Row {
                                        width: parent.width
                                        spacing: 8

                                        Text {
                                            text: modelData.title || modelData.caption || new Date(modelData.created_at).toLocaleDateString()
                                            font.family: "Georgia"; font.pixelSize: 17; color: "#2c1f14"
                                            width: parent.width - (root.isOwnSpace ? 60 : 0)
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            visible: root.isOwnSpace
                                            text: "delete"
                                            font.pixelSize: 11; color: delItemMouse.containsMouse ? "#E24B4A" : "#a89880"
                                            anchors.verticalCenter: parent.verticalCenter
                                            MouseArea {
                                                id: delItemMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                                onClicked: ContentService.deleteItem(modelData.id)
                                            }
                                        }
                                    }

                                    Text {
                                        visible: (modelData.kind === "note" || modelData.kind === "letter") && (modelData.body || "") !== ""
                                        text: modelData.body || ""
                                        font.pixelSize: 14; font.family: modelData.kind === "letter" ? "Georgia" : ""
                                        color: "#7a6a5a"; wrapMode: Text.WordWrap; width: parent.width
                                        lineHeight: 1.6
                                    }

                                    Image {
                                        visible: modelData.kind === "photo" && (modelData.signed_url || "") !== ""
                                        source: modelData.signed_url || ""
                                        width: parent.width; height: width * 0.6
                                        fillMode: Image.PreserveAspectCrop
                                        layer.enabled: true
                                    }
                                }
                            }
                        }
                    }

                    // ── MODE A — OWN CONTENT LIST ─────────────────────
                    Column {
                        width: parent.width
                        spacing: 12
                        visible: root.isOwnSpace && root.currentTab !== "chat"
                        topPadding: 8

                        Text {
                            visible: root.loading
                            text: "Looking…"
                            font.pixelSize: 14; color: "#a89880"; font.italic: true
                        }

                        Text {
                            visible: !root.loading && root.items.length === 0
                            text: "Nothing here yet."
                            font.pixelSize: 14; color: "#a89880"; font.italic: true
                        }

                        Repeater {
                            model: root.items

                            Rectangle {
                                width: parent.width
                                height: ownItemColumn.implicitHeight + 32
                                radius: 12; color: "#ffffff"
                                border.color: "#e8ddd4"; border.width: 1

                                Column {
                                    id: ownItemColumn
                                    anchors { top: parent.top; left: parent.left; right: parent.right; margins: 16 }
                                    spacing: 8

                                    Row {
                                        width: parent.width
                                        Text {
                                            text: modelData.title || modelData.caption || new Date(modelData.created_at).toLocaleDateString()
                                            font.family: "Georgia"; font.pixelSize: 17; color: "#2c1f14"
                                            width: parent.width - 60; elide: Text.ElideRight
                                        }
                                        Text {
                                            text: "delete"; font.pixelSize: 11
                                            color: ownDelMouse.containsMouse ? "#E24B4A" : "#a89880"
                                            anchors.verticalCenter: parent.verticalCenter
                                            MouseArea {
                                                id: ownDelMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                                onClicked: ContentService.deleteItem(modelData.id)
                                            }
                                        }
                                    }

                                    Text {
                                        visible: (modelData.body || "") !== ""
                                        text: modelData.body || ""
                                        font.pixelSize: 14; color: "#7a6a5a"
                                        wrapMode: Text.WordWrap; width: parent.width; lineHeight: 1.6
                                    }

                                    Image {
                                        visible: modelData.kind === "photo" && (modelData.signed_url || "") !== ""
                                        source: modelData.signed_url || ""
                                        width: parent.width; height: width * 0.6
                                        fillMode: Image.PreserveAspectCrop
                                    }
                                }
                            }
                        }
                    }

                    // ── MODE B — WRITE TO OWNER (Letter area) ─────────
                    Column {
                        width: parent.width
                        spacing: 16
                        visible: !root.isOwnSpace
                        topPadding: 24

                        Rectangle { width: parent.width; height: 1; color: "#e8ddd4" }

                        Text {
                            text: "Write to " + root.ownerName + "."
                            font.family: "Georgia"; font.pixelSize: 24; color: "#2c1f14"
                            width: parent.width; wrapMode: Text.WordWrap
                        }

                        Text {
                            text: root.ownerName + " will write back."
                            font.family: "Georgia"; font.pixelSize: 14; font.italic: true
                            color: "#b87057"
                        }

                        // Write area
                        Rectangle {
                            width: parent.width
                            height: writeArea.implicitHeight + 40
                            radius: 12; color: "#ffffff"
                            border.color: "#e8ddd4"; border.width: 1

                            Column {
                                anchors { top: parent.top; left: parent.left; right: parent.right; margins: 20 }
                                spacing: 12

                                Text {
                                    z: 0
                                    text: "Dear " + root.ownerName + ","
                                    font.family: "Georgia"; font.pixelSize: 14; color: "#b87057"
                                }

                                Rectangle {
                                    width: parent.width; height: 120; radius: 8; color: "#f5ede4"
                                    border.color: writeArea.activeFocus ? "#b87057" : "transparent"; border.width: 1

                                    TextEdit {
                                        id: writeArea
                                        anchors { fill: parent; margins: 12 }
                                        font.pixelSize: 15; font.family: "Georgia"; color: "#2c1f14"
                                        wrapMode: TextEdit.Wrap
                                    }

                                    Text {
                                        z: 0
                                        anchors { left: parent.left; top: parent.top; leftMargin: 12; topMargin: 12 }
                                        text: "Write anything…"
                                        color: "#a89880"; font.pixelSize: 15; font.family: "Georgia"
                                        visible: writeArea.text.length === 0 && !writeArea.activeFocus
                                    }
                                }

                                Rectangle {
                                    width: parent.width; height: 44; radius: 8
                                    color: sendMouse.containsMouse ? "#a0614a" : "#b87057"
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                    Text { anchors.centerIn: parent; text: "Send"; font.pixelSize: 15; font.weight: Font.Medium; color: "#ffffff" }
                                    MouseArea {
                                        id: sendMouse; anchors.fill: parent; hoverEnabled: true
                                        onClicked: {
                                            if (writeArea.text.trim().length === 0) return
                                            ChatService.sendMessage(
                                                root.ownerId,
                                                root.ownerName,
                                                chatConversationId.text,
                                                writeArea.text.trim(),
                                                []
                                            )
                                            writeArea.text = ""
                                        }
                                    }
                                }

                                TextInput { id: chatConversationId; visible: false; text: "" }
                            }
                        }

                        // AI response area
                        Rectangle {
                            width: parent.width
                            height: aiResponseColumn.implicitHeight + 40
                            radius: 12; color: "#fdf0eb"
                            border.color: "#e8ddd4"; border.width: 1
                            visible: aiResponseText.text.length > 0

                            Column {
                                id: aiResponseColumn
                                anchors { top: parent.top; left: parent.left; right: parent.right; margins: 20 }
                                spacing: 8

                                Text {
                                    text: root.ownerName + " writes back:"
                                    font.family: "Georgia"; font.pixelSize: 13; color: "#b87057"; font.italic: true
                                }

                                Text {
                                    id: aiResponseText
                                    text: ""
                                    font.family: "Georgia"; font.pixelSize: 15; color: "#2c1f14"
                                    wrapMode: Text.WordWrap; width: parent.width; lineHeight: 1.7
                                }
                            }
                        }
                    }

                    Item { width: parent.width; height: 48 }
                }
            }
        }
    }

    // ── FILE PICKERS ──────────────────────────────────────────────────
    Platform.FileDialog {
        id: photoPicker
        title: "Choose a photo"
        nameFilters: ["Images (*.jpg *.jpeg *.png)"]
        onAccepted: {
            root.busy = true
            spaceStatus.text = ""
            var path = photoPicker.file.toString().replace("file://", "")
            var mime = path.endsWith(".png") ? "image/png" : "image/jpeg"
            ContentService.uploadFile(root.userId, "photo", path, mime)
        }
    }

    Platform.FileDialog {
        id: audioPicker
        title: "Choose an audio file"
        nameFilters: ["Audio (*.mp3 *.mp4 *.m4a)"]
        onAccepted: {
            root.busy = true
            spaceStatus.text = ""
            var path = audioPicker.file.toString().replace("file://", "")
            var mime = path.endsWith(".mp3") ? "audio/mpeg" : "audio/mp4"
            ContentService.uploadFile(root.userId, "recording", path, mime)
        }
    }

    // ── CHAT SERVICE CONNECTIONS ──────────────────────────────────────
    Connections {
        target: ChatService
        function onConversationLoaded(data) {
            chatConversationId.text = data.id
        }
        function onMessageReceived(text) {
            aiResponseText.text = text
        }
        function onMessageFailed(error) {
            spaceStatus.color = "#E24B4A"
            spaceStatus.text  = error
        }
    }

    Component.onCompleted: {
        if (root.ownerId.length > 0) {
            root.loadContent()
            if (root.isOwnSpace) {
                CrewService.loadCrew(root.userId)
            } else {
                ChatService.loadOrCreateConversation(root.ownerId, root.userId)
            }
        }
    }
}