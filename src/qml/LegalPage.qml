import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    signal goBack()

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
                        text: "Sign in"
                        font.pixelSize: 13
                        color: "#b87057"
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.goBack()
                        }
                    }
                }

                // ── TITLE ────────────────────────────────────────────
                Text {
                    width: parent.width
                    text: "Privacy & Terms of Use"
                    font.family: "Georgia"
                    font.pixelSize: 32
                    color: "#2c1f14"
                    wrapMode: Text.WordWrap
                }

                Text {
                    width: parent.width
                    text: "Done In Love · Last updated: 9 May 2026 · Version 1.0 — Demo"
                    font.pixelSize: 12
                    color: "#a89880"
                    wrapMode: Text.WordWrap
                }

                // ── DEMO WARNING ─────────────────────────────────────
                Rectangle {
                    width: parent.width
                    radius: 10
                    color: "#fdf0eb"
                    border.color: "#b87057"
                    border.width: 1
                    height: demoWarning.implicitHeight + 32

                    Text {
                        id: demoWarning
                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                            margins: 16
                        }
                        text: "DEMO VERSION — This is a demo version of Done In Love. The service is under active development. Features, structure, and these terms will change. By using the service during this demo phase you acknowledge and accept that it is an unfinished product, that disruptions may occur, and that no guarantees of continuity, performance, or data permanence are made."
                        font.pixelSize: 13
                        color: "#7a6a5a"
                        wrapMode: Text.WordWrap
                        lineHeight: 1.6
                    }
                }

                // ── SECTIONS ─────────────────────────────────────────
                Repeater {
                    model: [
                        {title: "1. Who we are", body: "Done In Love is a private digital space created by Erika Aversa, based in the Netherlands, to help people preserve voices, letters, and memories for the people they love.\n\nContact: rcsc.erikaaversa@outlook.com\n\nDone In Love is the data controller under the GDPR. Our lead supervisory authority is the Dutch Autoriteit Persoonsgegevens."},
                        {title: "2. Who this service is for", body: "You must be at least 18 years old to create an account. By registering, you confirm you are 18 or older.\n\n2.1 Geographical availability. During this demo phase, Done In Love may be restricted to specific countries or regions at our sole discretion. If access in your region is removed after you have already created an account, you retain the right to access, export, or delete your personal data by contacting rcsc.erikaaversa@outlook.com."},
                        {title: "3. The service we provide", body: "Done In Love gives you a private space to create and store letters, voice recordings, photos, and memories, and to designate up to five recipients who will receive access to that content. We host and transmit your content. We do not read, curate, or moderate it.\n\nDone In Love is a technical platform, not a content provider. Everything you create, share, and send is entirely your own responsibility."},
                        {title: "4. Your responsibility as account holder", body: "You are solely and fully responsible for:\n\n• All content you upload, record, or write within the service.\n• Your decision to invite specific people as recipients.\n• Obtaining any necessary consent from third parties whose personal data appears in your content.\n• Ensuring that the content you share does not violate any applicable law.\n• Any consequences arising from the content you choose to leave and share.\n\nDone In Love does not review your content. You indemnify Done In Love and Erika Aversa against any claim arising from the content you create or share."},
                        {title: "4a. Prohibited content", body: "Regardless of the private nature of the service, you may not create, upload, store, or share any content that:\n\n• Depicts, describes, or promotes sexual abuse, exploitation, or any content involving minors in a sexual context.\n• Constitutes hate speech, incitement to violence, or discrimination.\n• Is defamatory, fraudulent, or intentionally deceptive.\n• Violates the privacy or intellectual property rights of any third party.\n• Facilitates or promotes illegal activity of any kind.\n• Contains malware, viruses, or any code designed to harm systems or users.\n\nViolations may result in immediate account termination. Done In Love operates on open-source infrastructure including Ubuntu and QML open space environments. Erika Aversa accepts no responsibility for any content created or transmitted by users through the service."},
                        {title: "5. Recipient responsibility", body: "Each person you invite receives access to your content strictly for personal, private use. By accepting an invitation, each recipient agrees that:\n\n• They will not redistribute, publish, or sell the content they receive.\n• They are solely responsible for how they use the content once delivered.\n• Done In Love and Erika Aversa bear no responsibility for any use or misuse of content by a recipient after delivery."},
                        {title: "6. Data we collect", body: "• Account data: email address, display name, authentication identifiers.\n• Content you create: letters, memories, recordings, photos.\n• Usage data: anonymised interaction logs used solely to improve the service.\n• Technical data: minimal security logs for abuse prevention.\n\nWe do not sell your data. We do not use your personal content to train AI models."},
                        {title: "7. Legal basis (GDPR)", body: "• Art. 6(1)(b) — performance of the contract.\n• Art. 6(1)(a) — your consent for optional features.\n• Art. 6(1)(f) — our legitimate interest in security.\n• Art. 9(2)(a) — your explicit consent for health or end-of-life content."},
                        {title: "8. Service improvement", body: "We may analyse technical usage data (features used, flows completed, error rates) to improve Done In Love. This data never includes your personal content, letters, recordings, or photos.\n\nYour personal content is never used for improvement purposes under any circumstances."},
                        {title: "9. Your rights under GDPR", body: "You have the right to access, export, restrict, and delete your personal data at any time.\n\nContact: rcsc.erikaaversa@outlook.com"},
                        {title: "10. International data transfers", body: "Data may be processed on servers outside the EEA. Where this occurs, we rely on Standard Contractual Clauses or equivalent GDPR-recognised safeguards."},
                        {title: "11. Retention and deletion", body: "Your content is retained for as long as your account is active. You may delete your account and all associated content at any time. Backups are purged within 30 days of deletion."},
                        {title: "12. Limitation of liability — demo phase", body: "Done In Love is provided as is during this demo phase, without warranty of any kind. Erika Aversa and Done In Love shall not be liable for:\n\n• Any indirect, incidental, special, or consequential damages.\n• Any content created, shared, or misused by you or any recipient.\n• Loss of data, service interruptions, or technical failures.\n\nTotal liability is limited to up €50 or the total fees the user paid in the last 12 months/excluded donations, for damages caused by minor breaches or simple negligence.\n\n12.1 Regional access. Done In Love may not be available in all regions. We are not liable for any loss of access resulting from changes to our geographical service areas.\n\n12.2 AI-assisted content. Done In Love accepts no responsibility for the accuracy, appropriateness, or legality of any AI-generated content created by users. The user remains solely and fully responsible for all content regardless of how it was produced."},
                        {title: "13. Pricing and future changes", body: "Done In Love is currently free and operates on a voluntary donation basis. Donations are non-refundable.\n\nFuture development may introduce paid tiers. Any such change will be communicated clearly in advance. You will never be charged without prior notice.Done In Love is provided free of charge. As the sole creator and operator, Erika Aversa reserves the right to discontinue, suspend, or shut down the service at any time, for any reason or no reason, without prior notice and without liability. This includes but is not limited to technical, financial, personal, or strategic reasons. By using the service you acknowledge and accept this right. Where possible, reasonable notice will be given before discontinuation so users may export or preserve their content, but no guarantee of advance notice is made. This right applies equally to the web version, the Ubuntu Touch application, and any future distributions of Done In Love"},
                        {title: "14. Intellectual property", body: "You retain full ownership of all content you create. By uploading content, you grant Done In Love a limited, non-exclusive licence to store, host, and transmit that content solely for the purpose of providing the service. This licence ends when you delete your account."},
                        {title: "15. Changes to these terms", body: "We may update these terms at any time. Notice of all changes will be posted on the Updates page. We will not send email notifications.\n\nContact: rcsc.erikaaversa@outlook.com\n\nContinued use of the service after a change is posted constitutes acceptance of the updated terms."},
                        {title: "16. Governing law", body: "These terms are governed by the laws of the Netherlands and, where applicable, the European Union. Any dispute shall be subject to the jurisdiction of the courts of the Netherlands."}
                    ]

                    Column {
                        width: mainColumn.width
                        spacing: 8

                        Text {
                            width: parent.width
                            text: modelData.title
                            font.family: "Georgia"
                            font.pixelSize: 20
                            color: "#2c1f14"
                            wrapMode: Text.WordWrap
                        }

                        Text {
                            width: parent.width
                            text: modelData.body
                            font.pixelSize: 14
                            color: "#7a6a5a"
                            wrapMode: Text.WordWrap
                            lineHeight: 1.7
                        }

                        Rectangle {
                            width: parent.width
                            height: 1
                            color: "#e8ddd4"
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
}
