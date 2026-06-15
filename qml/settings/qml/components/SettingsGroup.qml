import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root

    property string groupTitle: ""

    default property alias content: contentColumn.data

    width: parent ? parent.width : 0
    implicitHeight: mainColumn.implicitHeight + theme.spacingMedium * 2

    radius: theme.r2
    color: theme.bgCard

    antialiasing: true
    smooth: true

    border.width: 1
    border.color: Qt.rgba(1,1,1,0.04)

    ColumnLayout {
        id: mainColumn

        anchors.fill: parent
        anchors.margins: theme.spacingMedium

        spacing: theme.spacingSmall

        // Group title
        Text {
            text: root.groupTitle

            visible: text.length > 0

            font.family: theme.displayFont
            font.pixelSize: theme.fontSizeSmall
            font.weight: theme.fontWeightMedium
            font.letterSpacing: 1.5

            color: theme.t1

            Layout.fillWidth: true

            bottomPadding: theme.spacingSmall
        }

        // Settings rows container
        Column {
            id: contentColumn

            Layout.fillWidth: true

            spacing: 0
        }
    }
}
