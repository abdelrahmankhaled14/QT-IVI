import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    signal closeApp()

    // ── Per-seat state ────────────────────────────────────────────────────────
    property var seats: [
        { name: "Driver",         temp: 22, level: 0, side: "left"  },
        { name: "Passenger",      temp: 22, level: 0, side: "right" },
        { name: "Rear Left",      temp: 20, level: 0, side: "left"  },
        { name: "Rear Right",     temp: 20, level: 0, side: "right" }
    ]

    // Active seat index (which seat the controls apply to)
    property int activeSeat: 0

    // Derived colours from active seat's heat level
    property color accent: {
        var lv = seats[activeSeat].level
        if (lv === 0) return theme.t1
        if (lv === 1) return "#FF8C42"
        return theme.youtubeAc
    }
    Behavior on accent { ColorAnimation { duration: 300 } }

    property color glowCol: {
        var lv = seats[activeSeat].level
        if (lv === 0) return theme.bgDeep
        if (lv === 1) return Qt.rgba(1.0, 0.55, 0.26, 0.18)
        return Qt.rgba(1.0, 0.27, 0.1, 0.22)
    }
    Behavior on glowCol { ColorAnimation { duration: 300 } }

    // Entry animation
    property real _entry: 0
    NumberAnimation on _entry { from: 0; to: 1; duration: 400; easing.type: Easing.OutCubic; running: true }

    // ── Background ────────────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: theme.bgSurface

        // Warm tint overlay driven by heat level
        Rectangle {
            anchors.fill: parent
            color: seats[activeSeat].level > 0
                   ? Qt.rgba(1.0, 0.35, 0.1, 0.04 * seats[activeSeat].level)
                   : "transparent"
            Behavior on color { ColorAnimation { duration: 300 } }
        }
    }

    // Car seat image — full background, dimmed
    Image {
        anchors.fill: parent
        source: "qrc:/assets/carseat.jpg"
        fillMode: Image.PreserveAspectCrop
        opacity: 0.18
    }

    // ── Content (entry-animated) ──────────────────────────────────────────────
    Item {
        anchors.fill: parent
        opacity: root._entry

        // ── Top bar ──────────────────────────────────────────────────────────
        Rectangle {
            id: topBar
            width: parent.width; height: 64; z: 10
            color: Qt.rgba(theme.bgFooter.r, theme.bgFooter.g, theme.bgFooter.b, 0.92)
            border.color: theme.b0

            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: theme.b1 }

            // Home button
            Rectangle {
                width: 100; height: 36; radius: theme.r1
                anchors.left: parent.left; anchors.leftMargin: 16; anchors.verticalCenter: parent.verticalCenter
                color: homeMa.pressed ? Qt.darker(theme.bgHover, 1.2) : homeMa.containsMouse ? theme.bgHover : "transparent"
                border.color: theme.b2; border.width: 1
                Text { text: "← Home"; font.pixelSize: 13; color: theme.t0; anchors.centerIn: parent }
                MouseArea { id: homeMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.closeApp() }
            }

            // Title
            Column {
                anchors.centerIn: parent; spacing: 2
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "SEAT HEAT"
                    font.family: theme.monoFont; font.pixelSize: 18; font.letterSpacing: 4; font.weight: Font.Bold
                    color: theme.t0
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: seats[activeSeat].name + "  ·  " + (seats[activeSeat].level === 0 ? "OFF" : seats[activeSeat].level === 1 ? "LOW" : "HIGH")
                    font.family: theme.monoFont; font.pixelSize: 12; font.letterSpacing: 2; font.weight: Font.Medium
                    color: root.accent
                    Behavior on color { ColorAnimation { duration: 300 } }
                }
            }
        }

        // ── Main body ─────────────────────────────────────────────────────────
        Item {
            anchors.top: topBar.bottom; anchors.bottom: parent.bottom
            anchors.left: parent.left; anchors.right: parent.right

            // ── Seat selector tabs ────────────────────────────────────────────
            Row {
                id: seatTabs
                anchors.top: parent.top; anchors.topMargin: 20
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10

                Repeater {
                    model: root.seats

                    Rectangle {
                        width: 148; height: 54; radius: theme.r1
                        color: activeSeat === index
                               ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.18)
                               : Qt.rgba(1, 1, 1, 0.04)
                        border.color: activeSeat === index ? root.accent : theme.b2
                        border.width: activeSeat === index ? 1.5 : 1
                        Behavior on color { ColorAnimation { duration: 200 } }
                        Behavior on border.color { ColorAnimation { duration: 200 } }

                        Column {
                            anchors.centerIn: parent; spacing: 4
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData.name
                                font.family: theme.displayFont; font.pixelSize: 15; font.weight: Font.DemiBold
                                color: activeSeat === index ? root.accent : theme.t0
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }
                            // Heat level dots
                            Row {
                                anchors.horizontalCenter: parent.horizontalCenter; spacing: 4
                                Repeater {
                                    model: 2
                                    Rectangle {
                                        width: 6; height: 6; radius: 3
                                        color: modelData.level > index ? root.accent : theme.b2
                                        Behavior on color { ColorAnimation { duration: 200 } }
                                    }
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: root.activeSeat = index
                        }
                    }
                }
            }

            // ── Centre: big temp circle + carseat image area ──────────────────
            Item {
                anchors.top: seatTabs.bottom; anchors.topMargin: 20
                anchors.bottom: controlsRow.top; anchors.bottomMargin: 16
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.5

                // Outer pulse glow
                Rectangle {
                    anchors.centerIn: parent
                    width: 200; height: 200; radius: 100
                    color: "transparent"
                    border.color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.10)
                    border.width: 18
                    opacity: seats[activeSeat].level > 0 ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 400 } }
                    Behavior on border.color { ColorAnimation { duration: 300 } }

                    SequentialAnimation on opacity {
                        running: seats[activeSeat].level > 0; loops: Animation.Infinite
                        NumberAnimation { to: 0.6; duration: 1200; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 0.0; duration: 1200; easing.type: Easing.InOutSine }
                    }
                }

                // Main circle
                Rectangle {
                    anchors.centerIn: parent
                    width: 160; height: 160; radius: 80
                    color: root.glowCol
                    border.color: root.accent; border.width: 2
                    Behavior on color { ColorAnimation { duration: 300 } }
                    Behavior on border.color { ColorAnimation { duration: 300 } }

                    // Inner highlight ring
                    Rectangle {
                        anchors.centerIn: parent; width: 148; height: 148; radius: 74
                        color: "transparent"
                        border.color: Qt.rgba(1, 1, 1, 0.06); border.width: 1
                    }

                    Column {
                        anchors.centerIn: parent; spacing: 6

                        // Temperature number
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: seats[activeSeat].level === 0 ? "OFF" : seats[activeSeat].temp + "°"
                            font.family: theme.monoFont
                            font.pixelSize: seats[activeSeat].level === 0 ? 40 : 54
                            font.weight: Font.Bold
                            color: seats[activeSeat].level > 0 ? root.accent : theme.t1
                            Behavior on color { ColorAnimation { duration: 300 } }
                        }

                        // Heat icon
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: seats[activeSeat].level === 0 ? "" : seats[activeSeat].level === 1 ? "🔆" : "🔥"
                            font.pixelSize: 24
                            opacity: seats[activeSeat].level > 0 ? 1 : 0
                            Behavior on opacity { NumberAnimation { duration: 300 } }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var s = root.seats[activeSeat]
                            var newLevel = (s.level + 1) % 3
                            root.seats[activeSeat] = { name: s.name, temp: s.temp, level: newLevel, side: s.side }
                            root.seatsChanged()
                        }
                    }
                }

                // Tap hint
                Text {
                    anchors.top: parent.verticalCenter; anchors.topMargin: 88
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "tap to cycle heat level"
                    font.family: theme.monoFont; font.pixelSize: 11; font.letterSpacing: 1.5
                    color: theme.t1; opacity: 0.9
                }
            }

            // ── Bottom controls: − temp + and heat level ──────────────────────
            Row {
                id: controlsRow
                anchors.bottom: parent.bottom; anchors.bottomMargin: 32
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 24

                // Minus
                Rectangle {
                    width: 54; height: 54; radius: 27
                    color: minMa.containsMouse && seats[activeSeat].level > 0
                           ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.18) : theme.bgDeep
                    border.color: seats[activeSeat].level > 0 ? root.accent : theme.b2; border.width: 1.5
                    opacity: seats[activeSeat].level > 0 ? 1 : 0.3
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 300 } }

                    Text { anchors.centerIn: parent; text: "−"; font.pixelSize: 26; font.weight: Font.Light; color: root.accent; Behavior on color { ColorAnimation { duration: 300 } } }
                    MouseArea {
                        id: minMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (seats[activeSeat].level === 0) return
                            var s = root.seats[activeSeat]
                            if (s.temp > 16) {
                                root.seats[activeSeat] = { name: s.name, temp: s.temp - 1, level: s.level, side: s.side }
                                root.seatsChanged()
                            }
                        }
                    }
                }

                // Heat level pills: Off / Low / High
                Row {
                    spacing: 8; anchors.verticalCenter: parent.verticalCenter

                    Repeater {
                        model: ["Off", "Low", "High"]
                        Rectangle {
                            width: 78; height: 44; radius: 22
                            color: seats[activeSeat].level === index
                                   ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.22)
                                   : Qt.rgba(1, 1, 1, 0.04)
                            border.color: seats[activeSeat].level === index ? root.accent : theme.b2
                            border.width: seats[activeSeat].level === index ? 1.5 : 1
                            Behavior on color { ColorAnimation { duration: 200 } }
                            Behavior on border.color { ColorAnimation { duration: 200 } }

                            Text {
                                anchors.centerIn: parent; text: modelData
                                font.family: theme.displayFont; font.pixelSize: 15; font.weight: Font.DemiBold
                                color: seats[activeSeat].level === index ? root.accent : theme.t1
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }

                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    var s = root.seats[activeSeat]
                                    root.seats[activeSeat] = { name: s.name, temp: s.temp, level: index, side: s.side }
                                    root.seatsChanged()
                                }
                            }
                        }
                    }
                }

                // Plus
                Rectangle {
                    width: 54; height: 54; radius: 27
                    color: plusMa.containsMouse && seats[activeSeat].level > 0
                           ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.25) : root.glowCol
                    border.color: seats[activeSeat].level > 0 ? root.accent : theme.b2; border.width: 1.5
                    opacity: seats[activeSeat].level > 0 ? 1 : 0.3
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 300 } }

                    Text { anchors.centerIn: parent; text: "+"; font.pixelSize: 26; font.weight: Font.Light; color: root.accent; Behavior on color { ColorAnimation { duration: 300 } } }
                    MouseArea {
                        id: plusMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (seats[activeSeat].level === 0) return
                            var s = root.seats[activeSeat]
                            if (s.temp < 36) {
                                root.seats[activeSeat] = { name: s.name, temp: s.temp + 1, level: s.level, side: s.side }
                                root.seatsChanged()
                            }
                        }
                    }
                }
            }
        }
    }
}
