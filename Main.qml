import QtQuick 2.15
import QtQuick.Controls 2.15
import QtWebEngine
import QtQuick.VirtualKeyboard

Window {
    id: root
    width: 1280
    height: 720
    visible: true
    title: "HMI System"

    property AppTheme theme: AppTheme {} //to be used by others
    color: theme.bgVoid

    // ─── Splash Screen ───────────────────────────────────────────────────
    Item {
        id: splashScreen
        anchors.fill: parent
        z: 10
        visible: opacity > 0

        Rectangle {
            anchors.fill: parent
            color: theme.bgVoid
            Rectangle { anchors.centerIn: parent; width: 500; height: 500; radius: 250; color: theme.bgSurface; opacity: 0.9 }
            Rectangle { anchors.centerIn: parent; width: 380; height: 380; radius: 190; color: theme.bgCard;    opacity: 0.8 }
            Rectangle { anchors.centerIn: parent; width: 260; height: 260; radius: 130; color: theme.bgHover;   opacity: 0.7 }
        }

        Item {
            id: logoMark
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -30
            width: 120; height: 120
            opacity: 0; scale: 0.6

            Rectangle { anchors.centerIn: parent; width: 110; height: 110; radius: 55; color: "transparent"; border.color: theme.blue; border.width: 2; opacity: 0.9 }
            Rectangle { anchors.centerIn: parent; width: 86;  height: 86;  radius: 43; color: "transparent"; border.color: theme.blueBord; border.width: 1; opacity: 0.6 }
            Rectangle {anchors.centerIn: parent; width: 18; height: 18; radius: 9; color: theme.blue}

            //rotating circle
            Rectangle {
                anchors.centerIn: parent; width: 110; height: 110; radius: 55
                color: "transparent"; border.color: "transparent"
                RotationAnimation on rotation { running: splashScreen.visible; loops: Animation.Infinite; from: 0; to: 360; duration: 2400; easing.type: Easing.Linear }
                Rectangle { x: 50; y: -3; width: 10; height: 10; radius: 5; color: theme.blue; opacity: 0.95 }
            }
            //fading ball in middle
            ParallelAnimation {
                id: logoInAnim; running: false
                NumberAnimation { target: logoMark; property: "opacity"; to: 1; duration: 1000; easing.type: Easing.OutCubic }
                NumberAnimation { target: logoMark; property: "scale";   to: 1; duration: 1000; easing.type: Easing.OutBack }
            }
        }

        Column {
            id: brandText
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: logoMark.bottom
            anchors.topMargin: 22
            spacing: 6; opacity: 0
            //name
            Text { anchors.horizontalCenter: parent.horizontalCenter; text: "NEXUS"; font.family: theme.monoFont; font.pixelSize: 38; font.letterSpacing: 14; font.weight: 300; color: theme.t0 }
            Text { anchors.horizontalCenter: parent.horizontalCenter; text: "INFOTAINMENT SYSTEM"; font.family: theme.monoFont; font.pixelSize: 11; font.letterSpacing: 5; color: theme.blue; opacity: 0.8 }
            NumberAnimation on opacity { id: brandInAnim; running: false; to: 1; duration: 600; easing.type: Easing.OutCubic }
        }

        NumberAnimation { id: splashFadeOut; target: splashScreen; property: "opacity"; to: 0; duration: 600; easing.type: Easing.InCubic; onStopped: splashScreen.visible = false }

        SequentialAnimation {
            id: bootSequence; running: true
            PauseAnimation  { duration: 200 }
            ScriptAction    { script: logoInAnim.start() }
            PauseAnimation  { duration: 600 }
            ScriptAction    { script: brandInAnim.start() }
            PauseAnimation  { duration: 600 }
            ScriptAction    { script: splashFadeOut.start() }
        }
    }

    // ─── Status Bar ──────────────────────────────────────────────────────
    Rectangle {
        id: statusBar

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        height: 44
        color: theme.bgFooter

        border.width: 1
        border.color: theme.b1

        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: theme.b0
        }

        // ─── Left Branding ─────────────────────────────────────────
        Text {
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter

            text: "NEXUS OS"

            font.family: theme.monoFont
            font.pixelSize: 11
            font.letterSpacing: 3

            color: theme.t2
        }

        // ─── Clock + Date ──────────────────────────────────────────
        Column {
            anchors.centerIn: parent
            spacing: 0

            Text {
                id: clockText

                anchors.horizontalCenter: parent.horizontalCenter

                text: Qt.formatTime(new Date(), "HH:mm")

                font.family: theme.monoFont
                font.pixelSize: 16
                font.letterSpacing: 2

                color: theme.t0
            }

            Text {
                id: dateText

                anchors.horizontalCenter: parent.horizontalCenter

                text: Qt.formatDate(new Date(), "ddd, MMM d")

                font.family: theme.monoFont
                font.pixelSize: 9
                font.letterSpacing: 2

                color: theme.t1
            }
        }

        // ─── Right Status Icons Area ───────────────────────────────
        Row {
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12

            Text {
                text: "LTE"
                font.family: theme.monoFont
                font.pixelSize: 10
                color: theme.t1
            }

            Rectangle {
                width: 8
                height: 8
                radius: 999
                color: theme.success
            }
        }

        // ─── Live Clock Update ─────────────────────────────────────
        Timer {
            interval: 1000
            running: true
            repeat: true

            onTriggered: {
                clockText.text = Qt.formatTime(new Date(), "HH:mm")
                dateText.text = Qt.formatDate(new Date(), "ddd, MMM d")
            }
        }
    }

    // ─── Screen Manager ──────────────────────────────────────────────────
    StackView {
        id: screenStack
        anchors.top: statusBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: bottomBar.top
        z: 1

        property string currentAppName: ""
        property bool isAppOpening: false

        initialItem: "qml/applauncher/Applauncher.qml"

        onCurrentItemChanged: {
            if (currentItem) {
                if (currentItem.openApp !== undefined) {
                    currentItem.openApp.connect(handleOpenApp)
                }
                if (currentItem.closeApp !== undefined) {
                    currentItem.closeApp.connect(handleCloseApp)
                }
            }
        }

        function handleOpenApp(appName) {
            if (isAppOpening) {
                console.log("App already opening, ignoring")
                return
            }

            isAppOpening = true
            console.log("Opening app: " + appName)
            currentAppName = appName

            // ROUTES TO ALL YOUR APPS
            if (appName === "YouTube") { screenStack.push("qml/youtube/Youtube.qml") }
            else if (appName === "Sound") { screenStack.push("qml/spotify/Spotify.qml") }
            else if (appName === "Weather") { screenStack.push("qml/weather/weather.qml") }
            else if (appName === "Climate") { screenStack.push("qml/HVAC/HVAC.qml") }
            else if (appName === "Settings") { screenStack.push("qml/settings/settings.qml") }
            else if (appName === "Navigation"){ screenStack.push("qml/navigation/Navi.qml") }
            else if (appName === "Phone") { screenStack.push("qml/phone/phone.qml") }
            else if (appName === "Media") { screenStack.push("qml/media/Media.qml") }
            else if (appName === "Vehicle") { screenStack.push("qml/applauncher/VehiclePage.qml") }
            else if (appName === "SeatHeat") { screenStack.push("qml/applauncher/SeatHeatPage.qml") }
            else if (appName === "Volume") { screenStack.push("qml/settings/qml/pages/VolumePage.qml") }

            resetTimer.restart()
        }

        function handleCloseApp() {
            console.log("Closing app: ")
            currentAppName = ""
            screenStack.pop()
        }

        Timer {
            id: resetTimer
            interval: 500
            onTriggered: screenStack.isAppOpening = false
        }
    }

    // ─── Bottom Bar ──────────────────────────────────────────────────────
    Rectangle {
        id: bottomBar
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 44
        color: theme.bgFooter
        z: 5

        Rectangle {
            anchors.top: parent.top
            width: parent.width
            height: 1
            color: theme.b0
        }

        Text {
            anchors.centerIn: parent
            text: screenStack.depth > 1 ? "← HOME" : "HOME"
            font.family: theme.monoFont
            font.pixelSize: 11
            font.letterSpacing: 3
            color: screenStack.depth > 1 ? theme.blue : theme.t2
            Behavior on color { ColorAnimation { duration: theme.fast } }
        }

        MouseArea {
            anchors.fill: parent
            enabled: screenStack.depth > 1
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                screenStack.currentAppName = ""
                screenStack.pop()
            }
        }
    }

    // ─── On-screen Virtual Keyboard ──────────────────────────────────────
    // Single panel for the whole UI. It slides up from the bottom whenever
    // any text input gains focus (QML TextFields and web page inputs), and
    // slides away when input ends. Sits above everything (z highest).
    InputPanel {
        id: inputPanel
        z: 999
        // Smaller, centered keyboard — height scales with width so the whole
        // panel (and key size) shrinks proportionally.
        width: parent.width * 0.6
        x: (parent.width - width) / 2
        y: parent.height

        states: State {
            name: "visible"
            when: inputPanel.active
            PropertyChanges {
                target: inputPanel
                y: parent.height - inputPanel.height
            }
        }
        transitions: Transition {
            from: ""
            to: "visible"
            reversible: true
            NumberAnimation {
                properties: "y"
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }
    }
}