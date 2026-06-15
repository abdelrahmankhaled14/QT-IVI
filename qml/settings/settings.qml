// qml/settings/settings.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "qml/sidebar"
import "qml/pages"

Page {
    id: root

    title: "Settings"

    // Add the signal so the back button can close the app
    signal closeApp()

    background: Rectangle {
        color: theme.background
    }

    // ── Top Bar (Header) ──────────────────────────────────────────
    header: Rectangle {
        width: parent.width
        height: 70
        color: theme.background
        border.color: theme.divider
        border.width: 1

        // ── Back Button ───────────────────────────────────────────
        Rectangle {
            width: 100; height: 34; radius: theme.r1 || 8
            color: backMouse.pressed ? Qt.darker(theme.bgHover, 1.2) : (backMouse.containsMouse ? theme.bgHover : theme.background)
            border.color: theme.divider; border.width: 1

            // Anchored to the left and centered vertically inside the header
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter

            Text {
                text: "← Home"
                font.family: theme.displayFont
                font.pixelSize: 13; color: theme.t0
                anchors.centerIn: parent
            }

            MouseArea {
                id: backMouse
                anchors.fill: parent
                hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onClicked: root.closeApp()
            }
        }

        // ── App Title ─────────────────────────────────────────────
        Text {
            anchors.centerIn: parent
            text: "⚙  " + root.title
            font.family: theme.displayFont
            font.pixelSize: theme.fontSizeHeading
            font.weight: theme.fontWeightBold
            color: theme.t0
        }
    }

    // ── Main Content (Automatically sits below the header) ────────
    RowLayout {
        anchors.fill: parent
        spacing: 0

        Sidebar {
            id: sidebar
            Layout.fillHeight: true
            Layout.preferredWidth: theme.sidebarWidth
            currentIndex: stack.currentIndex
            onNavigate: (idx) => stack.currentIndex = idx
        }

        Rectangle {
            Layout.fillHeight: true
            width: 1
            color: theme.divider
        }

        StackLayout {
            id: stack
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: 0

            WifiPage      {}
            BluetoothPage {}
            VolumePage    {}
            ThemePage     {}
        }
    }
}