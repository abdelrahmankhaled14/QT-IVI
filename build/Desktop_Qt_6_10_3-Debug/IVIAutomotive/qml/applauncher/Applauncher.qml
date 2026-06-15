import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Effects
import "../navigation"
import "../HVAC"
import "../media"

Item {
    id: appLauncher
    signal openApp(string appName)

    // so we assign source for images
    function getWeatherIcon(condition) {
        var c = condition.toLowerCase()
        if (c.includes("thunder") || c.includes("storm")) return "qrc:/assets/storm.png"
        if (c.includes("snow") || c.includes("sleet") || c.includes("blizzard")) return "qrc:/assets/snowy.png"
        if (c.includes("rain") || c.includes("drizzle") || c.includes("shower")) return "qrc:/assets/rainy-day.png"
        if (c.includes("cloud") || c.includes("overcast") || c.includes("fog")) return "qrc:/assets/cloud(1).png"
        if (c.includes("wind") || c.includes("breeze")) return "qrc:/assets/windy.png"
        return "qrc:/assets/sun.png" // Default to sun/clear
    }

    // Data Model where you can add any Application
    property var appsModel: [
        {
            appName: "Navigation", appSub: "Maps", iconSource: "qrc:/assets/maps-and-flags(1).png",
            accentColor: theme.navigationAc, glowColor: theme.navigationGlow, bordColor: theme.navigationBord
        },
        {
            appName: "YouTube", appSub: "Music", iconSource: "qrc:/assets/youtube.png",
            accentColor: theme.youtubeAc, glowColor: theme.youtubeGlow, bordColor: theme.youtubeBord
        },
        {
            appName: "Sound", appSub: "Cloud", iconSource: "qrc:/assets/spotify.png",
            accentColor: theme.spotifyAc, glowColor: theme.spotifyGlow, bordColor: theme.spotifyBord
        },
        {
            appName: "Climate", appSub: "HVAC Control", iconSource: "qrc:/assets/fan(1).png",
            accentColor: theme.climateAc, glowColor: theme.climateGlow, bordColor: theme.climateBord
        },
        {
            appName: "Weather", appSub: "Forecast", iconSource: "qrc:/assets/cloud.png",
            accentColor: theme.weatherAc, glowColor: theme.weatherGlow, bordColor: theme.weatherBord
        },
        {
            appName: "Phone", appSub: "Calls & BT", iconSource: "qrc:/assets/phone.png",
            accentColor: theme.phoneAc, glowColor: theme.phoneGlow, bordColor: theme.phoneBord
        },
        {
            appName: "Media", appSub: "player", iconSource: "qrc:/assets/technology.png",
            accentColor: theme.vehicleAc, glowColor: theme.vehicleGlow, bordColor: theme.vehicleBord
        },
        {
            appName: "Settings", appSub: "System", iconSource: "qrc:/assets/settings.png",
            accentColor: theme.settingsAc, glowColor: theme.settingsGlow, bordColor: theme.settingsBord
        }
    ]

    Rectangle {
        anchors.fill: parent
        color: theme.bgSurface

        Column {
            anchors.fill: parent
            spacing: 0

            // ═══════════════════════════════════════════════════════════════════
            // TOP STATUS BAR
            // ═══════════════════════════════════════════════════════════════════
            Rectangle {
                id: topBar
                width: parent.width
                height: 52
                color: theme.bgFooter
                z: 10

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: theme.b0
                }

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 24
                    spacing: 20

                    Row {
                        spacing: 6

                        Rectangle {
                            width: 14; height: 14
                            radius: theme.rFull
                            color: theme.blue
                            opacity: 0.9
                        }
                    }
                }

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 24
                    spacing: 20

                    Text {
                        text: weatherCard.displayTemp
                        font.family: theme.displayFont
                        font.pixelSize: 13
                        color: theme.t1
                        font.letterSpacing: 1
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Row {
                        spacing: 6
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            width: 28; height: 14
                            radius: 3
                            color: "transparent"
                            border.color: theme.t2; border.width: 1.5
                            anchors.verticalCenter: parent.verticalCenter

                            Rectangle {
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                anchors.margins: 2
                                width: parent.width * 0.9 - 4
                                radius: 2
                                color: theme.blue
                            }

                            Rectangle {
                                anchors.left: parent.right; anchors.leftMargin: 1
                                anchors.verticalCenter: parent.verticalCenter
                                width: 3; height: 7
                                radius: 1
                                color: theme.t2
                            }
                        }

                        Text {
                            text: "90%"
                            font.family: theme.displayFont
                            font.pixelSize: 12; font.weight: 600; font.letterSpacing: 1
                            color: theme.blue
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }

            // ═══════════════════════════════════════════════════════════════════
            // PAGE LABEL
            // ═══════════════════════════════════════════════════════════════════
            Item {
                width: parent.width; height: 36

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top; anchors.topMargin: 8
                    text: swipe.currentIndex === 0 ? "PREVIEW DASHBOARD" : "APPLICATIONS"
                    font.family: theme.displayFont
                    font.pixelSize: 9; font.weight: 500; font.letterSpacing: 5
                    color: theme.t2
                    Behavior on text { }
                }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    width: 36; height: 1
                    color: theme.b1
                }
            }

            // ═══════════════════════════════════════════════════════════════════
            // SWIPE PAGES
            // ═══════════════════════════════════════════════════════════════════
            SwipeView {
                id: swipe
                width: parent.width
                height: parent.height - topBar.height - 36 - 24 - 76 // height of Page label and topBar and Page indicator and bottom control bar
                clip: true

                // ───────────────────────────────────────────────────────────────
                // PAGE 1: App preview
                // ───────────────────────────────────────────────────────────────
                Item {
                    id: dashboardPage

                    Item {
                        anchors.top: parent.top; anchors.topMargin: 10
                        anchors.bottom: parent.bottom; anchors.bottomMargin: 10
                        anchors.left: parent.left; anchors.leftMargin: 40
                        anchors.right: parent.right; anchors.rightMargin: 40

                        // 1) NAVIGATION
                        DashCard {
                            id: navCard
                            appName: "Navigation"
                            accentColor: theme.navigationAc
                            anchors.top: parent.top
                            anchors.left: parent.left
                            width: parent.width * 0.56
                            height: parent.height * 0.65

                            // ══════════════════════════════════════════════════════════════════
                            // binding with HvacState in case its undefined it gives hardcoded data
                            // ══════════════════════════════════════════════════════════════════
                            property string navNextStreet:  (typeof NaviState !== 'undefined') ? NaviState.nextStreet : ""
                            property bool   isNavigating:   (typeof NaviState !== 'undefined') ? NaviState.hasActiveRoute : false
                            property int    navDistanceM:   (typeof NaviState !== 'undefined') ? NaviState.distanceToTurn : 0
                            property string navEtaTime:     (typeof NaviState !== 'undefined') ? NaviState.eta : "--:--"
                            property int    navRemainingKm: (typeof NaviState !== 'undefined') ? Math.round(NaviState.totalDistance) : 0
                            property real   navHeading:     (typeof NaviState !== 'undefined') ? NaviState.heading : 0
                            property string navManeuver:    (typeof NaviState !== 'undefined') ? NaviState.turnIcon : "↱"

                            // ══════════════════════════════════════════════════════════════════
                            // IDLE STATE
                            // ══════════════════════════════════════════════════════════════════
                            Item {
                                anchors.fill: parent
                                visible: !navCard.isNavigating
                                z: 5

                                // Faded background grid
                                Item {
                                    anchors.fill: parent
                                    opacity: 0.08

                                    Repeater {
                                        model: 12
                                        Rectangle {
                                            x: index * (parent.width / 11)
                                            y: 0; width: 1; height: parent.height
                                            color: theme.navigationAc
                                        }
                                    }

                                    Repeater {
                                        model: 8
                                        Rectangle {
                                            x: 0; y: index * (parent.height / 7)
                                            width: parent.width; height: 1
                                            color: theme.navigationAc
                                        }
                                    }
                                }

                                // Center content
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 14

                                    Image {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        width: 64; height: 64
                                        source: "qrc:/assets/maps-and-flags(1).png"
                                        fillMode: Image.PreserveAspectFit
                                        smooth: true
                                        opacity: 0.25

                                        SequentialAnimation on opacity {
                                            running: true; loops: Animation.Infinite
                                            NumberAnimation { to: 0.10; duration: 1500; easing.type: Easing.InOutSine }
                                            NumberAnimation { to: 0.25; duration: 1500; easing.type: Easing.InOutSine }
                                        }
                                    }

                                    Column {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        spacing: 6

                                        Text {
                                            text: "NO ACTIVE ROUTE" /*important*/
                                            font.family: theme.monoFont
                                            font.pixelSize: 11
                                            font.letterSpacing: 2.5
                                            color: theme.navigationAc
                                            opacity: 0.6
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }

                                        Text {
                                            text: "Open Navigation to set destination"
                                            font.family: theme.monoFont
                                            font.pixelSize: 13
                                            color: theme.t1
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                    }

                                    Rectangle {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        width: 160; height: 36
                                        radius: theme.rFull
                                        color: navIdleBtn.containsMouse ? theme.navigationAc : theme.navigationGlow
                                        border.color: theme.navigationBord
                                        border.width: 1

                                        Behavior on color { ColorAnimation { duration: theme.fast } }

                                        Text {
                                            anchors.centerIn: parent
                                            text: "Open Map  →"
                                            font.family: theme.monoFont
                                            font.pixelSize: 12
                                            font.weight: 600
                                            color: navIdleBtn.containsMouse ? theme.bgVoid : theme.navigationAc
                                            Behavior on color { ColorAnimation { duration: theme.fast } }
                                        }

                                        MouseArea {
                                            id: navIdleBtn
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: appLauncher.openApp("Navigation") /*important*/
                                        }
                                    }
                                }
                            }

                            // ══════════════════════════════════════════════════════════════════
                            // ACTIVE STATE
                            // ══════════════════════════════════════════════════════════════════
                            Item {
                                anchors.fill: parent
                                visible: navCard.isNavigating

                                // ── Animated map grid ──
                                Item {
                                    anchors.fill: parent
                                    clip: true

                                    // Vertical roads
                                    Repeater {
                                        model: 14
                                        Rectangle {
                                            x: index * (parent.width / 13) - 8
                                            y: 0; width: 1; height: parent.height
                                            color: theme.navigationAc
                                            opacity: 0.045
                                        }
                                    }

                                    // Horizontal roads
                                    Repeater {
                                        model: 10
                                        Rectangle {
                                            x: 0; y: index * (parent.height / 9) - 6
                                            width: parent.width; height: 1
                                            color: theme.navigationAc
                                            opacity: 0.045
                                        }
                                    }
                                }

                                // Turn info (top-left)
                                Column {
                                    anchors.left: parent.left;  anchors.leftMargin: 22
                                    anchors.top: parent.top;    anchors.topMargin: 22
                                    spacing: 6
                                    z: 2

                                    Text {
                                        text: "NEXT TURN"
                                        font.family: theme.monoFont
                                        font.pixelSize: 9; font.letterSpacing: 2.5
                                        color: theme.navigationAc; opacity: 0.75
                                    }

                                    Text {
                                        text: navCard.navNextStreet
                                        font.family: theme.monoFont
                                        font.pixelSize: 22; font.weight: 600
                                        color: theme.t0
                                    }

                                    Text {
                                        text: navCard.navDistanceM >= 1000
                                              ? (navCard.navDistanceM / 1000).toFixed(1) + " km"
                                              : navCard.navDistanceM + " m"
                                        font.family: theme.monoFont
                                        font.pixelSize: 14; color: theme.t1
                                    }
                                }

                                // Large turn arrow
                                Text {
                                    anchors.centerIn: parent
                                    anchors.verticalCenterOffset: -10
                                    text: navCard.navManeuver
                                    font.pixelSize: 110
                                    color: theme.navigationAc
                                    opacity: 0.82
                                    z: 1
                                }

                                // ── Bottom info strip ──
                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.left: parent.left; anchors.right: parent.right
                                    height: 58
                                    color: theme.bgVoid
                                    opacity: 0.94
                                    z: 2

                                    Row {
                                        anchors.centerIn: parent
                                        spacing: 20

                                        Column {
                                            spacing: 3
                                            anchors.verticalCenter: parent.verticalCenter

                                            Text {
                                                text: "ETA"
                                                font.family: theme.monoFont
                                                font.pixelSize: 9; font.letterSpacing: 2
                                                color: theme.t2
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }

                                            Text {
                                                text: navCard.navEtaTime /*from singlton*/
                                                font.family: theme.monoFont
                                                font.pixelSize: 20; font.weight: 700
                                                color: theme.t0
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }

                                        Rectangle { width: 1; height: 28; color: theme.b2; anchors.verticalCenter: parent.verticalCenter }

                                        Column {
                                            spacing: 3
                                            anchors.verticalCenter: parent.verticalCenter

                                            Text {
                                                text: "REMAINING"
                                                font.family: theme.monoFont
                                                font.pixelSize: 9; font.letterSpacing: 2
                                                color: theme.t2
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }

                                            Text {
                                                text: navCard.navRemainingKm + " km" /*from singlton*/
                                                font.family: theme.monoFont
                                                font.pixelSize: 20; font.weight: 700
                                                color: theme.t0
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }

                                        Rectangle { width: 1; height: 28; color: theme.b2; anchors.verticalCenter: parent.verticalCenter }

                                        Item {
                                            width: 120; height: 40
                                            anchors.verticalCenter: parent.verticalCenter

                                            Text {
                                                anchors.centerIn: parent
                                                text: "Full Map  ↗"
                                                font.family: theme.monoFont
                                                font.pixelSize: 13; font.weight: 500
                                                color: theme.navigationAc
                                                opacity: navOpenHover.containsMouse ? 1.0 : 0.72
                                                Behavior on opacity { NumberAnimation { duration: theme.fast } }
                                            }

                                            MouseArea {
                                                id: navOpenHover
                                                anchors.fill: parent
                                                hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                                onClicked: appLauncher.openApp("Navigation")
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // 1b) PHONE / BLUETOOTH STATUS
                        DashCard {
                            id: phoneCard
                            appName: "Phone"
                            accentColor: theme.phoneAc
                            anchors.top: navCard.bottom; anchors.topMargin: 15
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            width: parent.width * 0.56

                            property bool   phoneOK:     (typeof phoneManager !== 'undefined') ? phoneManager.phoneConnected : false
                            property bool   btConnected: phoneOK || ((typeof bluetoothManager !== 'undefined') ? bluetoothManager.connected : false)
                            property string btDevice:    phoneOK ? phoneManager.deviceName
                                                                  : ((typeof bluetoothManager !== 'undefined') ? bluetoothManager.connectedDevice : "")
                            property bool   btPlaying:   (typeof bluetoothManager !== 'undefined') ? bluetoothManager.playing : false
                            property bool   onCall:      (typeof phoneManager !== 'undefined') && phoneManager.callState !== "idle"

                            // Ambient glow
                            Rectangle {
                                anchors.bottom: parent.bottom; anchors.right: parent.right
                                anchors.bottomMargin: -12; anchors.rightMargin: -12
                                width: 80; height: 80; radius: 40
                                color: phoneCard.btConnected
                                       ? Qt.rgba(theme.phoneAc.r, theme.phoneAc.g, theme.phoneAc.b, 0.07)
                                       : "transparent"
                                Behavior on color { ColorAnimation { duration: theme.normal } }
                            }

                            Row {
                                anchors.fill: parent
                                anchors.margins: 18
                                spacing: 16

                                // Phone icon circle
                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 52; height: 52; radius: 26
                                    color: phoneCard.btConnected
                                           ? Qt.rgba(theme.phoneAc.r, theme.phoneAc.g, theme.phoneAc.b, 0.14)
                                           : theme.bgDeep
                                    border.color: phoneCard.btConnected ? theme.phoneAc : theme.b2
                                    border.width: 1.5
                                    Behavior on color        { ColorAnimation { duration: theme.normal } }
                                    Behavior on border.color { ColorAnimation { duration: theme.normal } }

                                    Text {
                                        anchors.centerIn: parent
                                        text: phoneCard.btConnected ? "📱" : "📵"
                                        font.pixelSize: 22
                                        opacity: phoneCard.btConnected ? 1.0 : 0.45
                                        Behavior on opacity { NumberAnimation { duration: theme.normal } }
                                    }

                                    // Pulse when streaming audio
                                    SequentialAnimation on opacity {
                                        running: phoneCard.btPlaying
                                        loops: Animation.Infinite
                                        NumberAnimation { to: 0.6; duration: 800; easing.type: Easing.InOutSine }
                                        NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutSine }
                                    }
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - 68
                                    spacing: 6

                                    // Status badge
                                    Rectangle {
                                        width: statusBadgeTxt.width + 14; height: 16; radius: 8
                                        color: phoneCard.btConnected
                                               ? Qt.rgba(theme.phoneAc.r, theme.phoneAc.g, theme.phoneAc.b, 0.14)
                                               : Qt.rgba(1,1,1, 0.04)
                                        border.color: phoneCard.btConnected
                                                      ? Qt.rgba(theme.phoneAc.r, theme.phoneAc.g, theme.phoneAc.b, 0.50)
                                                      : theme.b1
                                        border.width: 1
                                        Behavior on color { ColorAnimation { duration: theme.normal } }

                                        Text {
                                            id: statusBadgeTxt
                                            anchors.centerIn: parent
                                            text: phoneCard.btPlaying ? "STREAMING" : (phoneCard.btConnected ? "CONNECTED" : "NO DEVICE")
                                            font.family: theme.monoFont; font.pixelSize: 8; font.letterSpacing: 2
                                            color: phoneCard.btConnected ? theme.phoneAc : theme.t2
                                        }
                                    }

                                    // Device name
                                    Text {
                                        width: parent.width
                                        text: phoneCard.btConnected ? phoneCard.btDevice : "No phone connected"
                                        font.family: theme.displayFont
                                        font.pixelSize: 14; font.weight: Font.DemiBold
                                        color: phoneCard.btConnected ? theme.t0 : theme.t2
                                        elide: Text.ElideRight
                                        Behavior on color { ColorAnimation { duration: theme.normal } }
                                    }

                                    // Streaming label or hint
                                    Text {
                                        text: phoneCard.btPlaying ? "Audio streaming  🎵" : "Open Phone to manage calls"
                                        font.family: theme.displayFont
                                        font.pixelSize: 10
                                        color: phoneCard.btPlaying ? theme.phoneAc : theme.t1
                                        Behavior on color { ColorAnimation { duration: theme.normal } }
                                    }

                                    // Open Phone link
                                    Text {
                                        text: "Open Phone  →"
                                        font.family: theme.monoFont; font.pixelSize: 10
                                        color: theme.phoneAc
                                        opacity: openPhoneHov.containsMouse ? 1.0 : 0.60
                                        Behavior on opacity { NumberAnimation { duration: theme.fast } }
                                        MouseArea {
                                            id: openPhoneHov; anchors.fill: parent
                                            hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                            onClicked: appLauncher.openApp("Phone")
                                        }
                                    }
                                }
                            }
                        }

                        // 2) MEDIA
                        DashCard {
                            id: ytCard
                            appName: "Media"
                            accentColor: theme.youtubeAc
                            anchors.top: parent.top; anchors.right: parent.right
                            width: parent.width * 0.42
                            height: parent.height * 0.44

                            // Bluetooth (phone streaming via A2DP/AVRCP) takes priority
                            // over the local radio/audio/video sources.
                            property bool   msIsBt:     (typeof bluetoothManager !== 'undefined') &&
                                                        bluetoothManager.connected &&
                                                        bluetoothManager.avrcpAvailable

                            property bool   msPlaying:  msIsBt ? (bluetoothManager.avrcpStatus === "playing")
                                                        : (typeof MediaState !== 'undefined') ? MediaState.isPlaying  : false
                            property bool   msIsRadio:  !msIsBt &&
                                                        ((typeof MediaState !== 'undefined') ? MediaState.isRadioMode : true)
                            property bool   msIsVideo:  !msIsBt && !msIsRadio &&
                                                        (typeof videoManager !== 'undefined') &&
                                                        videoManager.playing
                            property bool   msIsAudio:  !msIsBt && !msIsRadio && !msIsVideo

                            property string msTitle:    msIsBt ? (bluetoothManager.trackTitle !== "" ? bluetoothManager.trackTitle : bluetoothManager.connectedDevice)
                                                        : (typeof MediaState !== 'undefined') ? MediaState.currentTitle  : "No media"
                            property string msArtist:   msIsBt ? bluetoothManager.trackArtist
                                                        : (typeof MediaState !== 'undefined') ? MediaState.currentArtist : ""
                            property int    msVolume:   msIsBt ? bluetoothManager.volume
                                                        : (typeof MediaState !== 'undefined') ? MediaState.volume        : 80

                            property real msProgress: {
                                if (msIsAudio && typeof audioManager !== 'undefined' && audioManager.duration > 0)
                                    return audioManager.position / audioManager.duration
                                if (msIsVideo && typeof videoManager !== 'undefined' && videoManager.duration > 0)
                                    return videoManager.position / videoManager.duration
                                return 0.0
                            }

                            property int msPosSec: {
                                if (msIsAudio && typeof audioManager !== 'undefined')
                                    return Math.floor(audioManager.position / 1000)
                                if (msIsVideo && typeof videoManager !== 'undefined')
                                    return Math.floor(videoManager.position / 1000)
                                return 0
                            }

                            property int msDurSec: {
                                if (msIsAudio && typeof audioManager !== 'undefined')
                                    return Math.floor(audioManager.duration / 1000)
                                if (msIsVideo && typeof videoManager !== 'undefined')
                                    return Math.floor(videoManager.duration / 1000)
                                return 0
                            }

                            property color modeColor: msIsBt    ? theme.blue
                                                    : msIsRadio ? theme.navigationAc
                                                    : msIsVideo ? theme.youtubeAc
                                                    : theme.spotifyAc

                            function fmtTime(totalSec) {
                                var m = Math.floor(totalSec / 60)
                                var s = totalSec % 60
                                return m + ":" + (s < 10 ? "0" : "") + s
                            }

                            function doPlayPause() {
                                if (msIsBt) { bluetoothManager.mediaPlayPause(); return }
                                if (typeof MediaState !== 'undefined') MediaState.togglePlayPause()
                                if (msIsRadio && typeof radioManager !== 'undefined')
                                    radioManager.togglePlayPause()
                                else if (msIsAudio && typeof audioManager !== 'undefined')
                                    audioManager.playPause()
                                else if (msIsVideo && typeof videoManager !== 'undefined')
                                    videoManager.playPause()
                            }

                            function doStop() {
                                if (msIsBt) { bluetoothManager.mediaPause(); return }
                                if (typeof MediaState !== 'undefined') MediaState.stop()
                                if (msIsRadio && typeof radioManager !== 'undefined')  radioManager.stop()
                                if (msIsAudio && typeof audioManager !== 'undefined')  audioManager.stop()
                                if (msIsVideo && typeof videoManager !== 'undefined')  videoManager.stop()
                            }

                            function doPrev() {
                                if (msIsBt) { bluetoothManager.mediaPrevious(); return }
                                if (msIsAudio && typeof audioManager !== 'undefined') {
                                    audioManager.previous()
                                    MediaState.updateFromAudio(audioManager.currentTitle, audioManager.currentArtist, true)
                                } else if (msIsVideo && typeof videoManager !== 'undefined') {
                                    videoManager.previous()
                                }
                            }

                            function doNext() {
                                if (msIsBt) { bluetoothManager.mediaNext(); return }
                                if (msIsAudio && typeof audioManager !== 'undefined') {
                                    audioManager.next()
                                    MediaState.updateFromAudio(audioManager.currentTitle, audioManager.currentArtist, true)
                                } else if (msIsVideo && typeof videoManager !== 'undefined') {
                                    videoManager.next()
                                }
                            }

                            function doSetVolume(v) {
                                if (msIsBt) { bluetoothManager.setVolume(v); return }
                                if (typeof MediaState !== 'undefined') MediaState.setVolume(v)
                                if (typeof audioManager !== 'undefined') audioManager.setVolume(v)
                                if (typeof videoManager !== 'undefined') videoManager.setVolume(v)
                            }

                            Connections {
                                target: (typeof audioManager !== 'undefined') ? audioManager : null
                                function onCurrentTitleChanged() {
                                    if (!ytCard.msIsRadio && typeof MediaState !== 'undefined')
                                        MediaState.updateFromAudio(audioManager.currentTitle, audioManager.currentArtist, audioManager.playing)
                                }
                                function onPlayingChanged() {
                                    if (!ytCard.msIsRadio && typeof MediaState !== 'undefined')
                                        MediaState.isPlaying = audioManager.playing
                                }
                            }

                            Connections {
                                target: (typeof videoManager !== 'undefined') ? videoManager : null
                                function onPlayingChanged() {
                                    if (videoManager.playing && typeof MediaState !== 'undefined') {
                                        MediaState.isRadioMode = false
                                        MediaState.isPlaying   = true
                                        MediaState.currentTitle = videoManager.currentTitle || "Video"
                                    }
                                }
                            }

                            // ── Layout: disc left | info right ──────────────────────
                            Item {
                                anchors.fill: parent
                                anchors.margins: 16

                                // Spinning disc
                                Item {
                                    id: ytDisc
                                    width: parent.height - 8; height: parent.height - 8
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter

                                    // Outer halo
                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: parent.width + 22; height: parent.width + 22; radius: width / 2
                                        color: "transparent"
                                        border.color: Qt.rgba(ytCard.modeColor.r, ytCard.modeColor.g, ytCard.modeColor.b, 0.10)
                                        border.width: 5
                                        opacity: ytCard.msPlaying ? 1 : 0
                                        Behavior on opacity { NumberAnimation { duration: theme.normal } }
                                        Behavior on border.color { ColorAnimation { duration: theme.normal } }
                                    }
                                    // Inner glow ring
                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: parent.width + 10; height: parent.width + 10; radius: width / 2
                                        color: "transparent"
                                        border.color: Qt.rgba(ytCard.modeColor.r, ytCard.modeColor.g, ytCard.modeColor.b, 0.28)
                                        border.width: 2
                                        opacity: ytCard.msPlaying ? 1 : 0
                                        Behavior on opacity { NumberAnimation { duration: theme.normal } }
                                        Behavior on border.color { ColorAnimation { duration: theme.normal } }
                                    }
                                    // Disc body
                                    Rectangle {
                                        anchors.fill: parent; radius: width / 2
                                        color: theme.bgDeep
                                        border.color: Qt.rgba(ytCard.modeColor.r, ytCard.modeColor.g, ytCard.modeColor.b, 0.50)
                                        border.width: 2
                                        Behavior on border.color { ColorAnimation { duration: theme.normal } }
                                        Repeater {
                                            model: 4
                                            Rectangle {
                                                anchors.centerIn: parent
                                                width: parent.width * (0.88 - index * 0.18)
                                                height: width; radius: width / 2; color: "transparent"
                                                border.color: Qt.rgba(ytCard.modeColor.r, ytCard.modeColor.g, ytCard.modeColor.b, Math.max(0.02, 0.12 - index * 0.025))
                                                border.width: 1
                                            }
                                        }
                                    }
                                    // Spin — only when genuinely playing real media
                                    RotationAnimation on rotation { running: ytCard.msPlaying && ytCard.msTitle.length > 0 && ytCard.msTitle !== "No media"; loops: Animation.Infinite; from: 0; to: 360; duration: 5000 }
                                    // Centre hub
                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: parent.width * 0.38; height: width; radius: width / 2
                                        color: Qt.rgba(ytCard.modeColor.r, ytCard.modeColor.g, ytCard.modeColor.b, 0.18)
                                        border.color: Qt.rgba(ytCard.modeColor.r, ytCard.modeColor.g, ytCard.modeColor.b, 0.40)
                                        border.width: 1.5
                                        Behavior on color { ColorAnimation { duration: theme.normal } }
                                        Text { anchors.centerIn: parent; text: ytCard.msIsBt ? "📱" : ytCard.msIsRadio ? "📻" : ytCard.msIsVideo ? "🎬" : "🎵"; font.pixelSize: 16 }
                                    }
                                    // EQ bars
                                    Row {
                                        anchors.bottom: parent.bottom; anchors.bottomMargin: 4
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        spacing: 3; visible: ytCard.msPlaying && ytCard.msTitle.length > 0 && ytCard.msTitle !== "No media"
                                        Repeater {
                                            model: 5
                                            Rectangle {
                                                width: 3; height: 7; radius: 2; color: ytCard.modeColor; opacity: 0.9
                                                SequentialAnimation on height {
                                                    running: ytCard.msPlaying && ytCard.msTitle.length > 0 && ytCard.msTitle !== "No media"; loops: Animation.Infinite
                                                    NumberAnimation { to: 14 + index * 3; duration: 170 + index * 50; easing.type: Easing.InOutSine }
                                                    NumberAnimation { to: 4; duration: 170 + index * 50; easing.type: Easing.InOutSine }
                                                }
                                            }
                                        }
                                    }
                                    // Spindle
                                    Rectangle {
                                        anchors.centerIn: parent; width: 7; height: 7; radius: 4
                                        color: theme.bgDeep
                                        border.color: Qt.rgba(ytCard.modeColor.r, ytCard.modeColor.g, ytCard.modeColor.b, 0.7); border.width: 1.5
                                    }
                                }

                                // ── Info + controls ──────────────────────────────────
                                Column {
                                    anchors.left: ytDisc.right; anchors.leftMargin: 16
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 0

                                    // Mode badge
                                    Rectangle {
                                        width: modeLbl.implicitWidth + 20; height: 22; radius: 11
                                        color: Qt.rgba(ytCard.modeColor.r, ytCard.modeColor.g, ytCard.modeColor.b, 0.14)
                                        border.color: Qt.rgba(ytCard.modeColor.r, ytCard.modeColor.g, ytCard.modeColor.b, 0.45); border.width: 1
                                        Behavior on color { ColorAnimation { duration: theme.normal } }
                                        Row {
                                            anchors.centerIn: parent; spacing: 5
                                            Rectangle {
                                                width: 5; height: 5; radius: 3; color: ytCard.modeColor
                                                anchors.verticalCenter: parent.verticalCenter
                                                SequentialAnimation on opacity {
                                                    running: ytCard.msPlaying; loops: Animation.Infinite
                                                    NumberAnimation { to: 0.25; duration: 700 }
                                                    NumberAnimation { to: 1.0;  duration: 700 }
                                                }
                                            }
                                            Text {
                                                id: modeLbl
                                                text: ytCard.msIsBt ? "BLUETOOTH" : ytCard.msIsRadio ? "RADIO" : ytCard.msIsVideo ? "VIDEO" : "AUDIO"
                                                font.family: theme.monoFont; font.pixelSize: 9; font.letterSpacing: 2; color: ytCard.modeColor
                                                Behavior on color { ColorAnimation { duration: theme.normal } }
                                            }
                                        }
                                    }

                                    Item { width: 1; height: 10 }

                                    // Title
                                    Text {
                                        width: parent.width
                                        text: ytCard.msTitle.length > 0 ? ytCard.msTitle : "No media"
                                        font.family: theme.displayFont; font.pixelSize: 15; font.weight: Font.Bold
                                        color: theme.t0; elide: Text.ElideRight
                                    }

                                    Item { width: 1; height: 4 }

                                    // Artist
                                    Text {
                                        width: parent.width
                                        text: ytCard.msArtist
                                        visible: ytCard.msArtist.length > 0
                                        font.family: theme.displayFont; font.pixelSize: 11; color: theme.t2; elide: Text.ElideRight
                                    }

                                    Item { width: 1; height: 14 }

                                    // Progress bar
                                    Item {
                                        width: parent.width; height: 18; visible: !ytCard.msIsRadio && !ytCard.msIsBt
                                        Rectangle {
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: parent.width; height: 5; radius: 3
                                            color: Qt.rgba(1, 1, 1, 0.08)
                                            Rectangle {
                                                width: ytCard.msProgress * parent.width; height: 5; radius: 3; color: ytCard.modeColor; opacity: 0.95
                                                Behavior on color { ColorAnimation { duration: theme.normal } }
                                                Behavior on width { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
                                            }
                                            Rectangle {
                                                x: (ytCard.msProgress * parent.width) - 6
                                                anchors.verticalCenter: parent.verticalCenter
                                                width: 13; height: 13; radius: 7
                                                color: theme.t0; border.color: ytCard.modeColor; border.width: 2
                                                visible: ytCard.msPlaying
                                                Behavior on x { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
                                            }
                                        }
                                    }

                                    // Time labels
                                    Row {
                                        width: parent.width; visible: !ytCard.msIsRadio && ytCard.msDurSec > 0
                                        Text { text: ytCard.fmtTime(ytCard.msPosSec); font.family: theme.monoFont; font.pixelSize: 9; color: Qt.rgba(ytCard.modeColor.r, ytCard.modeColor.g, ytCard.modeColor.b, 0.85) }
                                        Item { width: parent.width - 52; height: 1 }
                                        Text { text: ytCard.fmtTime(ytCard.msDurSec); font.family: theme.monoFont; font.pixelSize: 9; color: theme.t2 }
                                    }

                                    Item { width: 1; height: 14 }

                                    // Transport controls
                                    Row {
                                        spacing: 8; anchors.horizontalCenter: parent.horizontalCenter

                                        Repeater {
                                            model: [
                                                { icon: "⏮", wide: false, isPlay: false, isStop: false },
                                                { icon: "■",  wide: false, isPlay: false, isStop: true  },
                                                { icon: "",   wide: true,  isPlay: true,  isStop: false },
                                                { icon: "⏭", wide: false, isPlay: false, isStop: false }
                                            ]
                                            Rectangle {
                                                property bool hasMedia: ytCard.msIsBt || ytCard.msIsRadio || (ytCard.msTitle.length > 0 && ytCard.msTitle !== "No media")
                                                property bool btnEnabled: {
                                                    if (modelData.isPlay) return hasMedia
                                                    if (modelData.isStop) return hasMedia
                                                    return !ytCard.msIsRadio && hasMedia
                                                }
                                                width:  modelData.wide ? 56 : 36; height: 32; radius: 16
                                                color: {
                                                    if (modelData.isPlay) return ytCard.msPlaying ? ytCard.modeColor : Qt.rgba(ytCard.modeColor.r, ytCard.modeColor.g, ytCard.modeColor.b, 0.18)
                                                    return ctrlHov.containsMouse && btnEnabled ? Qt.rgba(ytCard.modeColor.r, ytCard.modeColor.g, ytCard.modeColor.b, 0.15) : Qt.rgba(1,1,1,0.04)
                                                }
                                                border.color: Qt.rgba(ytCard.modeColor.r, ytCard.modeColor.g, ytCard.modeColor.b, btnEnabled ? 0.45 : 0.15)
                                                border.width: 1
                                                opacity: btnEnabled ? 1.0 : 0.25
                                                Behavior on color { ColorAnimation { duration: theme.fast } }

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: modelData.isPlay ? (ytCard.msPlaying ? "⏸" : "▶") : modelData.icon
                                                    color: (modelData.isPlay && ytCard.msPlaying) ? theme.bgVoid : ytCard.modeColor
                                                    font.pixelSize: modelData.isPlay ? 16 : 12
                                                    Behavior on color { ColorAnimation { duration: theme.fast } }
                                                }
                                                MouseArea {
                                                    id: ctrlHov; anchors.fill: parent; hoverEnabled: true
                                                    cursorShape: parent.btnEnabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                                    onClicked: {
                                                        if (!parent.btnEnabled) return
                                                        if (modelData.isPlay) ytCard.doPlayPause()
                                                        else if (modelData.isStop) ytCard.doStop()
                                                        else if (modelData.icon === "⏮") ytCard.doPrev()
                                                        else if (modelData.icon === "⏭") ytCard.doNext()
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    Item { width: 1; height: 12 }

                                    // Volume
                                    Row {
                                        width: parent.width; spacing: 8
                                        Text {
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: ytCard.msVolume < 30 ? "🔈" : ytCard.msVolume < 70 ? "🔉" : "🔊"
                                            font.pixelSize: 13; opacity: 0.75
                                        }
                                        Item {
                                            id: volTrackItem
                                            width: parent.width - 30; height: 22; anchors.verticalCenter: parent.verticalCenter
                                            Rectangle {
                                                anchors.verticalCenter: parent.verticalCenter
                                                width: parent.width; height: 5; radius: 3; color: Qt.rgba(1,1,1,0.07)
                                                Rectangle {
                                                    width: (ytCard.msVolume / 100) * parent.width; height: 5; radius: 3; color: ytCard.modeColor; opacity: 0.9
                                                    Behavior on color { ColorAnimation { duration: theme.normal } }
                                                    Behavior on width { NumberAnimation { duration: 80 } }
                                                }
                                            }
                                            Rectangle {
                                                width: 14; height: 14; radius: 7
                                                anchors.verticalCenter: parent.verticalCenter
                                                x: (ytCard.msVolume / 100) * (volTrackItem.width - width)
                                                color: volMouse.pressed ? ytCard.modeColor : Qt.rgba(1, 1, 1, 0.92)
                                                border.color: ytCard.modeColor; border.width: 2
                                                Behavior on x { NumberAnimation { duration: 80 } }
                                                Behavior on color { ColorAnimation { duration: 80 } }
                                            }
                                            MouseArea {
                                                id: volMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                                onPressed:         function(e) { ytCard.doSetVolume(Math.round(Math.max(0, Math.min(1, e.x / volTrackItem.width)) * 100)) }
                                                onPositionChanged: function(e) { if (pressed) ytCard.doSetVolume(Math.round(Math.max(0, Math.min(1, e.x / volTrackItem.width)) * 100)) }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // 3) CLIMATE HVAC
                        DashCard {
                            id: hvacCard
                            appName: "Climate"
                            accentColor: theme.climateAc
                            anchors.top: ytCard.bottom; anchors.topMargin: 10
                            anchors.right: parent.right
                            width: parent.width * 0.42; height: parent.height * 0.30

                            property bool   hvacOn:      (typeof HVACState !== 'undefined') ? HVACState.systemOn    : false
                            property int    hvacTemp:    (typeof HVACState !== 'undefined') ? HVACState.temperature : 22
                            property bool   hvacHeating: (typeof HVACState !== 'undefined') ? HVACState.heating     : false
                            property string hvacStatus:  (typeof HVACState !== 'undefined') ? HVACState.statusText  : "System Off"
                            property string hvacMode:    (typeof HVACState !== 'undefined') ? HVACState.modeText    : "OFF"

                            property color currentAccent: !hvacOn ? theme.t2      : (hvacHeating ? theme.youtubeAc  : theme.climateAc)
                            property color currentGlow:   !hvacOn ? "transparent" : (hvacHeating ? theme.youtubeGlow : theme.climateGlow)
                            property color currentBord:   !hvacOn ? theme.b2      : (hvacHeating ? theme.youtubeBord : theme.climateBord)

                            // ── Main layout: temp circle | controls ──────────────────
                            Item {
                                anchors.fill: parent; anchors.margins: 14

                                // Big temperature circle
                                Item {
                                    id: hvacCircle
                                    width: parent.height - 4; height: parent.height - 4
                                    anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter

                                    // Outer pulse ring
                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: parent.width + 18; height: parent.width + 18; radius: width / 2
                                        color: "transparent"
                                        border.color: Qt.rgba(hvacCard.currentAccent.r, hvacCard.currentAccent.g, hvacCard.currentAccent.b, 0.10)
                                        border.width: 5
                                        opacity: hvacCard.hvacOn ? 1 : 0
                                        Behavior on opacity { NumberAnimation { duration: theme.normal } }
                                        Behavior on border.color { ColorAnimation { duration: theme.normal } }
                                    }
                                    // Inner ring
                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: parent.width + 8; height: parent.width + 8; radius: width / 2
                                        color: "transparent"
                                        border.color: Qt.rgba(hvacCard.currentAccent.r, hvacCard.currentAccent.g, hvacCard.currentAccent.b, 0.25)
                                        border.width: 1.5
                                        opacity: hvacCard.hvacOn ? 1 : 0
                                        Behavior on opacity { NumberAnimation { duration: theme.normal } }
                                        Behavior on border.color { ColorAnimation { duration: theme.normal } }
                                    }
                                    // Circle body
                                    Rectangle {
                                        anchors.fill: parent; radius: width / 2
                                        color: hvacCard.hvacOn ? hvacCard.currentGlow : theme.bgDeep
                                        border.color: hvacCard.hvacOn ? hvacCard.currentBord : theme.b2; border.width: 2
                                        Behavior on color { ColorAnimation { duration: theme.normal } }
                                        Behavior on border.color { ColorAnimation { duration: theme.normal } }

                                        Column {
                                            anchors.centerIn: parent; spacing: 2

                                            Text {
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                text: hvacCard.hvacOn ? (hvacCard.hvacTemp + "°") : "OFF"
                                                font.family: theme.monoFont; font.pixelSize: 26; font.weight: Font.Bold
                                                color: hvacCard.hvacOn ? hvacCard.currentAccent : theme.t2
                                                Behavior on color { ColorAnimation { duration: theme.normal } }
                                            }
                                            Text {
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                text: hvacCard.hvacOn ? (hvacCard.hvacHeating ? "🔥" : "❄️") : ""
                                                font.pixelSize: 16; opacity: hvacCard.hvacOn ? 1 : 0
                                                Behavior on opacity { NumberAnimation { duration: theme.normal } }
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                            onClicked: if (typeof HVACState !== 'undefined') HVACState.toggleSystem()
                                        }
                                    }
                                }

                                // Controls column — compact to fit 105px usable height
                                Column {
                                    anchors.left: hvacCircle.right; anchors.leftMargin: 14
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    spacing: 6

                                    // "CLIMATE" label + status
                                    Text {
                                        text: "CLIMATE CONTROL"
                                        font.family: theme.monoFont; font.pixelSize: 9; font.letterSpacing: 2
                                        color: hvacCard.currentAccent
                                        Behavior on color { ColorAnimation { duration: theme.normal } }
                                    }

                                    // Status badge
                                    Rectangle {
                                        width: hvacStatusLbl.implicitWidth + 12; height: 18; radius: 9
                                        color: hvacCard.hvacOn ? Qt.rgba(hvacCard.currentAccent.r, hvacCard.currentAccent.g, hvacCard.currentAccent.b, 0.12) : Qt.rgba(1,1,1,0.04)
                                        border.color: hvacCard.hvacOn ? Qt.rgba(hvacCard.currentAccent.r, hvacCard.currentAccent.g, hvacCard.currentAccent.b, 0.35) : Qt.rgba(1,1,1,0.08)
                                        border.width: 1
                                        Behavior on color { ColorAnimation { duration: theme.normal } }
                                        Text { id: hvacStatusLbl; anchors.centerIn: parent; text: hvacCard.hvacStatus; font.family: theme.monoFont; font.pixelSize: 9; color: hvacCard.hvacOn ? theme.t0 : theme.t1; Behavior on color { ColorAnimation { duration: theme.normal } } }
                                    }

                                    // ❄️ / 🔥 segmented toggle
                                    Row {
                                        spacing: 0
                                        opacity: hvacCard.hvacOn ? 1 : 0.3
                                        Behavior on opacity { NumberAnimation { duration: theme.normal } }
                                        Rectangle {
                                            width: 44; height: 26; radius: 0; topLeftRadius: 13; bottomLeftRadius: 13
                                            color: !hvacCard.hvacHeating ? Qt.rgba(hvacCard.currentGlow.r, hvacCard.currentGlow.g, hvacCard.currentGlow.b, 0.85) : Qt.rgba(1,1,1,0.04)
                                            border.color: !hvacCard.hvacHeating ? hvacCard.currentBord : theme.b1; border.width: 1
                                            Behavior on color { ColorAnimation { duration: theme.fast } }
                                            Text { anchors.centerIn: parent; text: "❄️"; font.pixelSize: 13 }
                                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof HVACState !== 'undefined') HVACState.setMode("cold") }
                                        }
                                        Rectangle {
                                            width: 44; height: 26; radius: 0; topRightRadius: 13; bottomRightRadius: 13
                                            color: hvacCard.hvacHeating ? Qt.rgba(hvacCard.currentGlow.r, hvacCard.currentGlow.g, hvacCard.currentGlow.b, 0.85) : Qt.rgba(1,1,1,0.04)
                                            border.color: hvacCard.hvacHeating ? hvacCard.currentBord : theme.b1; border.width: 1
                                            Behavior on color { ColorAnimation { duration: theme.fast } }
                                            Text { anchors.centerIn: parent; text: "🔥"; font.pixelSize: 13 }
                                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof HVACState !== 'undefined') HVACState.setMode("hot") }
                                        }
                                    }

                                    // − temp + row
                                    Row {
                                        spacing: 8
                                        opacity: hvacCard.hvacOn ? 1 : 0.3
                                        Behavior on opacity { NumberAnimation { duration: theme.normal } }
                                        Rectangle {
                                            width: 26; height: 26; radius: 13
                                            color: minusHov.containsMouse ? Qt.rgba(hvacCard.currentAccent.r, hvacCard.currentAccent.g, hvacCard.currentAccent.b, 0.15) : theme.bgDeep
                                            border.color: hvacCard.currentBord; border.width: 1
                                            Behavior on color { ColorAnimation { duration: theme.fast } }
                                            Text { anchors.centerIn: parent; text: "−"; color: hvacCard.currentAccent; font.pixelSize: 16; font.weight: Font.Light }
                                            MouseArea { id: minusHov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof HVACState !== 'undefined' && HVACState.temperature > 16) HVACState.setTemperature(HVACState.temperature - 1) }
                                        }
                                        Text {
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: hvacCard.hvacTemp + "°C"
                                            font.family: theme.monoFont; font.pixelSize: 15; font.weight: Font.Bold
                                            color: hvacCard.hvacOn ? hvacCard.currentAccent : theme.t2
                                            Behavior on color { ColorAnimation { duration: theme.normal } }
                                        }
                                        Rectangle {
                                            width: 26; height: 26; radius: 13
                                            color: plusHov.containsMouse ? Qt.rgba(hvacCard.currentAccent.r, hvacCard.currentAccent.g, hvacCard.currentAccent.b, 0.25) : hvacCard.currentGlow
                                            border.color: hvacCard.currentBord; border.width: 1
                                            Behavior on color { ColorAnimation { duration: theme.fast } }
                                            Text { anchors.centerIn: parent; text: "+"; color: hvacCard.currentAccent; font.pixelSize: 16; font.weight: Font.Light }
                                            MouseArea { id: plusHov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof HVACState !== 'undefined' && HVACState.temperature < 30) HVACState.setTemperature(HVACState.temperature + 1) }
                                        }
                                    }
                                }
                            }
                        }

                        // 4) WEATHER
                        DashCard {
                            id: weatherCard
                            appName: "Weather"
                            accentColor: theme.weatherAc
                            anchors.bottom: parent.bottom; anchors.right: parent.right
                            width: parent.width * 0.42
                            height: parent.height * 0.22

                            property bool hasData:   weatherVM.appState === 2
                            property bool isLoading: weatherVM.appState === 1
                            property bool hasError:  weatherVM.appState === 3

                            property string displayTemp: {
                                if (!hasData) return "--"
                                return Math.round(weatherVM.temperature) + "°C"
                            }

                            property string displayDesc: {
                                if (isLoading) return "Loading..."
                                if (hasError)  return "Unavailable"
                                if (!hasData)  return "..."
                                return weatherVM.description !== "" ? weatherVM.description : "Clear"
                            }

                            property string displayIcon: {
                                if (!hasData) return "qrc:/assets/cloud.png"
                                return getWeatherIcon(weatherVM.condition)
                            }

                            property string displayCity: {
                                if (!hasData) return ""
                                return weatherVM.cityName || ""
                            }

                            Rectangle {
                                anchors.top:         parent.top
                                anchors.left:        parent.left
                                anchors.right:       parent.right
                                anchors.leftMargin:  30
                                anchors.rightMargin: 30
                                height: 1; radius: 1
                                opacity: 0.28
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 0.0;  color: "transparent" }
                                    GradientStop { position: 0.4;  color: theme.weatherAc }
                                    GradientStop { position: 0.6;  color: theme.weatherAc }
                                    GradientStop { position: 1.0;  color: "transparent" }
                                }
                            }

                            Rectangle {
                                anchors.top:        parent.top
                                anchors.right:      parent.right
                                anchors.topMargin:  -10
                                anchors.rightMargin: -10
                                width: 80; height: 80; radius: 40
                                color: weatherCard.hasData
                                       ? Qt.rgba(theme.weatherAc.r, theme.weatherAc.g, theme.weatherAc.b, 0.05)
                                       : "transparent"
                                Behavior on color { ColorAnimation { duration: 600 } }
                            }

                            Row {
                                anchors {
                                    fill:         parent
                                    leftMargin:   16
                                    rightMargin:  16
                                    topMargin:    12
                                    bottomMargin: 12
                                }
                                spacing: 16

                                // Left
                                Item {
                                    width:  48
                                    height: parent.height

                                    // weather Icon
                                    Item {
                                        anchors.centerIn: parent
                                        width:  44; height: 44
                                        visible: weatherCard.hasData

                                        // Soft glow disc behind icon
                                        Rectangle {
                                            anchors.centerIn: parent
                                            width: 44; height: 44; radius: 22
                                            color: Qt.rgba(theme.weatherAc.r, theme.weatherAc.g, theme.weatherAc.b, 0.10)
                                        }

                                        Image {
                                            anchors.centerIn: parent
                                            width: 36; height: 36
                                            source:   weatherCard.displayIcon
                                            fillMode: Image.PreserveAspectFit
                                            smooth:   true
                                            opacity:  weatherCard.hasData ? 1.0 : 0.0
                                            Behavior on opacity { NumberAnimation { duration: 400 } }
                                        }
                                    }

                                    // Error icon
                                    Text {
                                        anchors.centerIn: parent
                                        text: "⚠"
                                        font.pixelSize: 28
                                        color: theme.youtubeAc
                                        visible: weatherCard.hasError
                                    }
                                }

                                // ── Right
                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width:   parent.width - 48 - 16
                                    spacing: 5
                                    clip:    true

                                    // Temp + description row
                                    Row {
                                        spacing: 10
                                        width:   parent.width

                                        Text {
                                            id: tempDisplay
                                            text:           weatherCard.displayTemp
                                            font.family:    theme.monoFont
                                            font.pixelSize: 26
                                            font.weight:    Font.Bold
                                            font.letterSpacing: -0.5
                                            color: weatherCard.hasData ? theme.t0 : theme.t2
                                            Behavior on color { ColorAnimation { duration: 400 } }

                                            // Skeleton shimmer
                                            Rectangle {
                                                anchors.fill: parent
                                                visible:  !weatherCard.hasData
                                                color:    theme.b0
                                                radius:   4

                                                SequentialAnimation on opacity {
                                                    running:  parent.visible; loops: Animation.Infinite
                                                    NumberAnimation { to: 0.12; duration: 700; easing.type: Easing.InOutSine }
                                                    NumberAnimation { to: 0.50; duration: 700; easing.type: Easing.InOutSine }
                                                }
                                            }
                                        }

                                        // Vertical divider
                                        Rectangle {
                                            anchors.verticalCenter: tempDisplay.verticalCenter
                                            width: 1; height: 22; radius: 1
                                            color: Qt.rgba(1, 1, 1, 0.10)
                                            visible: weatherCard.hasData
                                        }

                                        Text {
                                            text:           weatherCard.displayDesc
                                            font.family:    theme.monoFont
                                            font.pixelSize: 11
                                            font.letterSpacing: 0.3
                                            color: weatherCard.hasData ? theme.t1 : theme.t2
                                            anchors.verticalCenter: tempDisplay.verticalCenter
                                            elide: Text.ElideRight
                                            width: parent.width - tempDisplay.implicitWidth - 11 - 10
                                            Behavior on color { ColorAnimation { duration: 400 } }

                                            Rectangle {
                                                anchors.fill: parent
                                                visible:  !weatherCard.hasData
                                                color:    theme.b0
                                                radius:   4

                                                SequentialAnimation on opacity {
                                                    running:  parent.visible; loops: Animation.Infinite
                                                    NumberAnimation { to: 0.12; duration: 700; easing.type: Easing.InOutSine }
                                                    NumberAnimation { to: 0.50; duration: 700; easing.type: Easing.InOutSine }
                                                }
                                            }
                                        }
                                    }

                                    // City chip
                                    Rectangle {
                                        width:  cityText.width + 12
                                        height: 16; radius: 8
                                        visible: weatherCard.displayCity !== ""
                                        color:  Qt.rgba(1, 1, 1, 0.05)
                                        border.color: Qt.rgba(1, 1, 1, 0.09)
                                        border.width: 1

                                        Text {
                                            id: cityText
                                            anchors.centerIn: parent
                                            text:  weatherCard.displayCity
                                            font.family:      theme.monoFont
                                            font.pixelSize:   9
                                            font.letterSpacing: 0.8
                                            color: theme.t2
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // ───────────────────────────────────────────────────────────────
                // PAGE 2: App Tiles
                // ───────────────────────────────────────────────────────────────
                Item {
                    id: appsPage

                    GridView {
                        id: appGrid
                        anchors.centerIn: parent

                        // Force exactly 4 columns and 2 rows
                        cellWidth: 180; cellHeight: 190
                        width: cellWidth * 4; height: cellHeight * 2 /*so it be in the shape of 4 top and 4 bottom*/

                        model: appsModel /*where apps are defined image source name colors */
                        interactive: false

                        /*** this will happen no. off apps times ***/
                        delegate: Item {
                            id: tile
                            width: 180; height: 190
                            opacity: 1
                            property real hoverScale: 1.0
                            Behavior on hoverScale { NumberAnimation { duration: theme.fast; easing.type: Easing.OutCubic } }

                            Rectangle {
                                id: card
                                width: 160; height: 178
                                anchors.centerIn: parent

                                radius: theme.r3
                                color: tile.hoverScale > 1.0 ? theme.bgHover : theme.bgCard
                                border.color: modelData.bordColor
                                border.width: 1.2
                                clip: true

                                transform: [ /*scale bigger on hover*/
                                    Scale {
                                        origin.x: card.width / 2; origin.y: card.height / 2
                                        xScale: tile.hoverScale; yScale: tile.hoverScale
                                    },
                                    Translate { id: entryTranslate; y: 20 }
                                ]

                                Behavior on color { ColorAnimation { duration: theme.fast } }

                                Rectangle {
                                    /*almost a circle on top*/
                                    id: topGlow
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.top: parent.top; anchors.topMargin: -20
                                    width: parent.width * 0.75; height: 80; radius: 40
                                    color: modelData.glowColor
                                    opacity: 0.45 + (tile.hoverScale - 1.0) * 4
                                }

                                Rectangle {
                                    id: scanline
                                    anchors.left: parent.left; anchors.right: parent.right
                                    height: parent.height * 0.22
                                    color: Qt.rgba(modelData.accentColor.r, modelData.accentColor.g, modelData.accentColor.b, 0.055)
                                    y: -height
                                    /*shading recatagle animation*/
                                    NumberAnimation on y {
                                        running: true; loops: Animation.Infinite
                                        from: -scanline.height; to: card.height + scanline.height
                                        duration: 10000; easing.type: Easing.Linear
                                    }
                                }

                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.left: parent.left; anchors.right: parent.right
                                    anchors.leftMargin: 14; anchors.rightMargin: 14
                                    height: 2.5; radius: 2
                                    color: modelData.accentColor
                                    opacity: 0.40 + (tile.hoverScale - 1.0) * 6
                                    Behavior on opacity { NumberAnimation { duration: theme.fast } }
                                }

                                Item {
                                    id: iconArea
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.top: parent.top; anchors.topMargin: parent.height * 0.20
                                    width: 64; height: 64

                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: 62; height: 62; radius: theme.rFull
                                        color: Qt.rgba(modelData.accentColor.r, modelData.accentColor.g, modelData.accentColor.b, 0.11)
                                        border.color: Qt.rgba(modelData.accentColor.r, modelData.accentColor.g, modelData.accentColor.b, 0.38)
                                        border.width: 1.5
                                    }

                                    // Source icon (hidden — rendered & recolored by MultiEffect
                                    // below so monochrome glyphs stay visible in both light
                                    // and dark themes, tinted to the app's accent colour).
                                    Image {
                                        id: appIconSrc
                                        anchors.centerIn: parent
                                        width: 28; height: 28
                                        source: modelData.iconSource /*image source*/
                                        fillMode: Image.PreserveAspectFit
                                        smooth: true
                                        visible: false
                                    }

                                    MultiEffect {
                                        anchors.centerIn: parent
                                        width: 28; height: 28
                                        source: appIconSrc
                                        colorization: 1.0
                                        colorizationColor: modelData.accentColor
                                        opacity: 0.95
                                    }
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.top: iconArea.bottom; anchors.topMargin: 18
                                    text: modelData.appName.toUpperCase() /*app name*/
                                    font.family: theme.displayFont
                                    font.pixelSize: 15; font.weight: 700; font.letterSpacing: 2.5
                                    color: theme.t0
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.top: iconArea.bottom; anchors.topMargin: 42
                                    text: modelData.appSub.toUpperCase()
                                    font.family: theme.displayFont
                                    font.pixelSize: 9; font.weight: 500; font.letterSpacing: 2
                                    color: modelData.accentColor
                                    opacity: 0.85
                                }

                                Rectangle {
                                    id: ripple
                                    anchors.centerIn: parent
                                    width: 0; height: 0; radius: width / 2
                                    color: modelData.accentColor; opacity: 0
                                }
                            }

                            MouseArea {
                                anchors.fill: card
                                hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onEntered:  tile.hoverScale = 1.045
                                onExited:   tile.hoverScale = 1.0
                                onPressed:  { tile.hoverScale = 0.96; rippleAnim.start() }
                                onReleased: { tile.hoverScale = containsMouse ? 1.045 : 1.0; appLauncher.openApp(modelData.appName) }
                            }
                        }
                    }
                }
            }

            // ═══════════════════════════════════════════════════════════════════
            // PAGE INDICATOR DOTS
            // ═══════════════════════════════════════════════════════════════════
            Item {
                width: parent.width; height: 24

                Row {
                    anchors.centerIn: parent; spacing: 7

                    Repeater {
                        model: 2
                        Rectangle {
                            height: 5; radius: 3
                            width: swipe.currentIndex === index ? 22 : 6
                            color: swipe.currentIndex === index ? theme.blue : theme.t2

                            Behavior on width { NumberAnimation { duration: theme.normal; easing.type: Easing.OutCubic } }
                            Behavior on color { ColorAnimation { duration: theme.normal } }

                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: swipe.setCurrentIndex(index)
                            }
                        }
                    }
                }
            }

            // ═══════════════════════════════════════════════════════════════════
            // BOTTOM CONTROL BAR
            // ═══════════════════════════════════════════════════════════════════
            Rectangle {
                id: bottomBar
                width: parent.width; height: 76
                color: theme.bgFooter
                border.color: theme.b0

                Rectangle {
                    anchors.top: parent.top; width: parent.width; height: 1
                    color: theme.b1
                }

                Row {
                    anchors.centerIn: parent; spacing: 0

                    Repeater {
                        model: [
                            { icon: "🚗",  label: "VEHICLE",   sep: false, app: "Vehicle"   },
                            { icon: "❄️",  label: "DEFROST",   sep: false, app: "Climate"   },
                            { icon: "💺",  label: "SEAT HEAT", sep: false, app: "SeatHeat"  },
                            { icon: "🔊",  label: "VOLUME",    sep: true,  app: "Volume"    },
                            { icon: "🎵",  label: "MEDIA",     sep: false, app: "Media"     },
                            { icon: "📞",  label: "PHONE",     sep: false, app: "Phone"     }
                        ]

                        Row {
                            spacing: 0

                            Rectangle {
                                visible: modelData.sep
                                width: 1; height: 28; color: theme.b1
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Item { visible: modelData.sep; width: 8; height: 1 }

                            Rectangle {
                                id: footBtn
                                property bool hovered: false
                                width: 80; height: 54; radius: theme.r1
                                color: hovered ? theme.b0 : "transparent"

                                Behavior on color { ColorAnimation { duration: theme.fast } }

                                Column {
                                    anchors.centerIn: parent; spacing: 5

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: modelData.icon; font.pixelSize: 22
                                        opacity: footBtn.hovered ? 1.0 : 0.55
                                        Behavior on opacity { NumberAnimation { duration: theme.fast } }
                                    }

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: modelData.label
                                        font.family: theme.displayFont
                                        font.pixelSize: 11; font.weight: Font.Bold; font.letterSpacing: 1.5
                                        color: theme.t1
                                        opacity: footBtn.hovered ? 1.0 : 0.55
                                        Behavior on opacity { NumberAnimation { duration: theme.fast } }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onEntered: footBtn.hovered = true
                                    onExited:  footBtn.hovered = false
                                    onClicked: appLauncher.openApp(modelData.app)
                                }
                            }
                        }
                    }
                }
            }
        }

    }
}
