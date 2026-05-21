import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.platform 1.1 as Platform

Item {
    id: root
    property string userId: ""
    signal goBack()

    property bool loading: true
    property bool uploading: false
    property var files: []

    // Detect platform
    readonly property bool isUbuntuTouch: Qt.platform.os === "linux" && typeof ContentHub !== "undefined"

    function load() {
        root.loading = true
        WillService.loadFiles(root.userId)
    }

    function fmtSize(n) {
        if (n < 1024) return n + " B"
        if (n < 1024 * 1024) return (n / 1024).toFixed(1) + " KB"
        return (n / 1024 / 1024).toFixed(1) + " MB"
    }

    function fmtDate(s) {
        if (!s) return ""
        return new Date(s).toLocaleDateString()
    }

    Component.onCompleted: {
        if (root.userId.length > 0) root.load()
    }

    Connections {
        target: WillService
        function onFilesLoaded(data) {
            root.files   = data
            root.loading = false
        }
        function onFilesLoadFailed(error) {
            root.loading = false
            statusText.color = "#E24B4A"
            statusText.text  = error
        }
        function onFileUploaded() {
            root.uploading = false
            statusText.color = "#1D9E75"
            statusText.text  = "Will saved."
            root.load()
        }
        function onFileUploadFailed(error) {
            root.uploading = false
            statusText.color = "#E24B4A"
            statusText.text  = error
        }
        function onFileOpened(url) {
            Qt.openUrlExternally(url)
        }
        function onFileOpenFailed(error) {
            statusText.color = "#E24B4A"
            statusText.text  = error
        }
        function onFileDeleted() {
            statusText.color = "#1D9E75"
            statusText.text  = "Removed."
            root.load()
        }
        function onFileDeleteFailed(error) {
            statusText.color = "#E24B4A"
            statusText.text  = error
        }
    }

    // Desktop file picker
    Platform.FileDialog {
        id: filePicker
        title: "Choose a will document"
        nameFilters: ["Documents (*.pdf *.doc *.docx *.jpg *.jpeg *.png)"]
        onAccepted: {
            root.uploading = true
            statusText.text = ""
            var path = filePicker.file.toString().replace("file://", "")
            var mime = "application/octet-stream"
            if (path.endsWith(".pdf"))  mime = "application/pdf"
            else if (path.endsWith(".doc"))  mime = "application/msword"
            else if (path.endsWith(".docx")) mime = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
            else if (path.endsWith(".jpg") || path.endsWith(".jpeg")) mime = "image/jpeg"
            else if (path.endsWith(".png")) mime = "image/png"
            WillService.uploadFile(root.userId, path, mime)
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
                        text: "paperwork"
                        font.family: "Georgia"
                        font.pixelSize: 22
                        font.italic: true
                        color: "#b87057"
                    }

                    Text {
                        text: "Arrange your will"
                        font.family: "Georgia"
                        font.pixelSize: 32
                        color: "#2c1f14"
                    }

                    Text {
                        width: parent.width
                        text: "Upload your will here. It stays private — only you can see, download, or delete it. PDF, Word, or a clear photo works."
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

                // ── UPLOAD CARD ───────────────────────────────────────
                Rectangle {
                    width: parent.width
                    height: uploadColumn.implicitHeight + 40
                    radius: 12
                    color: "#ffffff"
                    border.color: "#e8ddd4"
                    border.width: 1

                    Column {
                        id: uploadColumn
                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                            margins: 20
                        }
                        spacing: 12

                        Text {
                            text: "Upload a document"
                            font.family: "Georgia"
                            font.pixelSize: 18
                            color: "#2c1f14"
                        }

                        Text {
                            text: "Max 20 MB. PDF, Word (.doc/.docx), JPG or PNG."
                            font.pixelSize: 12
                            color: "#a89880"
                        }

                        // Upload button
                        Rectangle {
                            width: parent.width
                            height: 48
                            radius: 8
                            color: root.uploading ? "#d4a898" : (uploadMouse.containsMouse ? "#a0614a" : "#b87057")
                            opacity: root.uploading ? 0.6 : 1.0
                            Behavior on color { ColorAnimation { duration: 150 } }

                            Text {
                                anchors.centerIn: parent
                                text: root.uploading ? "saving…" : "Choose file"
                                font.pixelSize: 15
                                font.weight: Font.Medium
                                color: "#ffffff"
                            }

                            MouseArea {
                                id: uploadMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                enabled: !root.uploading
                                onClicked: filePicker.open()
                            }
                        }
                    }
                }

                // ── YOUR DOCUMENTS ────────────────────────────────────
                Column {
                    width: parent.width
                    spacing: 16

                    Text {
                        text: "Your documents"
                        font.family: "Georgia"
                        font.pixelSize: 24
                        color: "#2c1f14"
                    }

                    Text {
                        visible: root.loading
                        text: "Looking…"
                        font.pixelSize: 14
                        color: "#a89880"
                        font.italic: true
                    }

                    Text {
                        visible: !root.loading && root.files.length === 0
                        text: "Nothing here yet."
                        font.pixelSize: 14
                        color: "#a89880"
                        font.italic: true
                    }

                    Column {
                        width: parent.width
                        spacing: 12
                        visible: !root.loading && root.files.length > 0

                        Repeater {
                            model: root.files

                            Rectangle {
                                width: parent.width
                                height: fileRow.implicitHeight + 32
                                radius: 12
                                color: "#ffffff"
                                border.color: "#e8ddd4"
                                border.width: 1

                                Row {
                                    id: fileRow
                                    anchors {
                                        left: parent.left
                                        right: parent.right
                                        verticalCenter: parent.verticalCenter
                                        leftMargin: 16
                                        rightMargin: 16
                                    }
                                    spacing: 12

                                    Column {
                                        width: parent.width - 150
                                        spacing: 4
                                        anchors.verticalCenter: parent.verticalCenter

                                        Text {
                                            text: modelData.name
                                            font.family: "Georgia"
                                            font.pixelSize: 16
                                            color: "#2c1f14"
                                            elide: Text.ElideRight
                                            width: parent.width
                                        }

                                        Text {
                                            text: root.fmtSize(modelData.size) + (modelData.updated_at ? " · " + root.fmtDate(modelData.updated_at) : "")
                                            font.pixelSize: 11
                                            color: "#a89880"
                                        }
                                    }

                                    // Open button
                                    Rectangle {
                                        width: 64
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
                                            onClicked: WillService.openFile(modelData.path)
                                        }
                                    }

                                    // Delete button
                                    Rectangle {
                                        width: 56
                                        height: 36
                                        radius: 8
                                        color: delMouse.containsMouse ? "#fdf0eb" : "#ffffff"
                                        border.color: "#e8ddd4"
                                        border.width: 1
                                        anchors.verticalCenter: parent.verticalCenter
                                        Behavior on color { ColorAnimation { duration: 150 } }

                                        Text {
                                            anchors.centerIn: parent
                                            text: "delete"
                                            font.pixelSize: 12
                                            color: delMouse.containsMouse ? "#E24B4A" : "#a89880"
                                        }

                                        MouseArea {
                                            id: delMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: deleteConfirm.open(modelData)
                                        }
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

    // ── DELETE CONFIRM DIALOG ─────────────────────────────────────────
    Rectangle {
        id: deleteConfirm
        anchors.fill: parent
        color: "#000000"; opacity: 0; visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 200 } }

        property var file: null

        function open(f) {
            deleteConfirm.file = f
            deleteConfirmText.text = "Delete " + f.name + "?"
            deleteConfirm.opacity = 0.5
            deleteConfirmBox.opacity = 1
        }
        function close() {
            deleteConfirm.opacity = 0
            deleteConfirmBox.opacity = 0
        }

        MouseArea { anchors.fill: parent; onClicked: deleteConfirm.close() }
    }

    Rectangle {
        id: deleteConfirmBox
        anchors.centerIn: parent
        width: Math.min(parent.width - 48, 360)
        height: deleteConfirmCol.implicitHeight + 48
        radius: 16; color: "#ffffff"; opacity: 0; visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 200 } }

        Column {
            id: deleteConfirmCol
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 24 }
            spacing: 16

            Text {
                id: deleteConfirmText
                width: parent.width
                text: ""
                font.pixelSize: 15; color: "#2c1f14"; wrapMode: Text.WordWrap
            }

            Rectangle {
                width: parent.width; height: 48; radius: 8
                color: confirmDelMouse.containsMouse ? "#c0392b" : "#E24B4A"
                Behavior on color { ColorAnimation { duration: 150 } }
                Text { anchors.centerIn: parent; text: "Yes, delete"; font.pixelSize: 14; font.weight: Font.Medium; color: "#ffffff" }
                MouseArea {
                    id: confirmDelMouse; anchors.fill: parent; hoverEnabled: true
                    onClicked: {
                        WillService.deleteFile(deleteConfirm.file.path)
                        deleteConfirm.close()
                    }
                }
            }

            Rectangle {
                width: parent.width; height: 48; radius: 8
                color: cancelDelMouse.containsMouse ? "#e8ddd4" : "#ffffff"
                border.color: "#e8ddd4"; border.width: 1
                Behavior on color { ColorAnimation { duration: 150 } }
                Text { anchors.centerIn: parent; text: "Cancel"; font.pixelSize: 14; color: "#2c1f14" }
                MouseArea { id: cancelDelMouse; anchors.fill: parent; hoverEnabled: true; onClicked: deleteConfirm.close() }
            }
        }
    }
}
