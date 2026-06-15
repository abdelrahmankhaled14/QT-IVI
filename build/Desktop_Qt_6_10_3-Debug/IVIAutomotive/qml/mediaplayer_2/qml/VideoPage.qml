import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia

Item {
    id: videoPage
    width: SwipeView.view ? SwipeView.view.width : 800
    height: SwipeView.view ? SwipeView.view.height : 600

    Component.onCompleted: {
        videoManager.player.videoOutput = videoOutput
    }

    Connections {
        target: videoManager.player
        function onSourceChanged() {
            videoManager.player.videoOutput = videoOutput
        }
    }

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
        spacing: 10

        // Status Bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            radius: 12
            color: "white"
            border.color: "#FFD6E7"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 10

                Text {
                    text: "🎬"
                    font.pixelSize: 18
                }

                Text {
                    Layout.fillWidth: true
                    text: videoManager.statusMsg
                    font.pixelSize: 12
                    color: "#8B3A62"
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }

                BusyIndicator {
                    width: 24
                    height: 24
                    running: videoManager.loading
                    visible: videoManager.loading
                }
            }
        }

        // Scan Buttons
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            spacing: 12

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                radius: 22
                color: usbMouse.pressed ? "#C01870" : (usbMouse.containsMouse ? "#D81B7A" : "#E91E8C")

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
                    id: usbMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: videoManager.scanUSB()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                radius: 22
                color: folderMouse.pressed ? "#FF8899" : (folderMouse.containsMouse ? "#FFA0B1" : "#FFB6C1")

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        text: "📂"
                        font.pixelSize: 16
                    }

                    Text {
                        text: "Video Folder"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#8B3A62"
                    }
                }

                MouseArea {
                    id: folderMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: videoManager.scanFolder(videoManager.defaultVideoPath)
                }
            }
        }

        // Video Player
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 220
            radius: 16
            color: "black"
            clip: true

            VideoOutput {
                id: videoOutput
                anchors.fill: parent
                fillMode: VideoOutput.PreserveAspectFit
            }

            // Empty state
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 8
                visible: videoManager.currentTitle === ""

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "🎬"
                    font.pixelSize: 48
                    opacity: 0.5
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "No video loaded"
                    font.pixelSize: 13
                    color: "#888888"
                }
            }

            // Play overlay
            Rectangle {
                anchors.centerIn: parent
                width: 64
                height: 64
                radius: 32
                color: "#00000088"
                visible: videoManager.currentTitle !== "" && !videoManager.playing && !videoManager.loading

                Text {
                    anchors.centerIn: parent
                    text: "▶"
                    font.pixelSize: 28
                    color: "white"
                }
            }

            BusyIndicator {
                anchors.centerIn: parent
                width: 48
                height: 48
                running: videoManager.loading && videoManager.currentTitle !== ""
                visible: running
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (videoManager.currentTitle !== "") {
                        videoManager.playPause()
                    }
                }
            }
        }

        // Controls Panel
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 130
            radius: 16
            color: "#FFB6C1"
            visible: videoManager.currentTitle !== ""

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                // Title
                Text {
                    Layout.fillWidth: true
                    text: videoManager.currentTitle
                    font.pixelSize: 14
                    font.bold: true
                    color: "#8B3A62"
                    elide: Text.ElideRight
                }

                // Progress bar
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 8
                    radius: 4
                    color: "#FFD6E7"

                    Rectangle {
                        width: videoManager.duration > 0
                               ? parent.width * (videoManager.position / (videoManager.duration * 1.0))
                               : 0
                        height: parent.height
                        radius: 4
                        color: "#E91E8C"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: function(mouse) {
                            if (videoManager.duration > 0) {
                                var ratio = mouse.x / width
                                videoManager.seek(ratio * videoManager.duration)
                            }
                        }
                    }
                }

                // Time display
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: formatTime(videoManager.position)
                        font.pixelSize: 11
                        color: "#8B3A62"
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: formatTime(videoManager.duration)
                        font.pixelSize: 11
                        color: "#8B3A62"
                    }
                }

                // Playback controls
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 52
                    spacing: 12

                    Item { Layout.fillWidth: true }

                    // Previous
                    Rectangle {
                        width: 42
                        height: 42
                        radius: 21
                        color: prevMouse.pressed ? "#E91E8C" : (prevMouse.containsMouse ? "#FFFFFF" : "#FFFFFF99")

                        Text {
                            anchors.centerIn: parent
                            text: "⏮"
                            font.pixelSize: 18
                            color: "#8B3A62"
                        }

                        MouseArea {
                            id: prevMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: videoManager.previous()
                        }
                    }

                    // Play/Pause
                    Rectangle {
                        width: 52
                        height: 52
                        radius: 26
                        color: "#E91E8C"

                        Text {
                            anchors.centerIn: parent
                            text: videoManager.playing ? "⏸" : "▶"
                            font.pixelSize: 24
                            color: "white"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: videoManager.playPause()
                        }
                    }

                    // Next
                    Rectangle {
                        width: 42
                        height: 42
                        radius: 21
                        color: nextMouse.pressed ? "#E91E8C" : (nextMouse.containsMouse ? "#FFFFFF" : "#FFFFFF99")

                        Text {
                            anchors.centerIn: parent
                            text: "⏭"
                            font.pixelSize: 18
                            color: "#8B3A62"
                        }

                        MouseArea {
                            id: nextMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: videoManager.next()
                        }
                    }

                    // Spacer
                    Item { width: 16 }

                    // Volume icon
                    Text {
                        text: videoManager.volume < 30 ? "🔈" : (videoManager.volume < 70 ? "🔉" : "🔊")
                        font.pixelSize: 18
                    }

                    // Volume slider container
                    Rectangle {
                        width: 100
                        height: 42
                        color: "transparent"

                        Rectangle {
                            id: videoVolTrack
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width
                            height: 6
                            radius: 3
                            color: "#FFFFFF80"

                            Rectangle {
                                width: parent.width * (videoManager.volume / 100.0)
                                height: parent.height
                                radius: 3
                                color: "#8B3A62"
                            }
                        }

                        Rectangle {
                            id: videoVolHandle
                            width: 20
                            height: 20
                            radius: 10
                            color: videoVolMouse.pressed ? "#8B3A62" : "white"
                            border.color: "#8B3A62"
                            border.width: 2
                            anchors.verticalCenter: parent.verticalCenter
                            x: (parent.width - width) * (videoManager.volume / 100.0)
                        }

                        MouseArea {
                            id: videoVolMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            onPressed: function(mouse) {
                                updateVol(mouse.x)
                            }

                            onPositionChanged: function(mouse) {
                                if (pressed) {
                                    updateVol(mouse.x)
                                }
                            }

                            function updateVol(mx) {
                                var newVol = Math.round((mx / width) * 100)
                                newVol = Math.max(0, Math.min(100, newVol))
                                videoManager.setVolume(newVol)
                            }
                        }
                    }

                    // Volume text
                    Text {
                        text: videoManager.volume + "%"
                        font.pixelSize: 11
                        font.bold: true
                        color: "#8B3A62"
                        Layout.preferredWidth: 36
                    }

                    Item { Layout.fillWidth: true }
                }
            }
        }

        // Playlist header
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 24
            visible: videoManager.playlist.length > 0

            Text {
                text: "🎬 Playlist"
                font.pixelSize: 14
                font.bold: true
                color: "#8B3A62"
            }

            Item { Layout.fillWidth: true }

            Text {
                text: videoManager.playlist.length + " videos"
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
            visible: videoManager.playlist.length > 0
            clip: true

            ListView {
                id: videoList
                anchors.fill: parent
                anchors.margins: 8
                model: videoManager.playlist
                spacing: 6
                clip: true

                ScrollBar.vertical: ScrollBar {
                    active: true
                    policy: ScrollBar.AsNeeded
                }

                delegate: Rectangle {
                    id: delegateItem
                    width: ListView.view.width - 16
                    height: 54
                    radius: 12
                    color: {
                        if (videoManager.currentIndex === index) return "#FFD6E7"
                        if (delegateMouseArea.containsMouse) return "#FFF5F8"
                        return "transparent"
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 12

                        // Thumbnail
                        Rectangle {
                            Layout.preferredWidth: 48
                            Layout.preferredHeight: 34
                            radius: 6
                            color: videoManager.currentIndex === index ? "#E91E8C" : "#FFE4EE"

                            Text {
                                anchors.centerIn: parent
                                text: videoManager.currentIndex === index && videoManager.playing ? "▶" : "🎬"
                                font.pixelSize: videoManager.currentIndex === index && videoManager.playing ? 14 : 16
                                color: videoManager.currentIndex === index ? "white" : "#8B3A62"
                            }
                        }

                        // Info
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                Layout.fillWidth: true
                                text: modelData.title
                                font.pixelSize: 13
                                font.bold: videoManager.currentIndex === index
                                color: "#8B3A62"
                                elide: Text.ElideRight
                            }

                            Text {
                                text: "Video " + (index + 1)
                                font.pixelSize: 10
                                color: "#C06080"
                            }
                        }

                        // Play button
                        Rectangle {
                            Layout.preferredWidth: 34
                            Layout.preferredHeight: 34
                            radius: 17
                            color: delegatePlayMouse.containsMouse ? "#E91E8C" : "#FFD6E7"
                            visible: delegateMouseArea.containsMouse || videoManager.currentIndex === index

                            Text {
                                anchors.centerIn: parent
                                text: videoManager.currentIndex === index && videoManager.playing ? "⏸" : "▶"
                                font.pixelSize: 13
                                color: delegatePlayMouse.containsMouse ? "white" : "#E91E8C"
                            }

                            MouseArea {
                                id: delegatePlayMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (videoManager.currentIndex === index && videoManager.playing) {
                                        videoManager.playPause()
                                    } else {
                                        videoManager.playVideo(index)
                                    }
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: delegateMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: videoManager.playVideo(index)
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
            visible: videoManager.playlist.length === 0

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 12

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "🎬"
                    font.pixelSize: 56
                    opacity: 0.5
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "No videos loaded"
                    font.pixelSize: 15
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
        var totalSec = Math.floor(ms / 1000)
        var hrs = Math.floor(totalSec / 3600)
        var mins = Math.floor((totalSec % 3600) / 60)
        var secs = totalSec % 60

        if (hrs > 0) {
            return hrs + ":" + (mins < 10 ? "0" : "") + mins + ":" + (secs < 10 ? "0" : "") + secs
        }
        return mins + ":" + (secs < 10 ? "0" : "") + secs
    }
}
