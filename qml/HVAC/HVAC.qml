import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.settings 1.0
import "."  // Import current directory for HVACState

// ──────────────────────────────────────────────────────────────────────────────
//  HVAC.qml - Full Climate Control App with OFF/COLD/HOT States
//  Integrated with HVACState singleton for dashboard sync
// ──────────────────────────────────────────────────────────────────────────────
Item {
    id: hvac

    // ══════════════════════════════════════════════════════════════════
    // DIRECT SINGLETON BINDINGS
    // ══════════════════════════════════════════════════════════════════
    property bool systemOn:   HVACState.systemOn
    property bool heating:    HVACState.heating
    property int  temperature: HVACState.temperature
    property int  fanSpeed:    HVACState.fanSpeed
    property bool ventsOpen:   HVACState.ventsOpen

    // ── Derived / constants ──────────────────────────────────────────────────
    readonly property int  tempMin:  16
    readonly property int  tempMax:  30
    readonly property real tempPct:  (temperature - tempMin) / (tempMax - tempMin)

    // Animated accent - changes color based on system state and heating mode
    property color _liveAccent: !systemOn ? theme.t2 : (heating ? theme.youtubeAc : theme.climateAc)
    Behavior on _liveAccent { ColorAnimation { duration: theme.slow } }

    property color _liveGlow:   !systemOn ? theme.bgDeep : (heating ? theme.youtubeGlow : theme.climateGlow)
    Behavior on _liveGlow   { ColorAnimation { duration: theme.slow } }

    property color _liveBord:   !systemOn ? theme.b1 : (heating ? theme.youtubeBord : theme.climateBord)
    Behavior on _liveBord   { ColorAnimation { duration: theme.slow } }

    // ── Entry animation ──────────────────────────────────────────────────────
    property real _entry: 0
    NumberAnimation on _entry {
        from: 0; to: 1
        duration: theme.slow + 80
        easing.type: Easing.OutCubic
        running: true
    }

    // ════════════════════════════════════════════════════════════════════════
    //  BACKGROUND
    // ════════════════════════════════════════════════════════════════════════
    Rectangle {
        anchors.fill: parent
        color: theme.bgSurface

        // Subtle tinted wash
        Rectangle {
            anchors.fill: parent
            color: !systemOn ? "transparent" :(heating ? Qt.rgba(1.0, 0.27, 0.27, 0.055): Qt.rgba(0.0, 0.831, 0.604, 0.045))
            Behavior on color { ColorAnimation { duration: theme.slow } }
        }

        // Top-center ambient bloom
        Rectangle {
            width: parent.width * 0.55
            height: 320
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: -160
            radius: width / 2
            color: !systemOn ? "transparent" :(heating ? Qt.rgba(1.0, 0.27, 0.27, 0.045): Qt.rgba(0.0, 0.831, 0.604, 0.04))
            Behavior on color { ColorAnimation { duration: theme.slow } }
        }
    }

    // ════════════════════════════════════════════════════════════════════════
    //  ALL CONTENT  (rides the entry animation)
    // ════════════════════════════════════════════════════════════════════════
    Item {
        anchors.fill: parent
        opacity: hvac._entry
        transform: Translate { y: (1 - hvac._entry) * 48 }

        // ── TOP BAR home button and app name
        Item {
            id: topBar
            anchors { top: parent.top; left: parent.left; right: parent.right }
            anchors.margins: 18
            height: 46

            // ← Back / pop
            Rectangle {
                id: backBtn
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: 112; height: 40
                radius: theme.rFull
                color: theme.bgCard
                border.color: theme.b2
                border.width: 1

                // Hover glow
                Rectangle {
                    id: backHover
                    anchors.fill: parent
                    radius: parent.radius
                    color: theme.blueGlow
                    opacity: 0
                    Behavior on opacity { NumberAnimation { duration: theme.fast } }
                }

                Row {
                    anchors.centerIn: parent
                    spacing: 8
                    Text {
                        text: "←"
                        color: theme.t1
                        font.pixelSize: 17
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "Home"
                        color: theme.t1
                        font.pixelSize: 14
                        font.family: theme.displayFont
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: backHover.opacity = 1
                    onExited:  backHover.opacity = 0
                    onClicked: {
                        if (hvac.StackView.view)
                            hvac.StackView.view.pop()
                    }
                }
            }

            // Title
            Text {
                anchors.centerIn: parent
                text: "C L I M A T E"
                color: theme.t0
                font.pixelSize: 15
                font.letterSpacing: 5
                font.bold: true
                font.family: theme.displayFont
            }

        }

        // ── BODY (two columns)
        Item {
            anchors {
                top: topBar.bottom; topMargin: 10
                bottom: parent.bottom; bottomMargin: 22
                left: parent.left;  leftMargin: 24
                right: parent.right; rightMargin: 24
            }

            // ── LEFT COLUMN — Temperature Orb ────────────────────────────────
            Item {
                id: leftCol
                anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
                width: parent.width * 0.46

                // Orb container
                Item {
                    id: orbWrap
                    width: Math.min(leftCol.width * 0.82, leftCol.height * 0.62)
                    height: width
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: (leftCol.height - height - 90) / 2

                    // ring (3)
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width + 56
                        height: parent.height + 56
                        radius: width / 2
                        color: hvac._liveGlow
                        opacity: systemOn ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: theme.slow } }
                    }

                    // ring (2)
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width
                        height: parent.height
                        radius: width / 2
                        color: "transparent"
                        border.color: hvac._liveBord
                        border.width: 1
                    }

                    // ring (1)
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width - 18
                        height: parent.height - 18
                        radius: width / 2
                        color: hvac._liveGlow
                        opacity: systemOn ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: theme.slow } }
                    }

                    // Inner dark circle
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width - 36
                        height: parent.height - 36
                        radius: width / 2
                        color: theme.bgDeep
                        border.color: hvac._liveBord
                        border.width: 1

                        // Temperature readout
                        Column {
                            anchors.centerIn: parent
                            spacing: 2

                            Text {
                                id: tempLabel
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: systemOn ? temperature : "OFF"
                                color: systemOn ? theme.t0 : theme.t2
                                font.pixelSize: systemOn ? orbWrap.width * 0.27 : orbWrap.width * 0.18
                                font.bold: true
                                font.family: theme.displayFont
                                Behavior on color { ColorAnimation { duration: theme.slow } }

                                // Tiny pop animation on change
                                property real _scale: 1.0
                                scale: _scale
                                transformOrigin: Item.Center
                                onTextChanged: if (systemOn) popAnim.restart()

                                SequentialAnimation {
                                    id: popAnim
                                    NumberAnimation {
                                        target: tempLabel; property: "_scale"
                                        to: 1.10; duration: 80
                                        easing.type: Easing.OutQuad
                                    }
                                    NumberAnimation {
                                        target: tempLabel; property: "_scale"
                                        to: 1.0; duration: 160
                                        easing.type: Easing.OutBounce
                                    }
                                }
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: systemOn ? "°C" : ""
                                color: hvac._liveAccent
                                font.pixelSize: orbWrap.width * 0.10
                                font.family: theme.displayFont
                                opacity: systemOn ? 1.0 : 0.0
                                Behavior on opacity { NumberAnimation { duration: theme.slow } }
                            }

                            Item { width: 1; height: 6 }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: !systemOn ? "SYSTEM OFF" : (heating ? "HEATING" : "COOLING")
                                color: systemOn ? theme.t1 : theme.t2
                                font.pixelSize: orbWrap.width * 0.068
                                font.letterSpacing: 2
                                font.family: theme.displayFont
                                Behavior on color { ColorAnimation { duration: theme.slow } }
                            }
                        }
                    }

                    // ── Arc Canvas — temperature ring (only when on)
                    Canvas {
                        id: arc
                        anchors.fill: parent
                        opacity: systemOn ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: theme.slow } }

                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)

                            if (!systemOn) return

                            var cx = width  / 2
                            var cy = height / 2
                            var r  = width  / 2 - 5

                            var start = Math.PI * 0.75
                            var span  = Math.PI * 1.5

                            // Track
                            ctx.beginPath()
                            ctx.arc(cx, cy, r, start, start + span)
                            ctx.strokeStyle = "rgba(255,255,255,0.06)"
                            ctx.lineWidth = 9
                            ctx.lineCap = "round"
                            ctx.stroke()

                            // Fill
                            if (hvac.tempPct > 0.01) {
                                ctx.beginPath()
                                ctx.arc(cx, cy, r, start, start + hvac.tempPct * span)
                                ctx.strokeStyle = hvac._liveAccent.toString()
                                ctx.lineWidth = 9
                                ctx.lineCap = "round"
                                ctx.stroke()
                            }
                        }

                        Connections {
                            target: hvac
                            /*if temprature varible changed or system on changed will redraw*/
                            function onTemperatureChanged()  { arc.requestPaint() }
                            function on_liveAccentChanged()  { arc.requestPaint() }
                            function onSystemOnChanged()     { arc.requestPaint() }
                        }
                    }
                }

                // ── +  /  − buttons
                Row {
                    id: tempButtons
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 8
                    spacing: 18
                    opacity: systemOn ? 1.0 : 0.3
                    Behavior on opacity { NumberAnimation { duration: theme.slow } }

                    // Minus button
                    Rectangle {
                        width: 62; height: 62
                        radius: theme.rFull
                        color: theme.bgCard
                        border.color: theme.b2
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "−"
                            color: theme.t0
                            font.pixelSize: 30
                            font.family: theme.displayFont
                        }
                        MouseArea {
                            anchors.fill: parent
                            enabled: systemOn
                            onClicked: HVACState.setTemperature(HVACState.temperature - 1)/*important*/
                        }
                    }
                    // Plus button
                    Rectangle {
                        width: 62; height: 62
                        radius: theme.rFull
                        color: hvac._liveGlow
                        border.color: hvac._liveBord
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "+"
                            color: hvac._liveAccent
                            font.pixelSize: 30
                            font.family: theme.displayFont
                        }
                        MouseArea {
                            anchors.fill: parent
                            enabled: systemOn
                            onClicked: HVACState.setTemperature(HVACState.temperature + 1)
                        }
                    }
                }
            }

            /*border betwwen colums*/
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: leftCol.right
                anchors.leftMargin: 0
                width: 1
                height: parent.height * 0.75
                color: theme.b1
            }

            // ── RIGHT COLUMN — Controls ──────────────────────────────────────
            Item {
                id: rightCol
                anchors {
                    top: parent.top; bottom: parent.bottom
                    left: leftCol.right; leftMargin: 20
                    right: parent.right
                }
                opacity: systemOn ? 1.0 : 0.3
                Behavior on opacity { NumberAnimation { duration: theme.slow } }

                Column {
                    anchors.fill: parent
                    spacing: 14

                    // 1 -  Fan Speed
                    Rectangle {
                        width: parent.width
                        height: (rightCol.height - 28) / 3
                        radius: theme.r2
                        color: theme.bgCard
                        border.color: theme.b1
                        border.width: 1

                        Column {
                            anchors.centerIn: parent
                            spacing: 14

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "FAN SPEED"
                                color: theme.t1
                                font.pixelSize: 11
                                font.letterSpacing: 3
                                font.family: theme.displayFont
                            }

                            Row {
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: 10

                                Repeater {
                                    model: 5
                                    delegate: Rectangle {
                                        required property int index
                                        width: 36; height: 36
                                        radius: theme.rFull
                                        color: (index < fanSpeed && systemOn)
                                               ? hvac._liveGlow
                                               : theme.bgDeep
                                        border.color: (index < fanSpeed && systemOn)
                                                      ? hvac._liveBord
                                                      : theme.b1
                                        border.width: 1
                                        Behavior on color        { ColorAnimation { duration: theme.fast } }
                                        Behavior on border.color { ColorAnimation { duration: theme.fast } }

                                        Text {
                                            anchors.centerIn: parent
                                            text: index + 1
                                            color: (index < fanSpeed && systemOn)
                                                   ? hvac._liveAccent
                                                   : theme.t2
                                            font.pixelSize: 12
                                            font.bold: true
                                            font.family: theme.displayFont
                                            Behavior on color { ColorAnimation { duration: theme.fast } }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            enabled: systemOn
                                            onClicked: HVACState.setFanSpeed(index + 1)
                                        }
                                    }
                                }
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: systemOn ? (["Low","Medium","High","Very High","Max"])[fanSpeed - 1] : "Disabled"
                                color: hvac._liveAccent
                                font.pixelSize: 13
                                font.family: theme.displayFont
                            }
                        }
                    }

                    // 2 - Open / Close
                    Rectangle {
                        width: parent.width
                        height: (rightCol.height - 28) / 3
                        radius: theme.r2
                        color: theme.bgCard
                        border.color: theme.b1
                        border.width: 1

                        Row {
                            anchors.centerIn: parent
                            spacing: 28

                            // Animated vent slats
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: (ventsOpen && systemOn) ? 9 : 5
                                Behavior on spacing {
                                    NumberAnimation { duration: theme.normal; easing.type: Easing.InOutQuad }
                                }

                                Repeater {
                                    model: 5
                                    delegate: Rectangle {
                                        required property int index
                                        width: 72
                                        height: (ventsOpen && systemOn) ? 4 : 11
                                        radius: 2
                                        opacity: 1.0 - index * 0.14
                                        color: (ventsOpen && systemOn) ? hvac._liveAccent : theme.b2
                                        Behavior on height { NumberAnimation { duration: theme.normal; easing.type: Easing.InOutQuad } }
                                        Behavior on color  { ColorAnimation  { duration: theme.slow   } }
                                    }
                                }
                            }

                            // Label + toggle button
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 10

                                Text {
                                    text: "VENTS"
                                    color: theme.t1
                                    font.pixelSize: 11
                                    font.letterSpacing: 3
                                    font.family: theme.displayFont
                                }

                                Text {
                                    text: !systemOn ? "DISABLED" : (ventsOpen ? "OPEN" : "CLOSED")
                                    color: (ventsOpen && systemOn) ? hvac._liveAccent : theme.t1
                                    font.pixelSize: 20
                                    font.bold: true
                                    font.family: theme.displayFont
                                    Behavior on color { ColorAnimation { duration: theme.slow } }
                                }

                                // Toggle button
                                Rectangle {
                                    width: 88; height: 32
                                    radius: theme.rFull
                                    color: (ventsOpen && systemOn) ? hvac._liveGlow : theme.bgDeep
                                    border.color: (ventsOpen && systemOn) ? hvac._liveBord : theme.b1
                                    border.width: 1
                                    Behavior on color        { ColorAnimation { duration: theme.slow } }
                                    Behavior on border.color { ColorAnimation { duration: theme.slow } }

                                    Text {
                                        anchors.centerIn: parent
                                        text: !systemOn ? "Disabled" : (ventsOpen ? "Close" : "Open")
                                        color: (ventsOpen && systemOn) ? hvac._liveAccent : theme.t1
                                        font.pixelSize: 12
                                        font.family: theme.displayFont
                                        Behavior on color { ColorAnimation { duration: theme.slow } }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        enabled: systemOn
                                        onClicked: HVACState.toggleVents()
                                    }
                                }
                            }
                        }
                    }

                    // 3-Mode Selection
                    Rectangle {
                        width: parent.width
                        height: (rightCol.height - 28) / 3
                        radius: theme.r2
                        color: hvac._liveGlow
                        border.color: hvac._liveBord
                        border.width: 1

                        Column {
                            anchors.centerIn: parent
                            spacing: 14

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "MODE"
                                color: theme.t1
                                font.pixelSize: 11
                                font.letterSpacing: 3
                                font.family: theme.displayFont
                            }

                            Row {
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: 8

                                // ⏻ OFF
                                Rectangle {
                                    width: 60; height: 46
                                    radius: theme.r1
                                    color: !hvac.systemOn ? theme.bgCard : theme.bgDeep
                                    border.color: !hvac.systemOn ? hvac._liveAccent : theme.b1
                                    border.width: 1
                                    Behavior on color        { ColorAnimation { duration: theme.normal } }
                                    Behavior on border.color { ColorAnimation { duration: theme.normal } }

                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 4
                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: "⏻"
                                            font.pixelSize: 16
                                        }
                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: "OFF"
                                            color: !hvac.systemOn ? hvac._liveAccent : theme.t1
                                            font.pixelSize: 10
                                            font.bold: true
                                            font.family: theme.displayFont
                                            Behavior on color { ColorAnimation { duration: theme.normal } }
                                        }
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: HVACState.setMode("off")
                                    }
                                }

                                // ❄️ COLD
                                Rectangle {
                                    width: 60; height: 46
                                    radius: theme.r1
                                    color: hvac.systemOn && !hvac.heating ? theme.climateGlow : theme.bgDeep
                                    border.color: hvac.systemOn && !hvac.heating ? theme.climateBord : theme.b1
                                    border.width: 1
                                    Behavior on color        { ColorAnimation { duration: theme.normal } }
                                    Behavior on border.color { ColorAnimation { duration: theme.normal } }

                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 4
                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: "❄️"
                                            font.pixelSize: 16
                                        }
                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: "COLD"
                                            color: (hvac.systemOn && !hvac.heating) ? theme.climateAc : theme.t1
                                            font.pixelSize: 10
                                            font.bold: true
                                            font.family: theme.displayFont
                                            Behavior on color { ColorAnimation { duration: theme.normal } }
                                        }
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: HVACState.setMode("cold")
                                    }
                                }

                                // 🔥 HOT
                                Rectangle {
                                    width: 60; height: 46
                                    radius: theme.r1
                                    color: hvac.systemOn && hvac.heating ? theme.youtubeGlow : theme.bgDeep
                                    border.color: hvac.systemOn && hvac.heating ? theme.youtubeBord : theme.b1
                                    border.width: 1
                                    Behavior on color        { ColorAnimation { duration: theme.normal } }
                                    Behavior on border.color { ColorAnimation { duration: theme.normal } }

                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 4
                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: "🔥"
                                            font.pixelSize: 16
                                        }
                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: "HOT"
                                            color: (hvac.systemOn && hvac.heating) ? theme.youtubeAc : theme.t1
                                            font.pixelSize: 10
                                            font.bold: true
                                            font.family: theme.displayFont
                                            Behavior on color { ColorAnimation { duration: theme.normal } }
                                        }
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: HVACState.setMode("hot")
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