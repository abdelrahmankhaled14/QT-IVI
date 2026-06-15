// qml/weather/SplashScreen.qml
import QtQuick 2.15

Item {
    id: splashRoot

    // ── Entry animation ──────────────────────────────────────────────────────
    property real _in: 0
    NumberAnimation on _in {
        from: 0; to: 1
        duration: 2000
        easing.type: Easing.OutCubic
        running: true
    }

    // Deep void background
    Rectangle { anchors.fill: parent; color: theme.bgVoid }

    // Outer ambient bloom (very subtle, fills screen center)
    Rectangle {
        anchors.centerIn: parent
        width: 500; height: 500; radius: 250
        color: theme.weatherGlow
        opacity: 0.6
        SequentialAnimation on opacity {
            loops: Animation.Infinite
            NumberAnimation { to: 0.2; duration: 2000; easing.type: Easing.InOutSine }
            NumberAnimation { to: 0.6; duration: 2000; easing.type: Easing.InOutSine }
        }
    }

    // ── Main column ──────────────────────────────────────────────────────────
    Column {
        anchors.centerIn: parent
        spacing: 28
        opacity: splashRoot._in
        transform: Translate { y: (1 - splashRoot._in) * 32 }

        // ── Orbital ring ─────────────────────────────────────────────────────
        Item {
            id: orbRing
            width: 190; height: 190
            anchors.horizontalCenter: parent.horizontalCenter

            // Outer glow halo
            Rectangle {
                anchors.centerIn: parent
                width: 210; height: 210; radius: width / 2
                color: theme.weatherGlow
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.2; duration: 1600; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0; duration: 1600; easing.type: Easing.InOutSine }
                }
            }

            // Orbit track ring
            Rectangle {
                anchors.centerIn: parent
                width: 168; height: 168; radius: width / 2
                color: "transparent"
                border.color: Qt.rgba(1, 1, 1, 0.06)
                border.width: 2
            }

            // Inner glow fill
            Rectangle {
                anchors.centerIn: parent
                width: 136; height: 136; radius: width / 2
                color: theme.weatherGlow
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.4; duration: 1200; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0; duration: 1200; easing.type: Easing.InOutSine }
                }
            }

            // Dark core orb
            Rectangle {
                anchors.centerIn: parent
                width: 114; height: 114; radius: width / 2
                color: theme.bgDeep
                border.color: theme.weatherBord
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "W"
                    font.family: theme.displayFont
                    font.pixelSize: 58
                    font.bold: true
                    color: theme.weatherAc
                }
            }

            // ── Spinning comet arc ────────────────────────────────────────────
            Canvas {
                id: spinArc
                anchors.fill: parent
                property real ang: 0

                NumberAnimation on ang {
                    from: 0; to: 360
                    duration: 1600
                    loops: Animation.Infinite
                    running: true
                }
                onAngChanged: requestPaint()

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)

                    var cx  = width  / 2
                    var cy  = height / 2
                    var r   = 82
                    var rad = ang * Math.PI / 180 - Math.PI / 2

                    // Trailing arc (fades from transparent to full color)
                    var sweep = Math.PI * 0.65
                    var grad = ctx.createLinearGradient(0, 0, width, height)
                    grad.addColorStop(0, "rgba(74,159,255,0)")
                    grad.addColorStop(1, theme.weatherAc.toString())

                    ctx.beginPath()
                    ctx.arc(cx, cy, r, rad - sweep, rad)
                    ctx.strokeStyle = theme.weatherAc.toString()
                    ctx.lineWidth = 3
                    ctx.lineCap = "round"
                    ctx.globalAlpha = 0.9
                    ctx.stroke()
                    ctx.globalAlpha = 1.0

                    // Leading glowing dot
                    var ex = cx + r * Math.cos(rad)
                    var ey = cy + r * Math.sin(rad)

                    // Outer glow dot
                    ctx.beginPath()
                    ctx.arc(ex, ey, 8, 0, Math.PI * 2)
                    ctx.fillStyle = "rgba(74,159,255,0.25)"
                    ctx.fill()

                    // Core dot
                    ctx.beginPath()
                    ctx.arc(ex, ey, 4.5, 0, Math.PI * 2)
                    ctx.fillStyle = theme.weatherAc.toString()
                    ctx.fill()
                }
            }
        }

        // ── Title ─────────────────────────────────────────────────────────────
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "WEATHER"
            font.family: theme.displayFont
            font.pixelSize: 24
            font.letterSpacing: 10
            font.bold: true
            color: theme.t0
        }

        // ── Tagline ───────────────────────────────────────────────────────────
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Powered by OpenWeatherMap"
            font.family: theme.displayFont
            font.pixelSize: 11
            font.letterSpacing: 1
            color: theme.t2
        }

        // ── Animated loading dots ─────────────────────────────────────────────
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            Repeater {
                model: 3
                Rectangle {
                    width: 6; height: 6
                    radius: 3
                    color: theme.weatherAc
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        PauseAnimation     { duration: index * 220 }
                        NumberAnimation    { to: 1.0;  duration: 360; easing.type: Easing.OutQuad }
                        NumberAnimation    { to: 0.12; duration: 360; easing.type: Easing.InQuad  }
                        PauseAnimation     { duration: (2 - index) * 220 }
                    }
                }
            }
        }
    }
}
