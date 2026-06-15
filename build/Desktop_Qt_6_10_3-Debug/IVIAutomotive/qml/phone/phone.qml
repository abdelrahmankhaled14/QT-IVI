import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    signal closeApp()

    property int currentTab: 0
    property string dialedNumber: ""

    function fmtDuration(s) {
        var m = Math.floor(s / 60), sec = s % 60
        return m + ":" + (sec < 10 ? "0" : "") + sec
    }

    // ── Background ────────────────────────────────────────────────
    Rectangle { anchors.fill: parent; color: theme.bgSurface }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── Top Bar ───────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 70
            color: theme.bgFooter
            border.color: theme.b1; border.width: 1
            z: 10

            Rectangle {
                width: 100; height: 34; radius: theme.r1
                color: backMouse.pressed ? Qt.darker(theme.bgHover, 1.2) : (backMouse.containsMouse ? theme.bgHover : theme.bgCard)
                border.color: theme.b2; border.width: 1
                anchors.left: parent.left; anchors.leftMargin: 16; anchors.verticalCenter: parent.verticalCenter
                Text { text: "← Home"; font.pixelSize: 13; color: theme.t0; anchors.centerIn: parent }
                MouseArea { id: backMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.closeApp() }
            }

            Column {
                anchors.centerIn: parent; spacing: 2
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Phone"; font.pixelSize: 20; font.bold: true; color: theme.t0 }
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter; spacing: 6
                    Rectangle {
                        width: 7; height: 7; radius: 4; anchors.verticalCenter: parent.verticalCenter
                        color: phoneManager.phoneConnected ? theme.success : theme.t2
                    }
                    Text {
                        text: phoneManager.phoneConnected ? phoneManager.deviceName : "No phone connected"
                        font.pixelSize: 11; font.family: theme.monoFont; color: theme.t1
                    }
                }
            }

            // Sync button
            Rectangle {
                width: 96; height: 34; radius: theme.r1
                anchors.right: parent.right; anchors.rightMargin: 16; anchors.verticalCenter: parent.verticalCenter
                visible: phoneManager.phoneConnected
                color: syncMouse.pressed ? Qt.darker(theme.phoneAc, 1.2)
                     : phoneManager.syncing ? theme.bgCard
                     : Qt.rgba(theme.phoneAc.r, theme.phoneAc.g, theme.phoneAc.b, 0.15)
                border.color: theme.phoneBord; border.width: 1
                Row {
                    anchors.centerIn: parent; spacing: 6
                    BusyIndicator { running: phoneManager.syncing; visible: running; implicitWidth: 16; implicitHeight: 16 }
                    Text { text: phoneManager.syncing ? "Syncing" : "⟳ Sync"; font.pixelSize: 12; color: theme.phoneAc; anchors.verticalCenter: parent.verticalCenter }
                }
                MouseArea { id: syncMouse; anchors.fill: parent; enabled: !phoneManager.syncing; cursorShape: Qt.PointingHandCursor; onClicked: phoneManager.syncPhonebook() }
            }
        }

        // ── Body ──────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true; Layout.fillHeight: true; spacing: 0

            // ── Sidebar ────────────────────────────────────────────
            Rectangle {
                Layout.preferredWidth: Math.max(160, Math.min(260, parent.width * 0.25))
                Layout.fillHeight: true
                color: theme.bgCard
                border.color: theme.b1; border.width: 1

                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 12; anchors.topMargin: 20; spacing: 8

                    Repeater {
                        model: [
                            { name: "Keypad",   icon: "🔢" },
                            { name: "Contacts", icon: "👤" },
                            { name: "Recents",  icon: "🕒" }
                        ]
                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: 52; radius: theme.r2
                            color: root.currentTab === index ? theme.phoneGlow : (tabMouse.containsMouse ? theme.bgHover : "transparent")
                            border.color: root.currentTab === index ? theme.phoneBord : "transparent"; border.width: 1
                            Behavior on color { ColorAnimation { duration: theme.fast } }
                            RowLayout {
                                anchors.fill: parent; anchors.margins: 12; spacing: 12
                                Text { text: modelData.icon; font.pixelSize: 18; color: root.currentTab === index ? theme.phoneAc : theme.t1 }
                                Text { text: modelData.name; font.pixelSize: 15; font.bold: root.currentTab === index; color: root.currentTab === index ? theme.phoneAc : theme.t1; Layout.fillWidth: true }
                                // Count badge
                                Rectangle {
                                    visible: (index === 1 && phoneManager.contacts.length > 0) || (index === 2 && phoneManager.recents.length > 0)
                                    width: cnt.implicitWidth + 12; height: 18; radius: 9
                                    color: Qt.rgba(theme.phoneAc.r, theme.phoneAc.g, theme.phoneAc.b, 0.18)
                                    Text { id: cnt; anchors.centerIn: parent; text: index === 1 ? phoneManager.contacts.length : phoneManager.recents.length; font.pixelSize: 10; color: theme.phoneAc }
                                }
                            }
                            MouseArea { id: tabMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.currentTab = index }
                        }
                    }
                    Item { Layout.fillHeight: true }

                    // Status line
                    Text {
                        Layout.fillWidth: true
                        text: phoneManager.statusMsg
                        font.pixelSize: 10; font.family: theme.monoFont; color: theme.t2
                        wrapMode: Text.WordWrap
                    }
                }
            }

            // ── Content ────────────────────────────────────────────
            StackLayout {
                Layout.fillWidth: true; Layout.fillHeight: true
                currentIndex: root.currentTab

                // ═══ 1. KEYPAD ═══
                Item {
                    id: keypadArea
                    property real keySize: Math.max(40, Math.min(86, keypadArea.height / 8.5))
                    property real spacingSize: keySize * 0.25

                    ColumnLayout {
                        anchors.centerIn: parent
                        width: Math.min(parent.width * 0.8, 400)
                        spacing: keypadArea.spacingSize * 2

                        RowLayout {
                            Layout.fillWidth: true; Layout.preferredHeight: keypadArea.keySize
                            Text {
                                Layout.fillWidth: true
                                text: root.dialedNumber.length > 0 ? root.dialedNumber : "Enter Number"
                                font.pixelSize: root.dialedNumber.length > 0 ? keypadArea.keySize * 0.5 : keypadArea.keySize * 0.35
                                font.bold: true
                                color: root.dialedNumber.length > 0 ? theme.t0 : theme.t2
                                horizontalAlignment: Text.AlignHCenter; elide: Text.ElideLeft
                            }
                            Rectangle {
                                width: keypadArea.keySize * 0.7; height: width; radius: theme.rFull
                                color: bsMouse.pressed ? theme.bgHover : "transparent"
                                visible: root.dialedNumber.length > 0
                                Text { anchors.centerIn: parent; text: "⌫"; font.pixelSize: parent.width * 0.4; color: theme.t1 }
                                MouseArea {
                                    id: bsMouse; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: root.dialedNumber = root.dialedNumber.slice(0, -1)
                                    onPressAndHold: root.dialedNumber = ""
                                }
                            }
                        }

                        GridLayout {
                            Layout.alignment: Qt.AlignHCenter
                            columns: 3
                            rowSpacing: keypadArea.spacingSize; columnSpacing: keypadArea.spacingSize * 1.5
                            Repeater {
                                model: [
                                    { n: "1", l: "" },     { n: "2", l: "ABC" },  { n: "3", l: "DEF" },
                                    { n: "4", l: "GHI" },  { n: "5", l: "JKL" },  { n: "6", l: "MNO" },
                                    { n: "7", l: "PQRS" }, { n: "8", l: "TUV" },  { n: "9", l: "WXYZ" },
                                    { n: "*", l: "" },     { n: "0", l: "+" },    { n: "#", l: "" }
                                ]
                                Rectangle {
                                    Layout.preferredWidth: keypadArea.keySize; Layout.preferredHeight: keypadArea.keySize
                                    radius: theme.rFull
                                    color: keyMouse.pressed ? theme.bgHover : theme.bgCard
                                    border.color: theme.b1; border.width: 1
                                    Column {
                                        anchors.centerIn: parent; spacing: -2
                                        Text { text: modelData.n; font.pixelSize: keypadArea.keySize * 0.35; font.bold: true; color: theme.t0; anchors.horizontalCenter: parent.horizontalCenter }
                                        Text { text: modelData.l; font.pixelSize: keypadArea.keySize * 0.12; color: theme.t1; visible: modelData.l !== ""; anchors.horizontalCenter: parent.horizontalCenter }
                                    }
                                    MouseArea { id: keyMouse; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.dialedNumber += modelData.n }
                                }
                            }
                        }

                        // Call button
                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.topMargin: keypadArea.spacingSize
                            width: keypadArea.keySize * 1.15; height: width; radius: theme.rFull
                            opacity: root.dialedNumber.length > 0 ? 1.0 : 0.4
                            color: callMouse.pressed ? Qt.darker(theme.phoneAc, 1.2) : theme.phoneAc
                            border.color: theme.phoneBord; border.width: 1
                            Rectangle { anchors.fill: parent; radius: theme.rFull; color: "transparent"; border.color: theme.phoneGlow; border.width: 3 }
                            Text { text: "📞"; font.pixelSize: parent.width * 0.4; anchors.centerIn: parent }
                            MouseArea {
                                id: callMouse; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: if (root.dialedNumber.length > 0) phoneManager.dial(root.dialedNumber, "")
                            }
                        }
                    }
                }

                // ═══ 2. CONTACTS ═══
                Item {
                    // Empty state
                    Column {
                        anchors.centerIn: parent; spacing: 10
                        visible: phoneManager.contacts.length === 0
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "👤"; font.pixelSize: 40; opacity: 0.5 }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: phoneManager.phoneConnected ? "No contacts yet — tap Sync above" : "Connect your phone to see contacts"; color: theme.t1; font.pixelSize: 15 }
                    }

                    ListView {
                        anchors.fill: parent; anchors.margins: 24; spacing: 12; clip: true
                        visible: phoneManager.contacts.length > 0
                        model: phoneManager.contacts

                        delegate: Rectangle {
                            width: ListView.view.width; height: 74; radius: theme.r2
                            color: contactMouse.pressed ? theme.bgHover : theme.bgCard
                            border.color: theme.b1; border.width: 1
                            RowLayout {
                                anchors.fill: parent; anchors.margins: 16; spacing: 16
                                Rectangle {
                                    width: 44; height: 44; radius: theme.rFull
                                    color: theme.bgDeep; border.color: theme.b1; border.width: 1
                                    Text { anchors.centerIn: parent; text: (modelData.name || "?").charAt(0).toUpperCase(); font.pixelSize: 18; font.bold: true; color: theme.t0 }
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true; spacing: 2
                                    Text { text: modelData.name; color: theme.t0; font.pixelSize: 16; font.bold: true; elide: Text.ElideRight; Layout.fillWidth: true }
                                    Text { text: modelData.tag + " • " + modelData.number; color: theme.t1; font.pixelSize: 13; elide: Text.ElideRight; Layout.fillWidth: true }
                                }
                                Rectangle {
                                    width: 44; height: 44; radius: theme.rFull
                                    color: callBtnMouse.pressed ? Qt.darker(theme.phoneGlow, 1.3) : theme.phoneGlow
                                    border.color: theme.phoneBord; border.width: 1
                                    Text { anchors.centerIn: parent; text: "📞"; font.pixelSize: 18; color: theme.phoneAc }
                                    MouseArea { id: callBtnMouse; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: phoneManager.dial(modelData.number, modelData.name) }
                                }
                            }
                            MouseArea {
                                id: contactMouse; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: { root.dialedNumber = modelData.number; root.currentTab = 0 }
                            }
                        }
                    }
                }

                // ═══ 3. RECENTS ═══
                Item {
                    Column {
                        anchors.centerIn: parent; spacing: 10
                        visible: phoneManager.recents.length === 0
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "🕒"; font.pixelSize: 40; opacity: 0.5 }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: phoneManager.phoneConnected ? "No recent calls — tap Sync above" : "Connect your phone to see call history"; color: theme.t1; font.pixelSize: 15 }
                    }

                    ListView {
                        anchors.fill: parent; anchors.margins: 24; spacing: 10; clip: true
                        visible: phoneManager.recents.length > 0
                        model: phoneManager.recents

                        delegate: Rectangle {
                            width: ListView.view.width; height: 66; radius: theme.r2
                            color: recMouse.pressed ? theme.bgHover : theme.bgCard
                            border.color: theme.b1; border.width: 1
                            RowLayout {
                                anchors.fill: parent; anchors.margins: 16; spacing: 14
                                // Direction icon
                                Rectangle {
                                    width: 38; height: 38; radius: theme.rFull
                                    color: theme.bgDeep; border.width: 1
                                    border.color: modelData.direction === "missed" ? theme.youtubeAc
                                                : modelData.direction === "outgoing" ? theme.phoneBord : theme.b1
                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.direction === "missed" ? "↙" : modelData.direction === "outgoing" ? "↗" : "↘"
                                        font.pixelSize: 18; font.bold: true
                                        color: modelData.direction === "missed" ? theme.youtubeAc
                                             : modelData.direction === "outgoing" ? theme.phoneAc : theme.success
                                    }
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true; spacing: 2
                                    Text {
                                        text: modelData.name; font.pixelSize: 15; font.bold: true; elide: Text.ElideRight; Layout.fillWidth: true
                                        color: modelData.direction === "missed" ? theme.youtubeAc : theme.t0
                                    }
                                    Text { text: (modelData.direction === "missed" ? "Missed" : modelData.direction === "outgoing" ? "Outgoing" : "Incoming") + (modelData.time ? "  •  " + modelData.time : ""); color: theme.t1; font.pixelSize: 12 }
                                }
                                Rectangle {
                                    width: 40; height: 40; radius: theme.rFull
                                    color: recCallMouse.pressed ? Qt.darker(theme.phoneGlow, 1.3) : theme.phoneGlow
                                    border.color: theme.phoneBord; border.width: 1
                                    Text { anchors.centerIn: parent; text: "📞"; font.pixelSize: 16; color: theme.phoneAc }
                                    MouseArea { id: recCallMouse; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: phoneManager.dial(modelData.number, modelData.name) }
                                }
                            }
                            MouseArea { id: recMouse; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { root.dialedNumber = modelData.number; root.currentTab = 0 } }
                        }
                    }
                }
            }
        }
    }

    // ════════════════════════════════════════════════════════════════
    //  IN-CALL OVERLAY
    // ════════════════════════════════════════════════════════════════
    Rectangle {
        id: callOverlay
        anchors.fill: parent
        visible: phoneManager.callState !== "idle"
        color: Qt.rgba(0.02, 0.05, 0.09, 0.97)
        z: 100

        // Block clicks behind
        MouseArea { anchors.fill: parent }

        Column {
            anchors.centerIn: parent
            spacing: 24

            // Avatar
            Rectangle {
                width: 120; height: 120; radius: 60
                anchors.horizontalCenter: parent.horizontalCenter
                color: theme.bgCard
                border.color: theme.phoneAc; border.width: 2

                // Pulse ring while dialing/incoming
                Rectangle {
                    anchors.centerIn: parent; width: 120; height: 120; radius: 60
                    color: "transparent"; border.color: theme.phoneAc; border.width: 2; opacity: 0
                    SequentialAnimation on opacity {
                        running: phoneManager.callState === "dialing" || phoneManager.callState === "incoming"
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.6; duration: 900 }
                        NumberAnimation { to: 0.0; duration: 900 }
                    }
                    SequentialAnimation on scale {
                        running: phoneManager.callState === "dialing" || phoneManager.callState === "incoming"
                        loops: Animation.Infinite
                        NumberAnimation { from: 1.0; to: 1.5; duration: 1800 }
                    }
                }
                Text {
                    anchors.centerIn: parent
                    text: (phoneManager.activeName && phoneManager.activeName.length > 0)
                          ? phoneManager.activeName.charAt(0).toUpperCase() : "📞"
                    font.pixelSize: 48; font.bold: true; color: theme.phoneAc
                }
            }

            // Name / number
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: (phoneManager.activeName && phoneManager.activeName.length > 0) ? phoneManager.activeName : phoneManager.activeNumber
                font.pixelSize: 26; font.bold: true; color: theme.t0
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: phoneManager.activeName && phoneManager.activeName.length > 0 ? phoneManager.activeNumber : ""
                font.pixelSize: 15; font.family: theme.monoFont; color: theme.t1
            }

            // Status / duration
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: phoneManager.callState === "dialing"  ? "Calling…"
                    : phoneManager.callState === "incoming" ? "Incoming call"
                    : root.fmtDuration(phoneManager.callSeconds)
                font.pixelSize: 16; font.family: theme.monoFont
                color: phoneManager.callState === "active" ? theme.success : theme.phoneAc
            }

            Item { width: 1; height: 20 }

            // Action buttons
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 40

                // Answer (incoming only)
                Rectangle {
                    width: 72; height: 72; radius: 36
                    visible: phoneManager.callState === "incoming"
                    color: ansMouse.pressed ? Qt.darker(theme.success, 1.2) : theme.success
                    Text { anchors.centerIn: parent; text: "📞"; font.pixelSize: 30 }
                    MouseArea { id: ansMouse; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: phoneManager.answer() }
                }

                // Hang up
                Rectangle {
                    width: 72; height: 72; radius: 36
                    color: hupMouse.pressed ? Qt.darker(theme.youtubeAc, 1.2) : theme.youtubeAc
                    Text { anchors.centerIn: parent; text: "📵"; font.pixelSize: 30 }
                    MouseArea { id: hupMouse; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: phoneManager.hangup() }
                }
            }
        }
    }
}
