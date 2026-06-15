import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "."  // Import MediaState

Item {
    id: radioPage
    width: SwipeView.view ? SwipeView.view.width : 800
    height: SwipeView.view ? SwipeView.view.height : 600

    // ══════════════════════════════════════════════════════════════════
    // MEDIASTATE INTEGRATION
    // ══════════════════════════════════════════════════════════════════
    Connections {
        target: radioManager
        function onCurrentStationChanged() {
            if (radioManager.currentStation !== "") {
                updateMediaState()
            }
        }
        function onPlayingChanged() {
            updateMediaState()
        }
    }

    function updateMediaState() {
        if (typeof MediaState !== 'undefined') {
            var station = radioManager.currentStation || ""
            var playing = radioManager.playing
            var country = ""
            var tags = ""

            // Find current station details
            for (var i = 0; i < radioManager.stations.length; i++) {
                if (radioManager.stations[i].name === station) {
                    country = radioManager.stations[i].country || ""
                    tags = radioManager.stations[i].tags || ""
                    break
                }
            }

            MediaState.updateFromRadio(station, country, tags, playing)
        }
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: theme.bgSurface }
            GradientStop { position: 1.0; color: theme.bgDeep }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // Status Bar
        Rectangle {
            Layout.fillWidth: true
            height: 40
            radius: theme.r1
            color: theme.bgCard
            border.color: theme.b1
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                Text {
                    text: "📻"
                    font.pixelSize: 16
                }

                Text {
                    Layout.fillWidth: true
                    text: radioManager.statusMsg
                    font.pixelSize: 12
                    color: theme.t0
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }

                BusyIndicator {
                    width: 20
                    height: 20
                    running: radioManager.loading
                    visible: radioManager.loading
                }
            }
        }

        // Search Bar
        Rectangle {
            Layout.fillWidth: true
            height: 50
            radius: 25
            color: theme.bgCard
            border.color: theme.b1
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 12
                spacing: 12

                TextField {
                    id: genreField
                    Layout.fillWidth: true
                    placeholderText: "Search genre (jazz, pop, rock, classical...)"
                    font.pixelSize: 14
                    color: theme.t0
                    background: Item {}
                    onAccepted: radioManager.fetchStations(genreField.text)
                }

                Rectangle {
                    width: 36
                    height: 36
                    radius: 18
                    color: searchMouseArea.pressed ? Qt.darker(theme.navigationAc, 1.2) : (searchMouseArea.containsMouse ? Qt.lighter(theme.navigationAc, 1.1) : theme.navigationAc)

                    Text {
                        anchors.centerIn: parent
                        text: "🔍"
                        font.pixelSize: 16
                    }

                    MouseArea {
                        id: searchMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: radioManager.fetchStations(genreField.text)
                    }
                }
            }
        }

        // Quick Genre Buttons
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Repeater {
                model: ["Pop", "Jazz", "Rock", "Classical", "Electronic"]

                Rectangle {
                    Layout.fillWidth: true
                    height: 36
                    radius: 18
                    color: genreButtonMouse.pressed ? Qt.darker(theme.bgHover, 1.2) : (genreButtonMouse.containsMouse ? Qt.lighter(theme.bgHover, 1.2) : theme.bgHover)

                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        font.pixelSize: 12
                        font.bold: true
                        color: theme.t0
                    }

                    MouseArea {
                        id: genreButtonMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            genreField.text = modelData
                            radioManager.fetchStations(modelData)
                        }
                    }
                }
            }
        }

        // Now Playing Bar
        Rectangle {
            Layout.fillWidth: true
            height: 90
            radius: theme.r2
            visible: radioManager.currentStation !== ""

            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: theme.navigationAc }
                GradientStop { position: 1.0; color: Qt.darker(theme.navigationAc, 1.3) }
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 14

                // Station Icon
                Rectangle {
                    width: 56
                    height: 56
                    radius: 28
                    color: theme.b2

                    Text {
                        anchors.centerIn: parent
                        text: "📻"
                        font.pixelSize: 26
                    }

                    SequentialAnimation on scale {
                        loops: Animation.Infinite
                        running: radioManager.playing
                        NumberAnimation { to: 1.08; duration: 600; easing.type: Easing.InOutQuad }
                        NumberAnimation { to: 1.0; duration: 600; easing.type: Easing.InOutQuad }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        Layout.fillWidth: true
                        text: radioManager.currentStation
                        font.pixelSize: 15
                        font.bold: true
                        color: theme.textOnAccent
                        elide: Text.ElideRight
                    }

                    RowLayout {
                        spacing: 8

                        Rectangle {
                            width: 10
                            height: 10
                            radius: 5
                            color: radioManager.playing ? theme.success : theme.danger

                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                running: radioManager.playing
                                NumberAnimation { to: 0.4; duration: 500 }
                                NumberAnimation { to: 1.0; duration: 500 }
                            }
                        }

                        Text {
                            text: radioManager.playing ? "Live" : "Stopped"
                            font.pixelSize: 12
                            color: Qt.rgba(1, 1, 1, 0.8)
                        }
                    }
                }

                // Play/Pause Button
                Rectangle {
                    width: 50
                    height: 50
                    radius: 25
                    color: theme.textOnAccent

                    Text {
                        anchors.centerIn: parent
                        text: radioManager.playing ? "⏸" : "▶"
                        font.pixelSize: 20
                        color: theme.navigationAc
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            radioManager.togglePlayPause()
                            // Update MediaState
                            if (typeof MediaState !== 'undefined') {
                                MediaState.isPlaying = radioManager.playing
                                MediaState.statusText = radioManager.playing ?
                                    "Radio: " + radioManager.currentStation : "Radio Stopped"
                            }
                        }
                    }
                }

                // Volume Control
                RowLayout {
                    spacing: 8
                    Layout.preferredWidth: 160

                    Text {
                        text: "🔊"
                        font.pixelSize: 14
                        color: theme.textOnAccent
                    }

                    Item {
                        Layout.fillWidth: true
                        height: 30

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width
                            height: 6
                            radius: 3
                            color: theme.b1

                            Rectangle {
                                width: (radioManager.volume / 100.0) * parent.width
                                height: parent.height
                                radius: 3
                                color: theme.textOnAccent
                            }
                        }

                        Rectangle {
                            width: 18
                            height: 18
                            radius: 9
                            color: radioSliderMouse.pressed ? Qt.rgba(1, 1, 1, 0.8) : theme.textOnAccent
                            x: (radioManager.volume / 100.0) * (parent.width - width)
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        MouseArea {
                            id: radioSliderMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            onPressed: function(mouse) {
                                updateRadioVolume(mouse.x)
                            }

                            onPositionChanged: function(mouse) {
                                if (pressed) {
                                    updateRadioVolume(mouse.x)
                                }
                            }

                            function updateRadioVolume(mouseX) {
                                var newVolume = Math.round((mouseX / width) * 100)
                                newVolume = Math.max(0, Math.min(100, newVolume))
                                radioManager.setVolume(newVolume)
                                // Update MediaState volume
                                if (typeof MediaState !== 'undefined') {
                                    MediaState.setVolume(newVolume)
                                }
                            }
                        }
                    }

                    Text {
                        text: radioManager.volume + "%"
                        font.pixelSize: 11
                        font.bold: true
                        color: theme.textOnAccent
                        Layout.preferredWidth: 35
                    }
                }
            }
        }

        // Stations Header
        RowLayout {
            Layout.fillWidth: true
            visible: radioManager.stations.length > 0

            Text {
                text: "📡 Stations"
                font.pixelSize: 15
                font.bold: true
                color: theme.t0
            }

            Item { Layout.fillWidth: true }

            Text {
                text: radioManager.stations.length + " found"
                font.pixelSize: 12
                color: theme.t1
            }
        }

        // Stations List
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: theme.r2
            color: theme.bgCard
            border.color: theme.b1
            border.width: 1
            visible: radioManager.stations.length > 0
            clip: true

            ListView {
                id: stationList
                anchors.fill: parent
                anchors.margins: 8
                model: radioManager.stations
                spacing: 6
                clip: true

                ScrollBar.vertical: ScrollBar {
                    active: true
                    policy: ScrollBar.AsNeeded
                }

                delegate: Rectangle {
                    width: stationList.width - (stationList.ScrollBar.vertical.visible ? 16 : 8)
                    height: 60
                    radius: theme.r1
                    color: {
                        if (radioManager.currentStation === modelData.name) return theme.blueDim
                        if (stationMouseArea.containsMouse) return theme.bgHover
                        return "transparent"
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 20
                            color: theme.b1

                            Text {
                                anchors.centerIn: parent
                                text: "📻"
                                font.pixelSize: 18
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                Layout.fillWidth: true
                                text: modelData.name
                                font.pixelSize: 13
                                font.bold: true
                                color: theme.t0
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                text: modelData.country + (modelData.tags ? " • " + modelData.tags.split(",")[0] : "")
                                font.pixelSize: 10
                                color: theme.t1
                                elide: Text.ElideRight
                            }
                        }

                        Rectangle {
                            width: 36
                            height: 36
                            radius: 18
                            color: radioManager.currentStation === modelData.name && radioManager.playing
                                   ? theme.navigationAc : theme.b1

                            Text {
                                anchors.centerIn: parent
                                text: radioManager.currentStation === modelData.name && radioManager.playing
                                      ? "⏸" : "▶"
                                font.pixelSize: 14
                                color: radioManager.currentStation === modelData.name && radioManager.playing
                                       ? theme.textOnAccent : theme.navigationAc
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (radioManager.currentStation === modelData.name && radioManager.playing) {
                                        radioManager.stop()
                                        // Update MediaState
                                        if (typeof MediaState !== 'undefined') {
                                            MediaState.stop()
                                        }
                                    } else {
                                        radioManager.playStation(modelData.url, modelData.name)
                                        // Update MediaState
                                        if (typeof MediaState !== 'undefined') {
                                            MediaState.updateFromRadio(
                                                modelData.name,
                                                modelData.country,
                                                modelData.tags,
                                                true
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: stationMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            radioManager.playStation(modelData.url, modelData.name)
                            // Update MediaState
                            if (typeof MediaState !== 'undefined') {
                                MediaState.updateFromRadio(
                                    modelData.name,
                                    modelData.country,
                                    modelData.tags,
                                    true
                                )
                            }
                        }
                    }
                }
            }
        }

        // Empty State
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: theme.r2
            color: theme.bgCard
            border.color: theme.b1
            border.width: 1
            visible: radioManager.stations.length === 0 && !radioManager.loading

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 16

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "📻"
                    font.pixelSize: 60
                    opacity: 0.5
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "No stations loaded"
                    font.pixelSize: 16
                    color: theme.t0
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Search for a genre or click a quick button above"
                    font.pixelSize: 12
                    color: theme.t1
                }
            }
        }
    }
}