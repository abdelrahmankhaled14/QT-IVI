// qml/weather/MainScreen.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: mainRoot
    color: theme.bgSurface

    function getWeatherIcon(condition) {
        var c = condition.toLowerCase()
        if (c.includes("thunder") || c.includes("storm"))
            return "qrc:/assets/storm.png"
        if (c.includes("snow") || c.includes("sleet") || c.includes("blizzard"))
            return "qrc:/assets/snowy.png"
        if (c.includes("rain") || c.includes("drizzle") || c.includes("shower"))
            return "qrc:/assets/rainy-day.png"
        if (c.includes("cloud") || c.includes("overcast") || c.includes("fog"))
            return "qrc:/assets/cloud(1).png"
        if (c.includes("wind") || c.includes("breeze"))
            return "qrc:/assets/windy.png"
        if (c.includes("clear") || c.includes("sunny"))
            return "qrc:/assets/sun.png"
        return "qrc:/assets/sun.png"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // ═══════════════════════════════════════
        //  TOP BAR
        // ═══════════════════════════════════════
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            spacing: 12

            Image {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                source: getWeatherIcon(weatherVM.condition)
                fillMode: Image.PreserveAspectFit
                smooth: true
            }

            Text {
                text: "Weather"
                font.pixelSize: 20
                font.bold: true
                font.family: theme.displayFont
                color: theme.t0
            }

            // Search bar
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                radius: theme.rFull
                color: theme.bgDeep
                border.color: searchInput.activeFocus
                              ? theme.weatherAc
                              : theme.weatherBord
                border.width: 1

                Behavior on border.color {
                    ColorAnimation { duration: theme.fast }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 8
                    spacing: 6

                    Text {
                        text: "⌕"
                        font.pixelSize: 16
                        color: theme.t1
                    }

                    TextField {
                        id: searchInput
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        placeholderText: "City name..."
                        placeholderTextColor: theme.t2
                        color: theme.t0
                        font.pixelSize: 13
                        font.family: theme.displayFont
                        verticalAlignment: Text.AlignVCenter
                        background: Rectangle { color: "transparent" }

                        onAccepted: {
                            if (text.trim().length > 0)
                                weatherVM.fetchWeather(text.trim())/*INVOKABLE*/
                        }
                    }

                    // Search go button
                    Rectangle {
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        radius: theme.rFull
                        color: searchBtnArea.containsMouse
                               ? theme.weatherAc
                               : theme.weatherGlow
                        border.color: theme.weatherBord
                        border.width: 1

                        Behavior on color {
                            ColorAnimation { duration: theme.fast }
                        }

                        Text {
                            text: "→"
                            font.pixelSize: 15
                            color: theme.t0
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            id: searchBtnArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (searchInput.text.trim().length > 0)
                                    weatherVM.fetchWeather(searchInput.text.trim())/*INVOKABLE*/
                            }
                        }
                    }
                }
            }

            // Refresh button
            Rectangle {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                radius: theme.rFull
                color: refreshArea.containsMouse
                       ? theme.weatherGlow
                       : theme.bgDeep
                border.color: theme.weatherBord
                border.width: 1

                Behavior on color {
                    ColorAnimation { duration: theme.fast }
                }

                Image {
                    anchors.centerIn: parent
                    width: 20
                    height: 20
                    source: "qrc:/assets/refresh.png"
                    fillMode: Image.PreserveAspectFit
                    smooth: true

                    RotationAnimation on rotation {
                        from: 0
                        to: 360
                        duration: 1000
                        loops: Animation.Infinite
                        running: weatherVM.isLoading
                    }
                }

                MouseArea {
                    id: refreshArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: weatherVM.refresh()/*INVOKABLE*/
                }
            }
        }

        // ═══════════════════════════════════════
        //  LOADING STATE
        // ═══════════════════════════════════════
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: weatherVM.isLoading

            Column {
                anchors.centerIn: parent
                spacing: 12

                BusyIndicator {
                    width: 50
                    height: 50
                    running: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: "Loading..."
                    color: theme.t1
                    font.pixelSize: 14
                    font.family: theme.displayFont
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }

        // ═══════════════════════════════════════
        //  ERROR STATE
        // ═══════════════════════════════════════
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: weatherVM.appState === 3

            Column {
                anchors.centerIn: parent
                spacing: 12
                width: parent.width * 0.8

                Image {
                    width: 80
                    height: 80
                    source: "qrc:/assets/storm.png"
                    fillMode: Image.PreserveAspectFit
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: "Error"
                    font.pixelSize: 18
                    font.bold: true
                    font.family: theme.displayFont
                    color: theme.youtubeAc
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: weatherVM.errorMessage
                    font.pixelSize: 12
                    font.family: theme.displayFont
                    color: theme.t1
                    wrapMode: Text.WordWrap
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                }

                // Retry button
                Rectangle {
                    width: 100
                    height: 32
                    radius: theme.rFull
                    color: theme.youtubeAc
                    border.color: theme.youtubeBord
                    border.width: 1
                    anchors.horizontalCenter: parent.horizontalCenter

                    Behavior on color {
                        ColorAnimation { duration: theme.fast }
                    }

                    Text {
                        text: "Retry"
                        font.pixelSize: 12
                        font.family: theme.displayFont
                        color: theme.t0
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        id: retryArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: weatherVM.refresh()
                    }
                }
            }
        }

        // ═══════════════════════════════════════
        //  SUCCESS STATE
        // ═══════════════════════════════════════
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: weatherVM.appState === 2

            RowLayout {
                anchors.fill: parent
                spacing: 16

                // ── Left — Main Weather ───────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width * 0.45
                    radius: theme.r2
                    color: theme.bgCard
                    border.color: theme.weatherBord
                    border.width: 1

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            text: weatherVM.cityName
                            font.pixelSize: 18
                            font.bold: true
                            font.family: theme.displayFont
                            color: theme.t0
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Image {
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: 100
                            Layout.alignment: Qt.AlignHCenter
                            source: getWeatherIcon(weatherVM.condition)
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                        }

                        Text {
                            text: Math.round(weatherVM.temperature) + "°C"
                            font.pixelSize: 42
                            font.bold: true
                            font.family: theme.displayFont
                            color: theme.t0
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Text {
                            text: weatherVM.description
                            font.pixelSize: 13
                            font.family: theme.displayFont
                            color: theme.t1
                            font.capitalization: Font.Capitalize
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Text {
                            text: "Feels like " + Math.round(weatherVM.feelsLike) + "°C"
                            font.pixelSize: 12
                            font.family: theme.displayFont
                            color: theme.t1
                            Layout.alignment: Qt.AlignHCenter
                        }

                        // Min / Max row
                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 20

                            Row {
                                spacing: 4
                                Text {
                                    text: "❄"
                                    font.pixelSize: 14
                                    color: theme.weatherAc
                                }
                                Text {
                                    text: Math.round(weatherVM.tempMin) + "°C"
                                    font.pixelSize: 13
                                    font.family: theme.displayFont
                                    color: theme.weatherAc
                                    font.bold: true
                                }
                            }

                            Row {
                                spacing: 4
                                Text {
                                    text: "🔥"
                                    font.pixelSize: 14
                                    color: theme.youtubeAc
                                }
                                Text {
                                    text: Math.round(weatherVM.tempMax) + "°C"
                                    font.pixelSize: 13
                                    font.family: theme.displayFont
                                    color: theme.youtubeAc
                                    font.bold: true
                                }
                            }
                        }
                    }
                }

                // ── Right — Detail Cards ──────────────────────
                GridLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width * 0.55
                    columns: 2
                    rowSpacing: 12
                    columnSpacing: 12

                    DetailCard {
                        iconSource: getWeatherIcon(weatherVM.condition)
                        label: "Condition"
                        value: weatherVM.condition
                    }
                    DetailCard {
                        iconSource: "qrc:/assets/humidity.png"
                        label: "Humidity"
                        value: weatherVM.humidity + "%"
                    }
                    DetailCard {
                        iconSource: "qrc:/assets/windy.png"
                        label: "Wind"
                        value: weatherVM.windSpeed.toFixed(1) + " m/s"
                    }
                    DetailCard {
                        iconSource: "qrc:/assets/temperature.png"
                        label: "Pressure"
                        value: weatherVM.pressure + " hPa"
                    }
                }
            }
        }


    }
}