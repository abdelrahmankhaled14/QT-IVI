import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: audioPage
    width: SwipeView.view ? SwipeView.view.width : 800
    height: SwipeView.view ? SwipeView.view.height : 600

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#FFF0F5" }
            GradientStop { position: 1.0; color: "#FFE4EC" }
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
            radius: 12
            color: "#FFFFFF"
            border.color: "#FFD6E7"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                Text {
                    text: "🎵"
                    font.pixelSize: 16
                }

                Text {
                    Layout.fillWidth: true
                    text: audioManager.statusMsg
                    font.pixelSize: 12
                    color: "#8B3A62"
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }

                BusyIndicator {
                    width: 20
                    height: 20
                    running: audioManager.loading
                    visible: audioManager.loading
                }
            }
        }

        // Scan Buttons
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Rectangle {
                Layout.fillWidth: true
                height: 46
                radius: 23
                color: mouseAreaUSB.pressed ? "#C01870" : (mouseAreaUSB.containsMouse ? "#D81B7A" : "#E91E8C")

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        text: "💾"
                        font.pixelSize: 16
                    }

                    Text {
                        text: "Scan USB"
                        font.pixelSize: 14
                        font.bold: true
                        color: "white"
                    }
                }

                MouseArea {
                    id: mouseAreaUSB
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: audioManager.scanUSB()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 46
                radius: 23
                color: mouseAreaFolder.pressed ? "#FF8899" : (mouseAreaFolder.containsMouse ? "#FFA0B1" : "#FFB6C1")

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        text: "📂"
                        font.pixelSize: 16
                    }

                    Text {
                        text: "Music Folder"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#8B3A62"
                    }
                }

                MouseArea {
                    id: mouseAreaFolder
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: audioManager.scanFolder(audioManager.defaultMusicPath)
                }
            }
        }

        // Now Playing Card
        Rectangle {
            Layout.fillWidth: true
            height: 160
            radius: 20
            visible: audioManager.currentTitle !== ""

            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#E91E8C" }
                GradientStop { position: 1.0; color: "#FF6B9D" }
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16

                // Album Art
                Rectangle {
                    width: 120
                    height: 120
                    radius: 16
                    color: "#FFFFFF20"

                    Text {
                        anchors.centerIn: parent
                        text: "🎵"
                        font.pixelSize: 45
                    }

                    Row {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottomMargin: 10
                        spacing: 4
                        visible: audioManager.playing

                        Repeater {
                            model: 4
                            Rectangle {
                                width: 6
                                height: 8
                                radius: 3
                                color: "white"

                                SequentialAnimation on height {
                                    loops: Animation.Infinite
                                    running: audioManager.playing
                                    NumberAnimation { to: 18; duration: 200 + index * 50; easing.type: Easing.InOutQuad }
                                    NumberAnimation { to: 6; duration: 200 + index * 50; easing.type: Easing.InOutQuad }
                                }
                            }
                        }
                    }
                }

                // Track Info and Controls
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 6

                    Text {
                        Layout.fillWidth: true
                        text: audioManager.currentTitle
                        font.pixelSize: 17
                        font.bold: true
                        color: "white"
                        elide: Text.ElideRight
                    }

                    Text {
                        text: audioManager.currentArtist
                        font.pixelSize: 13
                        color: "#FFFFFFCC"
                    }

                    Item { Layout.fillHeight: true }

                    // Progress Bar
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Rectangle {
                            Layout.fillWidth: true
                            height: 6
                            radius: 3
                            color: "#FFFFFF40"

                            Rectangle {
                                width: audioManager.duration > 0
                                       ? parent.width * (audioManager.position / (audioManager.duration * 1.0))
                                       : 0
                                height: parent.height
                                radius: 3
                                color: "white"
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: function(mouse) {
                                    var ratio = mouse.x / width
                                    audioManager.seek(ratio * audioManager.duration)
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: formatTime(audioManager.position)
                                font.pixelSize: 10
                                color: "#FFFFFFCC"
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                text: formatTime(audioManager.duration)
                                font.pixelSize: 10
                                color: "#FFFFFFCC"
                            }
                        }
                    }

                    // Playback Controls
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 16

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 20
                            color: prevMouseArea.pressed ? "#FFFFFF60" : (prevMouseArea.containsMouse ? "#FFFFFF40" : "#FFFFFF20")

                            Text {
                                anchors.centerIn: parent
                                text: "⏮"
                                font.pixelSize: 16
                                color: "white"
                            }

                            MouseArea {
                                id: prevMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: audioManager.previous()
                            }
                        }

                        Rectangle {
                            width: 50
                            height: 50
                            radius: 25
                            color: "white"

                            Text {
                                anchors.centerIn: parent
                                text: audioManager.playing ? "⏸" : "▶"
                                font.pixelSize: 22
                                color: "#E91E8C"
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: audioManager.playPause()
                            }
                        }

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 20
                            color: nextMouseArea.pressed ? "#FFFFFF60" : (nextMouseArea.containsMouse ? "#FFFFFF40" : "#FFFFFF20")

                            Text {
                                anchors.centerIn: parent
                                text: "⏭"
                                font.pixelSize: 16
                                color: "white"
                            }

                            MouseArea {
                                id: nextMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: audioManager.next()
                            }
                        }
                    }
                }
            }
        }

        // Volume Control
        Rectangle {
            Layout.fillWidth: true
            height: 56
            radius: 12
            color: "white"
            border.color: "#FFD6E7"
            border.width: 1
            visible: audioManager.playlist.length > 0

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                anchors.topMargin: 8
                anchors.bottomMargin: 8
                spacing: 12

                Text {
                    text: audioManager.volume < 30 ? "🔈" : (audioManager.volume < 70 ? "🔉" : "🔊")
                    font.pixelSize: 20
                    color: "#8B3A62"
                }

                // Custom Volume Slider - FIXED
                Item {
                    Layout.fillWidth: true
                    height: 40

                    Rectangle {
                        id: audioSliderTrack
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        height: 8
                        radius: 4
                        color: "#FFD6E7"

                        Rectangle {
                            width: (audioManager.volume / 100.0) * parent.width
                            height: parent.height
                            radius: 4
                            color: "#E91E8C"
                        }
                    }

                    Rectangle {
                        id: audioSliderHandle
                        width: 24
                        height: 24
                        radius: 12
                        color: audioSliderMouseArea.pressed ? "#E91E8C" : "white"
                        border.color: "#E91E8C"
                        border.width: 3
                        x: (audioManager.volume / 100.0) * (parent.width - width)
                        anchors.verticalCenter: parent.verticalCenter

                        Behavior on color {
                            ColorAnimation { duration: 100 }
                        }
                    }

                    MouseArea {
                        id: audioSliderMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onPressed: function(mouse) {
                            updateVolume(mouse.x)
                        }

                        onPositionChanged: function(mouse) {
                            if (pressed) {
                                updateVolume(mouse.x)
                            }
                        }

                        function updateVolume(mouseX) {
                            var newVolume = Math.round((mouseX / width) * 100)
                            newVolume = Math.max(0, Math.min(100, newVolume))
                            audioManager.setVolume(newVolume)
                        }
                    }
                }

                Rectangle {
                    width: 50
                    height: 28
                    radius: 14
                    color: "#FFE4EE"

                    Text {
                        anchors.centerIn: parent
                        text: audioManager.volume + "%"
                        font.pixelSize: 12
                        font.bold: true
                        color: "#8B3A62"
                    }
                }
            }
        }

        // Playlist Header
        RowLayout {
            Layout.fillWidth: true
            visible: audioManager.playlist.length > 0

            Text {
                text: "🎶 Playlist"
                font.pixelSize: 15
                font.bold: true
                color: "#8B3A62"
            }

            Item { Layout.fillWidth: true }

            Text {
                text: audioManager.playlist.length + " tracks"
                font.pixelSize: 12
                color: "#C06080"
            }
        }

        // Playlist
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 16
            color: "white"
            border.color: "#FFD6E7"
            border.width: 2
            visible: audioManager.playlist.length > 0
            clip: true

            ListView {
                id: trackList
                anchors.fill: parent
                anchors.margins: 8
                model: audioManager.playlist
                spacing: 4
                clip: true

                ScrollBar.vertical: ScrollBar {
                    active: true
                    policy: ScrollBar.AsNeeded
                }

                delegate: Rectangle {
                    width: trackList.width - (trackList.ScrollBar.vertical.visible ? 16 : 8)
                    height: 52
                    radius: 12
                    color: {
                        if (audioManager.currentIndex === index) return "#FFD6E7"
                        if (trackMouseArea.containsMouse) return "#FFF0F5"
                        return "transparent"
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        Rectangle {
                            width: 32
                            height: 32
                            radius: 16
                            color: audioManager.currentIndex === index ? "#E91E8C" : "#FFE4EE"

                            Text {
                                anchors.centerIn: parent
                                text: audioManager.currentIndex === index && audioManager.playing ? "▶" : (index + 1)
                                font.pixelSize: 11
                                font.bold: true
                                color: audioManager.currentIndex === index ? "white" : "#8B3A62"
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                Layout.fillWidth: true
                                text: modelData.title
                                font.pixelSize: 13
                                font.bold: audioManager.currentIndex === index
                                color: "#8B3A62"
                                elide: Text.ElideRight
                            }

                            Text {
                                text: modelData.artist
                                font.pixelSize: 10
                                color: "#C06080"
                            }
                        }

                        Text {
                            text: audioManager.currentIndex === index && audioManager.playing ? "🎵" : ""
                            font.pixelSize: 14
                        }
                    }

                    MouseArea {
                        id: trackMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: audioManager.playTrack(index)
                    }
                }
            }
        }

        // Empty State
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 16
            color: "white"
            border.color: "#FFD6E7"
            border.width: 2
            visible: audioManager.playlist.length === 0

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 16

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "🎵"
                    font.pixelSize: 60
                    opacity: 0.5
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "No music loaded"
                    font.pixelSize: 16
                    color: "#8B3A62"
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Scan USB or select a folder to get started"
                    font.pixelSize: 12
                    color: "#C06080"
                }
            }
        }
    }

    function formatTime(ms) {
        var s = Math.floor(ms / 1000)
        var m = Math.floor(s / 60)
        s = s % 60
        return m + ":" + (s < 10 ? "0" : "") + s
    }
}
