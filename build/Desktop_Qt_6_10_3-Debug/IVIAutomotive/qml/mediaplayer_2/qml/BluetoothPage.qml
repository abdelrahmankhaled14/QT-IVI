import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: bluetoothPage
    width: SwipeView.view ? SwipeView.view.width : 480
    height: SwipeView.view ? SwipeView.view.height : 800

    // ── Background ────────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "#FFF0F5"
            }
            GradientStop {
                position: 1.0
                color: "#FFE4EC"
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        // ── Status bar ────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 60
            radius: 14
            color: "#FFFFFF"
            border.color: "#FFD6E7"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                Text {
                    text: bluetoothManager.connected ? "🔵" : "⚪"
                    font.pixelSize: 20
                }

                Text {
                    Layout.fillWidth: true
                    text: bluetoothManager.statusMsg
                    font.pixelSize: 12
                    color: "#8B3A62"
                    wrapMode: Text.WordWrap
                }

                BusyIndicator {
                    width: 24
                    height: 24
                    running: bluetoothManager.scanning
                    visible: bluetoothManager.scanning
                }
            }
        }

        // ── No adapter warning ────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 50
            radius: 12
            color: "#FFF3CD"
            border.color: "#FFCA2C"
            visible: !bluetoothManager.bluetoothAvailable

            Text {
                anchors.centerIn: parent
                text: "⚠️  No Bluetooth adapter detected"
                font.pixelSize: 13
                color: "#856404"
            }
        }

        // ── Now Playing card (shown when streaming) ───────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 100
            radius: 16
            visible: bluetoothManager.playing
            color: "#1A1A2E"

            // Animated glow when playing
            Rectangle {
                anchors.fill: parent
                radius: 16
                color: "transparent"
                border.color: "#E91E8C"
                border.width: 2
                opacity: glowAnim.running ? 0.6 : 1.0
                SequentialAnimation on opacity {
                    id: glowAnim
                    running: bluetoothManager.playing
                    loops: Animation.Infinite
                    NumberAnimation {
                        to: 0.2
                        duration: 900
                    }
                    NumberAnimation {
                        to: 1.0
                        duration: 900
                    }
                }
            }

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 6

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "🎵  STREAMING AUDIO"
                    font.pixelSize: 13
                    font.bold: true
                    font.letterSpacing: 2
                    color: "#E91E8C"
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "from " + bluetoothManager.connectedDevice
                    font.pixelSize: 12
                    color: "#FFB6C1"
                }
            }
        }

        // ── Connected banner ──────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 52
            radius: 14
            color: "#D4F8E8"
            border.color: "#40C080"
            border.width: 1
            visible: bluetoothManager.connected

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                Text {
                    text: "✅"
                    font.pixelSize: 20
                }

                Text {
                    Layout.fillWidth: true
                    text: "<b>" + bluetoothManager.connectedDevice + "</b> connected"
                    font.pixelSize: 13
                    color: "#1A6040"
                    textFormat: Text.RichText
                }

                Rectangle {
                    width: 90
                    height: 32
                    radius: 16
                    color: discBtnMouse.pressed ? "#B00020" : "#D00030"

                    Text {
                        anchors.centerIn: parent
                        text: "Disconnect"
                        font.pixelSize: 11
                        font.bold: true
                        color: "white"
                    }
                    MouseArea {
                        id: discBtnMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: bluetoothManager.disconnectDevice()
                    }
                }
            }
        }

        // ── Volume slider ─────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 52
            radius: 14
            color: "#FFFFFF"
            border.color: "#FFD6E7"
            visible: bluetoothManager.connected

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                Text {
                    text: "🔈"
                    font.pixelSize: 18
                }

                Slider {
                    id: volSlider

                    Layout.fillWidth: true

                    from: 0
                    to: 100

                    // IMPORTANT
                    value: bluetoothManager.volume

                    // Better than onMoved
                    onValueChanged: {
                        if (pressed)
                            bluetoothManager.setVolume(Math.round(value))
                    }

                    Connections {
                        target: bluetoothManager

                        function onVolumeChanged() {
                            if (!volSlider.pressed)
                                volSlider.value = bluetoothManager.volume
                        }
                    }

                    background: Rectangle {
                        x: volSlider.leftPadding
                        y: volSlider.height / 2 - height / 2
                        width: volSlider.availableWidth
                        height: 6
                        radius: 3
                        color: "#FFD6E7"

                        Rectangle {
                            width: volSlider.visualPosition * parent.width
                            height: parent.height
                            radius: 3
                            color: "#E91E8C"
                        }
                    }

                    handle: Rectangle {
                        width: 22
                        height: 22
                        radius: 11

                        x: volSlider.leftPadding +
                           volSlider.visualPosition *
                           (volSlider.availableWidth - width)

                        y: volSlider.height / 2 - height / 2

                        color: "white"

                        border.color: "#E91E8C"
                        border.width: 2
                    }
                }

                Text {
                    text: "🔊"
                    font.pixelSize: 18
                }
            }
        }
        // ── Action buttons ────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            enabled: bluetoothManager.bluetoothAvailable

            // Discoverable toggle
            Rectangle {
                Layout.fillWidth: true
                height: 48
                radius: 24
                color: bluetoothManager.discoverable ? (discMouse.pressed ? "#3A3AB0" : "#4A4AD0") : (discMouse.pressed ? "#C01870" : "#E91E8C")

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 6
                    Text {
                        text: bluetoothManager.discoverable ? "👁" : "📡"
                        font.pixelSize: 16
                    }
                    Text {
                        text: bluetoothManager.discoverable ? "Discoverable" : "Make Visible"
                        font.pixelSize: 12
                        font.bold: true
                        color: "white"
                    }
                }
                MouseArea {
                    id: discMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: bluetoothManager.setDiscoverable(!bluetoothManager.discoverable)
                }
            }

            // Scan button
            Rectangle {
                Layout.fillWidth: true
                height: 48
                radius: 24
                color: bluetoothManager.scanning ? (scanMouse.pressed ? "#707070" : "#909090") : (scanMouse.pressed ? "#C01870" : "#E91E8C")

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 6
                    Text {
                        text: bluetoothManager.scanning ? "⏹" : "🔍"
                        font.pixelSize: 16
                    }
                    Text {
                        text: bluetoothManager.scanning ? "Stop" : "Scan"
                        font.pixelSize: 12
                        font.bold: true
                        color: "white"
                    }
                }
                MouseArea {
                    id: scanMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: bluetoothManager.scanning ? bluetoothManager.stopScan() : bluetoothManager.startScan()
                }
            }
        }

        // ── How-to hint ───────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: hintCol.implicitHeight + 16
            radius: 12
            color: "#FFF8FF"
            border.color: "#FFD6E7"

            ColumnLayout {
                id: hintCol
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: 10
                }
                spacing: 3

                Text {
                    text: "📱 How to stream from your phone:"
                    font.pixelSize: 12
                    font.bold: true
                    color: "#8B3A62"
                }
                Text {
                    Layout.fillWidth: true
                    text: "1. Tap <b>Make Visible</b> — your PC becomes discoverable"
                    font.pixelSize: 11
                    color: "#8B3A62"
                    wrapMode: Text.WordWrap
                    textFormat: Text.RichText
                }
                Text {
                    Layout.fillWidth: true
                    text: "2. On your phone: Settings → Bluetooth → find this PC → Pair"
                    font.pixelSize: 11
                    color: "#8B3A62"
                    wrapMode: Text.WordWrap
                }
                Text {
                    Layout.fillWidth: true
                    text: "3. Play music on your phone — it streams here automatically"
                    font.pixelSize: 11
                    color: "#8B3A62"
                    wrapMode: Text.WordWrap
                }
            }
        }

        // ── Device list ───────────────────────────────────────────────────
        Text {
            text: "Nearby & Paired Devices"
            font.pixelSize: 14
            font.bold: true
            color: "#8B3A62"
            visible: bluetoothManager.devices.length > 0
        }

        ListView {
            id: deviceList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 8
            model: bluetoothManager.devices

            delegate: Rectangle {
                width: deviceList.width
                height: 62
                radius: 14
                color: itemMouse.containsMouse ? "#FFE4F0" : "#FFFFFF"
                border.color: bluetoothManager.connectedDevice === modelData.name ? "#40C080" : "#FFD6E7"
                border.width: bluetoothManager.connectedDevice === modelData.name ? 2 : 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    Text {
                        text: modelData.paired ? "📱" : "📶"
                        font.pixelSize: 24
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text {
                            text: modelData.name
                            font.pixelSize: 13
                            font.bold: true
                            color: "#8B3A62"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        Text {
                            text: modelData.address + (modelData.paired ? "  ✓ paired" : "")
                            font.pixelSize: 10
                            color: "#C06080"
                        }
                    }

                    // Connect button
                    Rectangle {
                        width: 82
                        height: 30
                        radius: 15
                        visible: bluetoothManager.connectedDevice !== modelData.name
                        color: itemMouse.pressed ? "#C01870" : "#E91E8C"
                        Text {
                            anchors.centerIn: parent
                            text: "Connect"
                            font.pixelSize: 11
                            font.bold: true
                            color: "white"
                        }
                    }

                    // Active badge
                    Rectangle {
                        width: 82
                        height: 30
                        radius: 15
                        visible: bluetoothManager.connectedDevice === modelData.name
                        color: "#40C080"
                        Text {
                            anchors.centerIn: parent
                            text: "✓ Active"
                            font.pixelSize: 11
                            font.bold: true
                            color: "white"
                        }
                    }
                }

                MouseArea {
                    id: itemMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (bluetoothManager.connectedDevice !== modelData.name)
                            bluetoothManager.connectDevice(modelData.address);
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                visible: bluetoothManager.devices.length === 0 && !bluetoothManager.scanning
                text: "No devices found yet.\nTap Scan or Make Visible to start."
                font.pixelSize: 13
                color: "#C06080"
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
