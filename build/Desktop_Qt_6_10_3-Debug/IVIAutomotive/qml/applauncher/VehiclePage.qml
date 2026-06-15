import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    signal closeApp()

    // ── Entry animation ───────────────────────────────────────────────────────
    property real _entry: 0
    NumberAnimation on _entry { from: 0; to: 1; duration: 420; easing.type: Easing.OutCubic; running: true }

    // ── Car state data ────────────────────────────────────────────────────────
    // zone groups an item so the summary badges can reflect its health
    readonly property var stateItems: [
        { label: "Engine",          value: "Running",    ok: true,  zone: "engine" },
        { label: "Oil Pressure",    value: "Normal",     ok: true,  zone: "engine" },
        { label: "Coolant Temp",    value: "88 °C",      ok: true,  zone: "engine" },
        { label: "Engine Load",     value: "22 %",       ok: true,  zone: "engine" },
        { label: "Check Engine",    value: "None",       ok: true,  zone: "engine" },
        { label: "Service Due",     value: "1,200 km",   ok: true,  zone: "engine" },

        { label: "Fuel Level",      value: "78 %",       ok: true,  zone: "fuel"   },
        { label: "Est. Range",      value: "420 km",     ok: true,  zone: "fuel"   },
        { label: "Avg Consumption", value: "7.2 L/100",  ok: true,  zone: "fuel"   },

        { label: "Tyre FL",         value: "32 PSI",     ok: true,  zone: "tyre"   },
        { label: "Tyre FR",         value: "31 PSI",     ok: true,  zone: "tyre"   },
        { label: "Tyre RL",         value: "32 PSI",     ok: true,  zone: "tyre"   },
        { label: "Tyre RR",         value: "29 PSI",     ok: false, zone: "tyre"   },

        { label: "All Doors",       value: "Closed",     ok: true,  zone: "body"   },
        { label: "Boot",            value: "Closed",     ok: true,  zone: "body"   },
        { label: "Hood",            value: "Closed",     ok: true,  zone: "body"   },

        { label: "12V Battery",     value: "12.8 V",     ok: true,  zone: "elec"   },
        { label: "Alternator",      value: "14.1 V",     ok: true,  zone: "elec"   },
        { label: "Exterior Lights", value: "OK",         ok: true,  zone: "elec"   }
    ]

    // Sections for the report panel
    readonly property var sections: [
        { title: "POWERTRAIN",   keys: ["Engine","Oil Pressure","Coolant Temp","Engine Load","Check Engine","Service Due"] },
        { title: "FUEL & RANGE", keys: ["Fuel Level","Est. Range","Avg Consumption"] },
        { title: "TYRES",        keys: ["Tyre FL","Tyre FR","Tyre RL","Tyre RR"] },
        { title: "BODY",         keys: ["All Doors","Boot","Hood"] },
        { title: "ELECTRICAL",   keys: ["12V Battery","Alternator","Exterior Lights"] }
    ]

    function zoneOk(zone) {
        for (var i = 0; i < stateItems.length; i++)
            if (stateItems[i].zone === zone && !stateItems[i].ok) return false
        return true
    }
    function getItem(label) {
        for (var i = 0; i < stateItems.length; i++)
            if (stateItems[i].label === label) return stateItems[i]
        return { label: label, value: "—", ok: true, zone: "" }
    }

    property int warningCount: {
        var n = 0
        for (var i = 0; i < stateItems.length; i++) if (!stateItems[i].ok) n++
        return n
    }
    property int healthPct: Math.round((stateItems.length - warningCount) / stateItems.length * 100)
    property bool healthy: warningCount === 0
    // Gauge colour reflects the score, not a single fault: high score stays green
    property color statusColor: healthPct >= 90 ? theme.success
                              : healthPct >= 70 ? theme.navigationAc
                              : theme.youtubeAc
    Behavior on statusColor { ColorAnimation { duration: 300 } }

    onHealthPctChanged: healthArc.requestPaint()
    onStatusColorChanged: healthArc.requestPaint()

    // ── Background: sedan, full bleed, dimmed (kept as-is) ───────────────────
    Rectangle { anchors.fill: parent; color: theme.bgVoid }

    Image {
        anchors.fill: parent
        source: "qrc:/assets/sedancar.jpg"
        fillMode: Image.PreserveAspectCrop
        opacity: 0.22
    }

    // Gradient so the right report panel stays readable
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0;  color: "transparent" }
            GradientStop { position: 0.45; color: "transparent" }
            GradientStop { position: 0.56; color: Qt.rgba(0.03, 0.06, 0.11, 0.85) }
            GradientStop { position: 1.0;  color: Qt.rgba(0.03, 0.06, 0.11, 0.97) }
        }
    }

    // ── Content ───────────────────────────────────────────────────────────────
    Item {
        anchors.fill: parent
        opacity: root._entry

        // ── Top bar ──────────────────────────────────────────────────────────
        Rectangle {
            id: topBar
            width: parent.width; height: 60; z: 10
            color: Qt.rgba(0.04, 0.08, 0.14, 0.94)
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: theme.b1 }

            Rectangle {
                width: 100; height: 34; radius: theme.r1
                anchors.left: parent.left; anchors.leftMargin: 16; anchors.verticalCenter: parent.verticalCenter
                color: homeMa.pressed ? Qt.darker(theme.bgHover, 1.2) : homeMa.containsMouse ? theme.bgHover : Qt.rgba(1,1,1,0.05)
                border.color: theme.b2; border.width: 1
                Text { text: "← Home"; font.pixelSize: 13; color: theme.t0; anchors.centerIn: parent }
                MouseArea { id: homeMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.closeApp() }
            }

            Column {
                anchors.centerIn: parent; spacing: 2
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "VEHICLE REPORT"
                    font.family: theme.monoFont; font.pixelSize: 15; font.letterSpacing: 4; font.weight: Font.Bold; color: theme.t0
                }
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter; spacing: 6
                    Rectangle {
                        width: 7; height: 7; radius: 4; anchors.verticalCenter: parent.verticalCenter
                        color: root.healthy ? theme.success : theme.youtubeAc
                        SequentialAnimation on opacity {
                            running: !root.healthy; loops: Animation.Infinite
                            NumberAnimation { to: 0.15; duration: 600 }
                            NumberAnimation { to: 1.0;  duration: 600 }
                        }
                    }
                    Text {
                        text: root.healthy ? "All systems normal"
                                           : root.warningCount + " warning" + (root.warningCount > 1 ? "s" : "") + " detected"
                        font.family: theme.monoFont; font.pixelSize: 10; font.letterSpacing: 1.5
                        color: root.healthy ? theme.success : theme.youtubeAc
                    }
                }
            }

            Text {
                anchors.right: parent.right; anchors.rightMargin: 20; anchors.verticalCenter: parent.verticalCenter
                text: Qt.formatDateTime(new Date(), "ddd HH:mm")
                font.family: theme.monoFont; font.pixelSize: 11; color: theme.t2
            }
        }

        // ── Body ──────────────────────────────────────────────────────────────
        Item {
            anchors.top: topBar.bottom; anchors.bottom: parent.bottom
            anchors.left: parent.left; anchors.right: parent.right

            // ── LEFT: health gauge + system badges (over the car) ─────────────
            Item {
                id: leftPanel
                anchors.top: parent.top; anchors.bottom: parent.bottom
                anchors.left: parent.left
                width: parent.width * 0.54

                Column {
                    anchors.centerIn: parent
                    spacing: 30

                    // ── Health gauge ──────────────────────────────────────────
                    Item {
                        width: 200; height: 200
                        anchors.horizontalCenter: parent.horizontalCenter

                        // Soft pulse halo
                        Rectangle {
                            anchors.centerIn: parent
                            width: 200; height: 200; radius: 100; color: "transparent"
                            border.color: Qt.rgba(root.statusColor.r, root.statusColor.g, root.statusColor.b, 0.12)
                            border.width: 14; opacity: 0
                            SequentialAnimation on opacity {
                                running: true; loops: Animation.Infinite
                                NumberAnimation { to: 0.6; duration: root.healthy ? 1900 : 700; easing.type: Easing.InOutSine }
                                NumberAnimation { to: 0.0; duration: root.healthy ? 1900 : 700; easing.type: Easing.InOutSine }
                            }
                        }

                        // Progress arc
                        Canvas {
                            id: healthArc
                            anchors.centerIn: parent
                            width: 180; height: 180
                            onPaint: {
                                var ctx = getContext("2d"); ctx.reset()
                                var cx = width/2, cy = height/2, r = width/2 - 8
                                ctx.beginPath(); ctx.arc(cx, cy, r, 0, 2*Math.PI)
                                ctx.lineWidth = 7; ctx.strokeStyle = Qt.rgba(1,1,1,0.08); ctx.stroke()
                                var start = -Math.PI/2
                                var end = start + 2*Math.PI*(root.healthPct/100)
                                ctx.beginPath(); ctx.arc(cx, cy, r, start, end)
                                ctx.lineWidth = 7; ctx.lineCap = "round"; ctx.strokeStyle = root.statusColor; ctx.stroke()
                            }
                            Component.onCompleted: requestPaint()
                        }

                        // Inner disc
                        Rectangle {
                            anchors.centerIn: parent
                            width: 150; height: 150; radius: 75
                            color: Qt.rgba(0.05, 0.09, 0.15, 0.85)
                            border.color: Qt.rgba(root.statusColor.r, root.statusColor.g, root.statusColor.b, 0.35)
                            border.width: 1.5

                            Column {
                                anchors.centerIn: parent; spacing: 2
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: root.healthPct + "%"
                                    font.family: theme.monoFont; font.pixelSize: 44; font.weight: Font.Bold
                                    color: root.statusColor
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "VEHICLE HEALTH"
                                    font.family: theme.monoFont; font.pixelSize: 9; font.letterSpacing: 2; color: theme.t2
                                }
                            }
                        }
                    }

                    // ── System status badges ──────────────────────────────────
                    Grid {
                        anchors.horizontalCenter: parent.horizontalCenter
                        columns: 3; rowSpacing: 10; columnSpacing: 10

                        Repeater {
                            model: [
                                { label: "ENGINE", icon: "⚙",  ok: root.zoneOk("engine") },
                                { label: "FUEL",   icon: "⛽", ok: root.zoneOk("fuel")   },
                                { label: "TYRES",  icon: "🛞", ok: root.zoneOk("tyre")   },
                                { label: "BODY",   icon: "🚪", ok: root.zoneOk("body")   },
                                { label: "ELEC",   icon: "🔋", ok: root.zoneOk("elec")   }
                            ]
                            Rectangle {
                                width: 116; height: 52; radius: theme.r1
                                color: modelData.ok ? Qt.rgba(0.13, 0.78, 0.37, 0.10) : Qt.rgba(1.0, 0.55, 0.1, 0.12)
                                border.color: modelData.ok ? Qt.rgba(0.13, 0.78, 0.37, 0.45) : theme.youtubeAc
                                border.width: 1

                                Row {
                                    anchors.centerIn: parent; spacing: 9
                                    Text { text: modelData.icon; font.pixelSize: 18; anchors.verticalCenter: parent.verticalCenter }
                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter; spacing: 2
                                        Text {
                                            text: modelData.label
                                            font.family: theme.monoFont; font.pixelSize: 11; font.letterSpacing: 1.5; font.weight: Font.Bold
                                            color: theme.t0
                                        }
                                        Text {
                                            text: modelData.ok ? "OK" : "CHECK"
                                            font.family: theme.monoFont; font.pixelSize: 9; font.letterSpacing: 1
                                            color: modelData.ok ? theme.success : theme.youtubeAc
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ── RIGHT: detailed report ────────────────────────────────────────
            ScrollView {
                anchors.top: parent.top; anchors.bottom: parent.bottom
                anchors.right: parent.right
                width: parent.width * 0.46
                anchors.topMargin: 14; anchors.bottomMargin: 14
                contentWidth: availableWidth; clip: true

                Column {
                    id: reportCol
                    width: parent.width
                    spacing: 14
                    topPadding: 4; bottomPadding: 8

                    Repeater {
                        model: root.sections

                        // Section block (plain Column respects explicit heights)
                        Column {
                            id: sectionDelegate
                            required property var modelData
                            width: reportCol.width - 30
                            x: 8
                            spacing: 6

                            // Section header
                            Row {
                                spacing: 8
                                Rectangle { width: 3; height: 12; radius: 2; anchors.verticalCenter: parent.verticalCenter; color: theme.blue; opacity: 0.8 }
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: sectionDelegate.modelData.title
                                    font.family: theme.monoFont; font.pixelSize: 9; font.letterSpacing: 2.5; color: theme.t2
                                }
                            }

                            // Section card
                            Rectangle {
                                width: parent.width
                                height: sectionCol.implicitHeight
                                radius: theme.r2
                                color: Qt.rgba(1, 1, 1, 0.04)
                                border.color: theme.b1; border.width: 1
                                clip: true

                                Column {
                                    id: sectionCol
                                    width: parent.width

                                    Repeater {
                                        model: sectionDelegate.modelData.keys
                                        delegate: Item {
                                            id: rowDelegate
                                            required property string modelData
                                            required property int index
                                            property var item: root.getItem(modelData)
                                            width: sectionCol.width; height: 38

                                            Rectangle {
                                                visible: index > 0
                                                anchors.top: parent.top
                                                anchors.left: parent.left; anchors.leftMargin: 12
                                                anchors.right: parent.right; anchors.rightMargin: 12
                                                height: 1; color: theme.b1; opacity: 0.5
                                            }

                                            Rectangle {
                                                width: 2; height: 18; radius: 1
                                                anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                                                color: rowDelegate.item.ok ? theme.success : theme.youtubeAc
                                            }

                                            Text {
                                                anchors.left: parent.left; anchors.leftMargin: 14
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: rowDelegate.item.label
                                                font.family: theme.displayFont; font.pixelSize: 12; color: theme.t1
                                            }

                                            Row {
                                                anchors.right: parent.right; anchors.rightMargin: 12
                                                anchors.verticalCenter: parent.verticalCenter; spacing: 7
                                                Text {
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    text: rowDelegate.item.value
                                                    font.family: theme.monoFont; font.pixelSize: 12; font.weight: Font.Medium
                                                    color: rowDelegate.item.ok ? theme.t0 : theme.youtubeAc
                                                }
                                                Rectangle {
                                                    width: 7; height: 7; radius: 4; anchors.verticalCenter: parent.verticalCenter
                                                    color: rowDelegate.item.ok ? theme.success : theme.youtubeAc
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
