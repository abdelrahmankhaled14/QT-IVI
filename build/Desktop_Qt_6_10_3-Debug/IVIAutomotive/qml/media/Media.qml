import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    signal closeApp()

    Rectangle {
        anchors.fill: parent
        color: theme.bgSurface
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── Top Bar ───────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 70
            color: theme.bgCard
            border.color: theme.b1
            border.width: 1

            // ── Back Button (Moved inside Top Bar) ──────────────
            Rectangle {
                width: 100; height: 34; radius: theme.r1
                color: backMouse.pressed ? Qt.darker(theme.bgHover, 1.2) : (backMouse.containsMouse ? theme.bgHover : theme.bgCard)
                border.color: theme.b2; border.width: 1

                // Anchored to the left and centered vertically inside the 70px Top Bar
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text: "← Home"
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

            // ── App Title ───────────────────────────────────────
            Text {
                anchors.centerIn: parent
                text: "🌸 Multi Media Player"
                font.pixelSize: 24
                font.bold: true
                color: theme.t0
            }
        }

        // ── Tab Pill Selector ─────────────────────────────────────
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: 380
            height: 44
            radius: theme.rFull
            color: theme.bgDeep
            border.color: theme.b1
            border.width: 1
            Layout.topMargin: 16
            Layout.bottomMargin: 16

            readonly property int tabCount: 3

            property color activeAccent: {
                switch(tabBar.currentIndex) {
                    case 0: return theme.navigationAc
                    case 1: return theme.spotifyAc
                    case 2: return theme.youtubeAc
                    default: return theme.blue
                }
            }

            Rectangle {
                x: {
                    var w = parent.width / parent.tabCount;
                    return tabBar.currentIndex * w + 4;
                }
                y: 4
                width: parent.width / parent.tabCount - 8
                height: parent.height - 8
                radius: theme.rFull
                color: theme.bgCard
                border.color: parent.activeAccent
                border.width: 1

                Behavior on x {
                    NumberAnimation { duration: 200; easing.type: Easing.OutQuart }
                }
                Behavior on border.color {
                    ColorAnimation { duration: 200 }
                }
            }

            RowLayout {
                anchors.fill: parent
                spacing: 0

                Repeater {
                    model: [
                        { icon: "📻", idx: 0 },
                        { icon: "🎵", idx: 1 },
                        { icon: "🎬", idx: 2 }
                    ]

                    Item {
                        Layout.fillWidth: true
                        height: parent.height

                        Text {
                            anchors.centerIn: parent
                            text: modelData.icon
                            font.pixelSize: tabBar.currentIndex === modelData.idx ? 18 : 16
                            opacity: tabBar.currentIndex === modelData.idx ? 1.0 : 0.4

                            Behavior on font.pixelSize { NumberAnimation { duration: 200 } }
                            Behavior on opacity { NumberAnimation { duration: 200 } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: tabBar.currentIndex = modelData.idx
                        }
                    }
                }
            }
        }

        TabBar {
            id: tabBar
            visible: false
            currentIndex: 0
        }

        SwipeView {
            id: swipeView
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: tabBar.currentIndex
            interactive: false
            onCurrentIndexChanged: tabBar.currentIndex = currentIndex

            RadioPage     {}
            AudioPage     {}
            VideoPage     {}
        }
    }
}