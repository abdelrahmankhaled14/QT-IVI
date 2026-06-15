import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"

Item {
    id: wifiPage

    Component.onCompleted: {
        SettingsManager.wifi.scan()
    }

    // Toast notification
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

    // Password dialog for secured networks
    Dialog {
        id: passwordDialog
        title: "Wi-Fi Password"
        modal: true
        anchors.centerIn: parent
        standardButtons: Dialog.Ok | Dialog.Cancel
        width: 320

        property string targetSsid: ""

        onAccepted: {
            if (passwordField.text.length > 0) {
                SettingsManager.wifi.connectToNetwork(targetSsid, passwordField.text)
                passwordField.text = ""
            }
        }
        onRejected: passwordField.text = ""

        ColumnLayout {
            spacing: theme.spacingMedium
            width: parent.width

            Text {
                text: "Enter password for \"" + passwordDialog.targetSsid + "\""
                font.pixelSize: theme.fontSizeSmall
                color: theme.textPrimary
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }

            TextField {
                id: passwordField
                Layout.fillWidth: true
                echoMode: TextInput.Password
                placeholderText: "Password"
                focus: true
            }
        }
    }

    Connections {
        target: SettingsManager.wifi
        function onConnectionResult(success, message) {
            showToast(success, message)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: theme.spacingLarge
        spacing: theme.spacingMedium

        PageHeader {
            Layout.fillWidth: true
            title: "Wi-Fi"
            subtitle: "Manage wireless networks"
        }

        // WiFi enable switch
        SettingsGroup {
            Layout.fillWidth: true

            SettingsRow {
                label: "Wi-Fi"
                description: "Turn wireless networking on or off"
                showDivider: false

                StyledToggle {
                    id: wifiToggle
                    checked: SettingsManager.wifi.enabled

                    onToggled: (value) => {
                        SettingsManager.wifi.setEnabled(value)
                    }
                }
            }
        }

        // Networks list
        SettingsGroup {
            Layout.fillWidth: true
            groupTitle: "AVAILABLE NETWORKS"
            visible: wifiToggle.checked

            ColumnLayout {
                width: parent.width
                spacing: theme.spacingMedium

                // Header: status + spinner + scan button
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true
                        text: SettingsManager.wifi.statusText
                        color: theme.textSecondary
                        font.pixelSize: theme.fontSizeSmall
                    }

                    BusyIndicator {
                        running: SettingsManager.wifi.scanning
                        visible: running
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20
                    }

                    Rectangle {
                        Layout.preferredHeight: 32
                        Layout.preferredWidth: scanTxt.implicitWidth + 28
                        radius: 16
                        color: scanMa.containsMouse ? theme.blue
                                                    : Qt.rgba(theme.blue.r, theme.blue.g, theme.blue.b, 0.14)
                        border.color: theme.blue; border.width: 1
                        Behavior on color { ColorAnimation { duration: theme.fast } }

                        Text {
                            id: scanTxt
                            anchors.centerIn: parent
                            text: "Scan"
                            font.family: theme.displayFont
                            font.pixelSize: theme.fontSizeSmall; font.weight: Font.Medium
                            color: scanMa.containsMouse ? "#fff" : theme.blue
                            Behavior on color { ColorAnimation { duration: theme.fast } }
                        }
                        MouseArea {
                            id: scanMa
                            anchors.fill: parent
                            hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: SettingsManager.wifi.scan()
                        }
                    }
                }

                // Network list
                ListView {
                    id: networkList
                    Layout.fillWidth: true
                    Layout.preferredHeight: count > 0 ? Math.min(contentHeight, 400) : 0
                    clip: true
                    model: SettingsManager.wifi.networks

                    delegate: SettingsRow {
                        width: networkList.width

                        label: model.ssid
                        description: (model.connected ? "✓ Connected · " : "")
                                   + (model.secured ? "Secured · " : "Open · ")
                                   + model.strength + "% signal"
                        showDivider: index < networkList.count - 1

                        // Action buttons anchored to the right
                        Row {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.rightMargin: theme.spacingMedium
                            spacing: theme.spacingSmall

                            // Forget (neutral) — only when currently connected
                            Rectangle {
                                visible: model.connected
                                width: forgetTxt.implicitWidth + 28
                                height: 30
                                radius: 15
                                color: forgetMa.containsMouse ? theme.bgHover : "transparent"
                                border.color: theme.b2; border.width: 1
                                Behavior on color { ColorAnimation { duration: theme.fast } }

                                Text {
                                    id: forgetTxt
                                    anchors.centerIn: parent
                                    text: "Forget"
                                    color: theme.t1
                                    font.family: theme.displayFont
                                    font.pixelSize: theme.fontSizeSmall; font.weight: Font.Medium
                                }

                                MouseArea {
                                    id: forgetMa
                                    anchors.fill: parent
                                    hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: SettingsManager.wifi.forgetNetwork(model.ssid)
                                }
                            }

                            // Connect (blue) / Disconnect (danger)
                            Rectangle {
                                property bool isDisc: model.connected
                                width: connTxt.implicitWidth + 28
                                height: 30
                                radius: 15
                                color: isDisc
                                       ? (connMa.containsMouse ? theme.danger : Qt.rgba(theme.danger.r, theme.danger.g, theme.danger.b, 0.14))
                                       : (connMa.containsMouse ? theme.blue   : Qt.rgba(theme.blue.r, theme.blue.g, theme.blue.b, 0.14))
                                border.color: isDisc ? theme.danger : theme.blue; border.width: 1
                                Behavior on color { ColorAnimation { duration: theme.fast } }

                                Text {
                                    id: connTxt
                                    anchors.centerIn: parent
                                    text: parent.isDisc ? "Disconnect" : "Connect"
                                    font.family: theme.displayFont
                                    font.pixelSize: theme.fontSizeSmall; font.weight: Font.Medium
                                    color: connMa.containsMouse ? "#fff"
                                                               : (parent.isDisc ? theme.danger : theme.blue)
                                    Behavior on color { ColorAnimation { duration: theme.fast } }
                                }

                                MouseArea {
                                    id: connMa
                                    anchors.fill: parent
                                    hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (model.connected) {
                                            SettingsManager.wifi.disconnect()
                                        } else if (model.secured) {
                                            passwordDialog.targetSsid = model.ssid
                                            passwordDialog.open()
                                        } else {
                                            SettingsManager.wifi.connectToNetwork(model.ssid)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Empty state
                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    visible: networkList.count === 0 && !SettingsManager.wifi.scanning
                    text: "No networks found. Tap Scan to search."
                    color: theme.textSecondary
                    font.pixelSize: theme.fontSizeSmall
                    topPadding: theme.spacingMedium
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
