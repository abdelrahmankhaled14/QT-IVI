import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root

    property string label: ""
    property bool   isActive: false

    signal clicked()

    radius: theme.radiusSmall
    color:  isActive  ? theme.sidebarActive :
            hov.containsMouse ? theme.sidebarHover :
            "transparent"

    anchors.leftMargin:  theme.spacingSmall
    anchors.rightMargin: theme.spacingSmall

    Behavior on color {
        ColorAnimation { duration: theme.animFast }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin:  theme.spacingMedium
        anchors.rightMargin: theme.spacingMedium
        spacing: theme.spacingMedium

        Text {
            text: root.label
            font.family: theme.displayFont
            font.pixelSize: theme.fontSizeBody
            font.weight: root.isActive ? theme.fontWeightMedium : theme.fontWeightNormal
            color: root.isActive ? theme.textOnAccent : theme.t0
            Layout.fillWidth: true
        }
    }

    HoverHandler { id: hov }

    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
    }
}
