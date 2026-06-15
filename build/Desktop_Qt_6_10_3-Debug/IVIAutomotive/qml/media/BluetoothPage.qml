import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: btPage

    // ── helpers ───────────────────────────────────────────────────────────────
    function fmtStatus() {
        if (!bluetoothManager.bluetoothAvailable) return "No Bluetooth adapter"
        if (bluetoothManager.connected)           return "Connected to " + bluetoothManager.connectedDevice
        if (bluetoothManager.scanning)            return "Scanning for devices…"
        return "Ready"
    }

    // ── Toast ─────────────────────────────────────────────────────────────────
    Rectangle {
        id: toast
        property bool ok: true
        anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 24
        width: toastTxt.implicitWidth + 32; height: 36; radius: 18
        color: toast.ok ? "#1B5E20" : "#B71C1C"
        border.color: toast.ok ? "#43A047" : "#EF5350"; border.width: 1
        visible: false; z: 99

        Text { id: toastTxt; anchors.centerIn: parent; color: "#fff"; font.family: theme.displayFont; font.pixelSize: 12 }
        Timer { id: toastTimer; interval: 3000; onTriggered: toast.visible = false }
    }

    function showToast(ok, msg) {
        toast.ok = ok; toastTxt.text = msg; toast.visible = true; toastTimer.restart()
    }

    // ── background ────────────────────────────────────────────────────────────
    Rectangle { anchors.fill: parent; color: theme.bgSurface }

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth

        ColumnLayout {
            width: parent.width
            spacing: 14
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 20 }

            // ── Page title ────────────────────────────────────────────────────
            Item { height: 4 }
            Text {
                text: "Bluetooth"
                font.family: theme.displayFont; font.pixelSize: 22; font.weight: Font.Bold
                color: theme.t0
            }
            Text {
                text: fmtStatus()
                font.family: theme.displayFont; font.pixelSize: 13; color: theme.t1
            }
            Item { height: 4 }

            // ── Discoverable toggle ───────────────────────────────────────────
            BtCard {
                Layout.fillWidth: true; cardHeight: 60
                visible: bluetoothManager.bluetoothAvailable

                RowLayout {
                    anchors { fill: parent; margins: 16 }

                    Column {
                        spacing: 3; Layout.fillWidth: true
                        Text { text: "Discoverable"; font.family: theme.displayFont; font.pixelSize: 14; font.weight: Font.Medium; color: theme.t0 }
                        Text {
                            text: bluetoothManager.discoverable ? "Your device is visible to nearby phones" : "Tap to make your device visible"
                            font.family: theme.displayFont; font.pixelSize: 11; color: theme.t1
                        }
                    }

                    BtToggle {
                        checked: bluetoothManager.discoverable
                        onToggled: bluetoothManager.setDiscoverable(!bluetoothManager.discoverable)
                    }
                }
            }

            // ── Connected device ──────────────────────────────────────────────
            BtCard {
                Layout.fillWidth: true
                cardHeight: connectedCol.implicitHeight + 32
                visible: bluetoothManager.connected

                Column {
                    id: connectedCol
                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16 }
                    spacing: 14

                    // Section label
                    Text { text: "CONNECTED DEVICE"; font.family: theme.displayFont; font.pixelSize: 10; font.letterSpacing: 2.5; color: theme.t1 }

                    // Device row
                    RowLayout {
                        width: parent.width; spacing: 12

                        // Avatar circle
                        Rectangle {
                            width: 44; height: 44; radius: 22
                            color: Qt.rgba(theme.blue.r, theme.blue.g, theme.blue.b, 0.12)
                            border.color: theme.blue; border.width: 1.5

                            // Pulsing ring when streaming
                            Rectangle {
                                anchors.centerIn: parent; width: 56; height: 56; radius: 28
                                color: "transparent"; border.color: theme.blue; border.width: 1; opacity: 0
                                SequentialAnimation on opacity {
                                    running: bluetoothManager.playing; loops: Animation.Infinite
                                    NumberAnimation { to: 0.5; duration: 800 }
                                    NumberAnimation { to: 0;   duration: 800 }
                                }
                            }

                            Text { anchors.centerIn: parent; text: "📱"; font.pixelSize: 20 }
                        }

                        Column {
                            Layout.fillWidth: true; spacing: 4

                            Text {
                                text: bluetoothManager.connectedDevice
                                font.family: theme.displayFont; font.pixelSize: 15; font.weight: Font.DemiBold
                                color: theme.t0; elide: Text.ElideRight; width: parent.width
                            }

                            // Profile badges
                            Row {
                                spacing: 6
                                BtBadge { label: "A2DP"; active: bluetoothManager.playing;   activeColor: theme.blue }
                                BtBadge { label: "HFP";  active: bluetoothManager.hfpConnected; activeColor: theme.climateAc }
                            }
                        }

                        // Disconnect
                        BtButton {
                            label: "Disconnect"; danger: true
                            onAction: { bluetoothManager.disconnectDevice(); showToast(true, "Disconnected") }
                        }
                    }

                    // Retry audio button when connected but not streaming
                    RowLayout {
                        width: parent.width
                        visible: !bluetoothManager.playing
                        Item { Layout.fillWidth: true }
                        BtButton {
                            label: "Retry Audio"
                            onAction: { bluetoothManager.retryAudio(); showToast(true, "Looking for audio source…") }
                        }
                    }

                    // Volume slider (only when streaming A2DP)
                    ColumnLayout {
                        width: parent.width; spacing: 8
                        visible: bluetoothManager.playing

                        RowLayout {
                            width: parent.width
                            Text { text: "Volume"; font.family: theme.displayFont; font.pixelSize: 13; color: theme.t0; Layout.fillWidth: true }
                            Text { text: bluetoothManager.volume + "%"; font.family: theme.displayFont; font.pixelSize: 12; color: theme.blue }
                        }

                        // Slider track
                        Item {
                            width: parent.width; height: 24

                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width; height: 4; radius: 2; color: theme.b1

                                Rectangle {
                                    width: (bluetoothManager.volume / 100) * parent.width
                                    height: 4; radius: 2; color: theme.blue
                                    Behavior on width { NumberAnimation { duration: 60 } }
                                }
                            }

                            Rectangle {
                                id: volKnob
                                anchors.verticalCenter: parent.verticalCenter
                                width: 18; height: 18; radius: 9
                                x: (bluetoothManager.volume / 100) * (parent.width - 18)
                                color: volDrag.pressed ? theme.blue : "#ffffff"
                                border.color: theme.blue; border.width: 2
                                Behavior on x { NumberAnimation { duration: 60 } }
                            }

                            MouseArea {
                                id: volDrag; anchors.fill: parent; hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onPressed:         (e) => applyVol(e.x)
                                onPositionChanged: (e) => { if (pressed) applyVol(e.x) }
                                function applyVol(mx) {
                                    bluetoothManager.setVolume(Math.round(Math.max(0, Math.min(1, mx / parent.width)) * 100))
                                }
                            }
                        }
                    }
                }
            }

            // ── Scan + device list ────────────────────────────────────────────
            BtCard {
                Layout.fillWidth: true
                cardHeight: devicesCol.implicitHeight + 32
                visible: bluetoothManager.bluetoothAvailable

                Column {
                    id: devicesCol
                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16 }
                    spacing: 12

                    // Header row
                    RowLayout {
                        width: parent.width

                        Column {
                            Layout.fillWidth: true; spacing: 3
                            Text { text: "NEARBY & PAIRED DEVICES"; font.family: theme.displayFont; font.pixelSize: 10; font.letterSpacing: 2.5; color: theme.t1 }
                            Text {
                                text: bluetoothManager.statusMsg
                                font.family: theme.displayFont; font.pixelSize: 11; color: theme.t2
                                elide: Text.ElideRight; width: parent.width
                            }
                        }

                        BusyIndicator {
                            running: bluetoothManager.scanning; visible: running
                            implicitWidth: 22; implicitHeight: 22
                        }

                        BtButton {
                            label: bluetoothManager.scanning ? "Stop" : "Scan"
                            danger: bluetoothManager.scanning
                            onAction: bluetoothManager.scanning ? bluetoothManager.stopScan() : bluetoothManager.startScan()
                        }
                    }

                    // Divider
                    Rectangle { width: parent.width; height: 1; color: theme.b1 }

                    // Device rows
                    Repeater {
                        model: bluetoothManager.devices

                        delegate: RowLayout {
                            width: devicesCol.width; spacing: 12
                            property bool isCurrent: bluetoothManager.connectedDevice === modelData.name

                            // Icon
                            Rectangle {
                                width: 38; height: 38; radius: 19
                                color: isCurrent ? Qt.rgba(theme.blue.r, theme.blue.g, theme.blue.b, 0.12) : theme.bgDeep
                                border.color: isCurrent ? theme.blue : theme.b2; border.width: 1
                                Text { anchors.centerIn: parent; text: modelData.paired ? "📱" : "📶"; font.pixelSize: 16 }
                            }

                            Column {
                                Layout.fillWidth: true; spacing: 3
                                Text {
                                    text: modelData.name || modelData.address
                                    font.family: theme.displayFont; font.pixelSize: 14; font.weight: Font.Medium
                                    color: theme.t0; elide: Text.ElideRight; width: parent.width
                                }
                                Text {
                                    text: isCurrent ? "Connected" : (modelData.paired ? "Paired" : "Found nearby")
                                    font.family: theme.displayFont; font.pixelSize: 11
                                    color: isCurrent ? theme.blue : theme.t1
                                }
                            }

                            BtButton {
                                label: isCurrent ? "Disconnect" : "Connect"
                                danger: isCurrent
                                onAction: isCurrent ? bluetoothManager.disconnectDevice() : bluetoothManager.connectDevice(modelData.address)
                            }
                        }
                    }

                    // Empty state
                    Item {
                        width: parent.width; height: 60
                        visible: bluetoothManager.devices.length === 0 && !bluetoothManager.scanning

                        Text {
                            anchors.centerIn: parent
                            text: "No devices found.\nTap Scan to search."
                            font.family: theme.displayFont; font.pixelSize: 13; color: theme.t2
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }

            Item { height: 20 }
        }
    }

    // ── Inline components ─────────────────────────────────────────────────────
    component BtCard: Rectangle {
        property int cardHeight: 60
        property color cardColor: theme.bgCard
        height: cardHeight
        radius: theme.r2
        color:  cardColor
        border.color: theme.b1; border.width: 1
    }

    component BtToggle: Rectangle {
        id: tog
        property bool checked: false
        signal toggled()
        width: 46; height: 26; radius: 13
        color: checked ? theme.blue : theme.b2
        Behavior on color { ColorAnimation { duration: 180 } }

        Rectangle {
            width: 20; height: 20; radius: 10; color: "#fff"
            anchors.verticalCenter: parent.verticalCenter
            x: tog.checked ? parent.width - width - 3 : 3
            Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
        }

        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: tog.toggled() }
    }

    component BtBadge: Rectangle {
        property string label: ""
        property bool   active: false
        property color  activeColor: theme.blue
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

    component BtButton: Item {
        property string label: ""
        property bool   danger: false
        signal action()
        width: btn.width; height: 32

        Rectangle {
            id: btn
            height: 32; radius: 16
            width: btnTxt.implicitWidth + 24
            color: danger
                   ? (ma.containsMouse ? theme.youtubeAc : Qt.rgba(theme.youtubeAc.r, theme.youtubeAc.g, theme.youtubeAc.b, 0.14))
                   : (ma.containsMouse ? theme.blue       : Qt.rgba(theme.blue.r, theme.blue.g, theme.blue.b, 0.14))
            border.color: danger ? theme.youtubeAc : theme.blue; border.width: 1
            Behavior on color { ColorAnimation { duration: 130 } }

            Text {
                id: btnTxt; anchors.centerIn: parent; text: label
                font.family: theme.displayFont; font.pixelSize: 12; font.weight: Font.Medium
                color: danger
                       ? (ma.containsMouse ? "#fff" : theme.youtubeAc)
                       : (ma.containsMouse ? "#fff" : theme.blue)
                Behavior on color { ColorAnimation { duration: 130 } }
            }

            MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: action() }
        }
    }
}
