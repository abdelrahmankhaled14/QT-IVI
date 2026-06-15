// qml/WeatherApp.qml
import QtQuick
import QtQuick.Controls

Item {
    id: weatherAppRoot
    signal closeApp()


    // ── Top Bar ──────────────────────────────────────────────
    Rectangle {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 48
        color: theme.bgFooter
        z: 10

        // Back button
        Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            width: 130
            height: 34
            radius: theme.r1
            color: backMouse.containsMouse? theme.weatherGlow: theme.bgCard
            border.color: theme.weatherBord
            border.width: 1

            Behavior on color {
                ColorAnimation { duration: theme.fast }
            }

            Text {
                anchors.centerIn: parent
                text: "← Home"
                font.family: theme.displayFont
                font.pixelSize: 13
                color: theme.weatherAc
            }

            MouseArea {
                id: backMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: weatherAppRoot.closeApp()
            }
        }

        Text {
            anchors.centerIn: parent
            text: "WEATHER"
            font.family: theme.displayFont
            font.pixelSize: 13
            font.letterSpacing: 4
            color: theme.t2
        }
    }

    Rectangle {
        anchors.top: topBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: theme.bgSurface

        SplashScreen {
            anchors.fill: parent
            visible: !weatherVM.splashDone
            opacity: visible ? 1.0 : 0.0
            z: 10
            Behavior on opacity {
                NumberAnimation { duration: theme.slow; easing.type: Easing.InOutQuad }
            }
        }

        MainScreen {
            anchors.fill: parent
            visible: weatherVM.splashDone
            opacity: visible ? 1.0 : 0.0
            z: 1
            Behavior on opacity {
                NumberAnimation { duration: theme.slow; easing.type: Easing.InOutQuad }
            }
        }
    }

    Component.onCompleted: weatherVM.refresh()
}