import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root

    property string label: ""
    property string description: ""
    property bool showDivider: true

    default property alias control: controlSlot.data

    width: parent ? parent.width : implicitWidth
    implicitHeight: contentLayout.implicitHeight + theme.spacingMedium * 1.5

    color: "transparent"

    antialiasing: true
    smooth: true

    RowLayout {
        id: contentLayout

        anchors {
            fill: parent
            leftMargin: theme.spacingMedium
            rightMargin: theme.spacingMedium
            topMargin: theme.spacingSmall
            bottomMargin: theme.spacingSmall
        }

        spacing: theme.spacingMedium

        ColumnLayout {
            Layout.fillWidth: true

            spacing: 4

            Text {
                text: root.label

                font.family: theme.displayFont
                font.pixelSize: theme.fontSizeBody
                font.weight: Font.Medium

                color: theme.t0

                Layout.fillWidth: true

                elide: Text.ElideRight
            }

            Text {
                text: root.description

                visible: text.length > 0

                font.family: theme.displayFont
                font.pixelSize: theme.fontSizeSmall

                color: theme.t1

                wrapMode: Text.WordWrap

                Layout.fillWidth: true
            }
        }

        // Right-side widget/control
        Item {
            id: controlSlot

            Layout.alignment: Qt.AlignVCenter

            Layout.preferredWidth: childrenRect.width
            Layout.preferredHeight: childrenRect.height
        }
    }

    // Bottom divider
    Rectangle {
        visible: root.showDivider

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom

            leftMargin: theme.spacingMedium
            rightMargin: theme.spacingMedium
        }

        height: 1

        color: theme.divider

        opacity: 0.7
    }
}
