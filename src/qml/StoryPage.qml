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

                Text {
                    width: parent.width
                    text: "a letter from me"
                    font.family: "Georgia"
                    font.pixelSize: 26
                    font.italic: true
                    color: "#b87057"
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    width: parent.width
                    text: "This is why I built Done In Love."
                    font.family: "Georgia"
                    font.pixelSize: 32
                    color: "#2c1f14"
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }

                Column {
                    width: parent.width
                    spacing: 16

                    Repeater {
                        model: [
                            "I know exactly what it feels like to lose the people who mean the most to you.",
                            "My own family has been through so much — too many premature deaths and the weight of long illnesses.",
                            "The app was born because I wanted to give people a gift: the opportunity to leave behind beautiful memories for their families when they know their time is getting closer.",
                            "I created this so you can have the possibility I didn't have — to say those things that are so hard to say when life gets difficult.",
                            "Done In Love is a private space to preserve your voice, share your memories, and stay connected to your family forever.",
                            "If you're able to donate, I'll use it to keep improving the app.",
                            "It's my way of making sure that even when we have to say goodbye, the love never really ends."
                        ]
                        Text {
                            width: parent.width
                            text: modelData
                            font.pixelSize: 15
                            color: "#7a6a5a"
                            wrapMode: Text.WordWrap
                            lineHeight: 1.7
                        }
                    }
                }

                Text {
                    width: parent.width
                    text: "Erika Aversa"
                    font.family: "Georgia"
                    font.pixelSize: 22
                    font.italic: true
                    color: "#b87057"
                    horizontalAlignment: Text.AlignRight
                }

                Rectangle {
                    width: parent.width
                    height: donationColumn.implicitHeight + 48
                    radius: 16
                    color: "#ffffff"
                    border.color: "#e8ddd4"
                    border.width: 1

                    Column {
                        id: donationColumn
                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                            margins: 24
                        }
                        spacing: 16

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "with gratitude"
                            font.family: "Georgia"
                            font.pixelSize: 18
                            font.italic: true
                            color: "#8a9e8a"
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Support Done In Love."
                            font.family: "Georgia"
                            font.pixelSize: 22
                            color: "#2c1f14"
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width
                            text: "Every contribution helps to develop the service."
                            font.pixelSize: 14
                            color: "#7a6a5a"
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                        }

                        Rectangle {
                            width: parent.width
                            height: 52
                            radius: 10
                            color: donateMouse.containsMouse ? "#a0614a" : "#b87057"
                            Behavior on color { ColorAnimation { duration: 150 } }

                            Row {
                                anchors.centerIn: parent
                                spacing: 8
                                Text {
                                    text: "♥"
                                    font.pixelSize: 16
                                    color: "#ffffff"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: "Donate"
                                    font.pixelSize: 16
                                    font.weight: Font.Medium
                                    color: "#ffffff"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                id: donateMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: Qt.openUrlExternally("https://paypal.me/ErikaAversa383")
                            }
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "paypal.me/ErikaAversa383"
                            font.pixelSize: 13
                            color: "#b87057"
                            font.underline: true
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Qt.openUrlExternally("https://paypal.me/ErikaAversa383")
                            }
                        }
                    }
                }

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
