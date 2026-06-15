import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"

Item {
    id: root
    signal closeApp()

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── Top Bar ──────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true; height: 70
            color: theme.bgCard; border.color: theme.b1; border.width: 1

            Rectangle {
                width: 100; height: 34; radius: theme.r1
                anchors.left: parent.left; anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                color: backMa.pressed ? Qt.darker(theme.bgHover, 1.2)
                     : backMa.containsMouse ? theme.bgHover : theme.bgCard
                border.color: theme.b2; border.width: 1
                Text { text: "← Home"; font.pixelSize: 13; color: theme.t0; anchors.centerIn: parent }
                MouseArea { id: backMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.closeApp() }
            }

            Text {
                anchors.centerIn: parent; text: "Volume"
                font.family: theme.displayFont; font.pixelSize: 20; font.weight: Font.Bold; color: theme.t0
            }
        }

        // ── Settings content ─────────────────────────────────────
        ColumnLayout {
        Layout.fillWidth: true
        Layout.margins: theme.spacingLarge
        spacing: theme.spacingMedium

        SettingsGroup {
            Layout.fillWidth: true
            groupTitle: "OUTPUT"

            SettingsRow {
                label: "Master Volume"
                description: "Current: " + SettingsManager.sound.masterVolume + "%"

                StyledSlider {
                    id: masterSlider
                    from: 0
                    to: 100
                    value: SettingsManager.sound.masterVolume
                    width: 200

                    // Use onMoved to avoid binding loops while dragging
                    onMoved: SettingsManager.sound.setMasterVolume(Math.round(value))
                }
            }

            SettingsRow {
                label: "Mute"
                showDivider: false

                StyledToggle {
                    checked: SettingsManager.sound.mute
                    onToggled: (val) => SettingsManager.sound.setMute(val)
                }
            }
        }

        SettingsGroup {
            Layout.fillWidth: true
            groupTitle: "INPUT"

            SettingsRow {
                label: "Microphone Volume"
                showDivider: false

                StyledSlider {
                    from: 0
                    to: 100
                    value: SettingsManager.sound.micVolume
                    width: 200
                    onMoved: SettingsManager.sound.setMicVolume(Math.round(value))
                }
            }
        }

        Item { Layout.fillHeight: true }
        } // inner ColumnLayout
    } // outer ColumnLayout
}
