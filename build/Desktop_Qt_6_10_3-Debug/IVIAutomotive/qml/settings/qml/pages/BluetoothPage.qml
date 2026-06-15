import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"

Item {
    id: btPage

    // ── Toast notification (matches WifiPage) ───────────────────────────────
    Rectangle {
        id: toastBar
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: theme.spacingLarge
        }
        width: toastText.implicitWidth + theme.spacingLarge * 2
        height: 36
        radius: theme.radiusSmall
        color: toastSuccess ? "#2e7d32" : "#c62828"
        visible: false
        z: 100

        property bool toastSuccess: true

        Text {
            id: toastText
            anchors.centerIn: parent
            color: theme.textOnAccent
            font.pixelSize: theme.fontSizeSmall
        }

        Timer {
            id: toastTimer
            interval: 3000
            onTriggered: toastBar.visible = false
        }
    }

    function showToast(success, message) {
        toastBar.toastSuccess = success
        toastText.text = message
        toastBar.visible = true
        toastTimer.restart()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: theme.spacingLarge
        spacing: theme.spacingMedium

        PageHeader {
            Layout.fillWidth: true
            title: "Bluetooth"
            subtitle: "Manage paired devices"
        }

        // ── Discoverable switch ─────────────────────────────────────────────
        SettingsGroup {
            Layout.fillWidth: true
            visible: bluetoothManager.bluetoothAvailable

            SettingsRow {
                label: "Discoverable"
                description: bluetoothManager.discoverable
                             ? "Your device is visible to nearby phones"
                             : "Make your device visible to nearby phones"
                showDivider: false

                StyledToggle {
                    checked: bluetoothManager.discoverable
                    onToggled: (value) => bluetoothManager.setDiscoverable(value)
                }
            }
        }

        // ── Connected device ────────────────────────────────────────────────
        SettingsGroup {
            Layout.fillWidth: true
            groupTitle: "CONNECTED DEVICE"
            visible: bluetoothManager.connected

            ColumnLayout {
                width: parent.width
                spacing: theme.spacingMedium

                // Device row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: theme.spacingMedium

                    // Avatar
                    Rectangle {
                        Layout.preferredWidth: 44; Layout.preferredHeight: 44
                        radius: 22
                        color: Qt.rgba(theme.accent.r, theme.accent.g, theme.accent.b, 0.12)
                        border.color: theme.accent; border.width: 1.5
                        Text { anchors.centerIn: parent; text: "📱"; font.pixelSize: 20 }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: bluetoothManager.connectedDevice
                            font.family: theme.displayFont
                            font.pixelSize: theme.fontSizeBody; font.weight: Font.DemiBold
                            color: theme.t0; elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Row {
                            spacing: 6
                            Badge { label: "A2DP"; active: bluetoothManager.playing;     activeColor: theme.accent }
                            Badge { label: "HFP";  active: bluetoothManager.hfpConnected; activeColor: theme.success }
                        }
                    }

                    Pill {
                        label: "Disconnect"; kind: "danger"
                        onActivated: { bluetoothManager.disconnectDevice(); showToast(true, "Disconnected") }
                    }
                }

                // Retry audio (connected but not streaming)
                RowLayout {
                    Layout.fillWidth: true
                    visible: !bluetoothManager.playing
                    Item { Layout.fillWidth: true }
                    Pill {
                        label: "Retry Audio"; kind: "primary"
                        onActivated: { bluetoothManager.retryAudio(); showToast(true, "Looking for audio source…") }
                    }
                }

                // Volume (A2DP streaming)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: theme.spacingSmall
                    visible: bluetoothManager.playing

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Volume"; Layout.fillWidth: true
                            font.family: theme.displayFont; font.pixelSize: theme.fontSizeSmall
                            color: theme.t0
                        }
                        Text {
                            text: bluetoothManager.volume + "%"
                            font.family: theme.displayFont; font.pixelSize: theme.fontSizeSmall
                            color: theme.accent
                        }
                    }

                    StyledSlider {
                        Layout.fillWidth: true
                        from: 0; to: 100
                        value: bluetoothManager.volume
                        onMoved: bluetoothManager.setVolume(Math.round(value))
                    }
                }
            }
        }

        // ── Available devices ───────────────────────────────────────────────
        SettingsGroup {
            Layout.fillWidth: true
            groupTitle: "AVAILABLE DEVICES"
            visible: bluetoothManager.bluetoothAvailable

            ColumnLayout {
                width: parent.width
                spacing: theme.spacingMedium

                // Header: status + spinner + scan
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true
                        text: bluetoothManager.statusMsg
                        color: theme.textSecondary
                        font.pixelSize: theme.fontSizeSmall
                        elide: Text.ElideRight
                    }

                    BusyIndicator {
                        running: bluetoothManager.scanning
                        visible: running
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20
                    }

                    Pill {
                        label: bluetoothManager.scanning ? "Stop" : "Scan"
                        kind: bluetoothManager.scanning ? "danger" : "primary"
                        onActivated: bluetoothManager.scanning ? bluetoothManager.stopScan()
                                                               : bluetoothManager.startScan()
                    }
                }

                // Device list
                Repeater {
                    model: bluetoothManager.devices

                    delegate: SettingsRow {
                        id: devRow
                        width: parent.width
                        property bool isCurrent: bluetoothManager.connectedDevice === modelData.name

                        label: modelData.name || modelData.address
                        description: devRow.isCurrent ? "✓ Connected"
                                   : (modelData.paired ? "Paired" : "Found nearby")
                        showDivider: index < bluetoothManager.devices.length - 1

                        Pill {
                            label: devRow.isCurrent ? "Disconnect" : "Connect"
                            kind: devRow.isCurrent ? "danger" : "primary"
                            onActivated: devRow.isCurrent ? bluetoothManager.disconnectDevice()
                                                          : bluetoothManager.connectDevice(modelData.address)
                        }
                    }
                }

                // Empty state
                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    visible: bluetoothManager.devices.length === 0 && !bluetoothManager.scanning
                    text: "No devices found. Tap Scan to search."
                    color: theme.textSecondary
                    font.pixelSize: theme.fontSizeSmall
                    topPadding: theme.spacingMedium
                }
            }
        }

        Item { Layout.fillHeight: true }
    }

    // ── Reusable pill button (matches the WifiPage button language) ─────────
    //    kind: "primary" (blue) · "danger" (red) · "neutral" (subtle)
    component Pill: Item {
        id: pill
        property string label: ""
        property string kind: "primary"
        signal activated()

        readonly property color baseColor: kind === "danger"  ? theme.danger
                                          : kind === "neutral" ? theme.b2
                                          : theme.blue

        implicitWidth: pillTxt.implicitWidth + 28
        implicitHeight: 30
        Layout.preferredWidth: implicitWidth
        Layout.preferredHeight: implicitHeight

        Rectangle {
            anchors.fill: parent
            radius: 15
            color: pill.kind === "neutral"
                   ? (pillMa.containsMouse ? theme.bgHover : "transparent")
                   : (pillMa.containsMouse ? pill.baseColor
                                           : Qt.rgba(pill.baseColor.r, pill.baseColor.g, pill.baseColor.b, 0.14))
            border.color: pill.kind === "neutral" ? theme.b2 : pill.baseColor
            border.width: 1
            Behavior on color { ColorAnimation { duration: theme.fast } }

            Text {
                id: pillTxt
                anchors.centerIn: parent
                text: pill.label
                font.family: theme.displayFont
                font.pixelSize: theme.fontSizeSmall; font.weight: Font.Medium
                color: pill.kind === "neutral" ? theme.t1
                     : (pillMa.containsMouse ? "#fff" : pill.baseColor)
                Behavior on color { ColorAnimation { duration: theme.fast } }
            }

            MouseArea {
                id: pillMa
                anchors.fill: parent
                hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onClicked: pill.activated()
            }
        }
    }

    // ── Small profile badge ─────────────────────────────────────────────────
    component Badge: Rectangle {
        property string label: ""
        property bool   active: false
        property color  activeColor: theme.accent
        height: 22; radius: 11
        width: badgeTxt.implicitWidth + 14
        color:  active ? Qt.rgba(activeColor.r, activeColor.g, activeColor.b, 0.14) : theme.bgDeep
        border.color: active ? activeColor : theme.b2; border.width: 1
        Text {
            id: badgeTxt; anchors.centerIn: parent; text: label
            font.family: theme.displayFont; font.pixelSize: 10; font.weight: Font.Medium
            color: active ? activeColor : theme.t2
        }
    }
}
