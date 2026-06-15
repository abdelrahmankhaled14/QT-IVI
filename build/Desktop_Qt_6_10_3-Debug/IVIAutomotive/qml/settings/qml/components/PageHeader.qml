import QtQuick 2.15

Item {
    property string title:    ""
    property string subtitle: ""

    height: subtitleText.visible ? 64 : 48

    Text {
        id: titleText
        text: title
        font.family: theme.displayFont
        font.pixelSize: theme.fontSizeHeading
        font.weight: theme.fontWeightBold
        color: theme.t0
        anchors.top: parent.top
    }

    Text {
        id: subtitleText
        text: subtitle
        font.family: theme.displayFont
        font.pixelSize: theme.fontSizeSmall
        color: theme.t1
        visible: subtitle.length > 0
        anchors.top: titleText.bottom
        anchors.topMargin: 2
    }
}
