import QtQuick 2.15

Item {
        id: cBase
        property string appName: ""
        property color accentColor: theme.t0

        property real hoverScale: 1
        scale: hoverScale
        Behavior on scale { NumberAnimation { duration: theme.fast; easing.type: Easing.OutCubic } }

        Rectangle {
            anchors.fill: parent
            radius: theme.r2
            color: theme.bgCard
            border.color: Qt.rgba(cBase.accentColor.r, cBase.accentColor.g, cBase.accentColor.b, 0.3)
            border.width: 1.5
            clip: true

        }

        MouseArea {
            anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
            onEntered: cBase.hoverScale = 1.03
            onExited: cBase.hoverScale = 1.0
            onPressed: cBase.hoverScale = 0.98
            onReleased: {appLauncher.openApp(cBase.appName)}
        }
    }