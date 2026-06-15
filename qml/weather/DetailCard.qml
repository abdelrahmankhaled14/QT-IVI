import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    property string iconSource: ""
    property string label: ""
    property string value: ""

    Layout.fillWidth: true
    Layout.fillHeight: true
    radius: theme.r1
    color: theme.bgDeep
    border.color: theme.weatherBord
    border.width: 1

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 6

        Image {
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            Layout.alignment: Qt.AlignHCenter
            source: iconSource
            fillMode: Image.PreserveAspectFit
            smooth: true
        }

        Text {
            text: label
            font.pixelSize: 10
            font.family: theme.displayFont
            color: theme.t1
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: value
            font.pixelSize: 14
            font.bold: true
            font.family: theme.displayFont
            color: theme.t0
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
