import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: theme.sidebarBg

    property int currentIndex: 0
    signal navigate(int index)

    // Navigation items — add new pages here only
    readonly property var items: [
        { label: "Wi-Fi"      },
        { label: "Bluetooth"  },
        { label: "Sound"      },
        { label: "Appearance" },
    ]

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // App title / header
        Rectangle {
            Layout.fillWidth: true
            height: 60
            color: "transparent"

            Text {
                anchors.centerIn: parent
                text: "Settings"
                font.family: theme.displayFont
                font.pixelSize: theme.fontSizeTitle
                font.weight: theme.fontWeightBold
                color: theme.t0
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: theme.divider
        }

        // Nav list
        ListView {
            id: navList
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: root.items
            interactive: false
            spacing: 2
            topMargin: theme.spacingSmall
            bottomMargin: theme.spacingSmall

            delegate: SidebarItem {
                width: navList.width
                height: theme.sidebarItemH
                label:     modelData.label
                isActive:  root.currentIndex === index
                onClicked: root.navigate(index)
            }
        }
    }
}
