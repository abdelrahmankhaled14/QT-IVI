import QtQuick
import QtQuick.Controls
import QtLocation
import QtPositioning
import "."

Item {
    id: naviRoot

    // ── Map Plugin ────────────────────────────────────────────────────────────
    Plugin {
        id: mapPlugin
        name: "osm"
        PluginParameter { name: "osm.useragent";           value: "IVIAutomotive/1.0" }
        PluginParameter { name: "osm.mapping.custom.host"; value: "https://tile.openstreetmap.org/%z/%x/%y.png" }
    }

    // ── Map ───────────────────────────────────────────────────────────────────
    MapView {
        id: mapView
        anchors.fill: parent
        map.plugin:    mapPlugin
        map.center:    QtPositioning.coordinate(30.0055, 31.4779)
        map.zoomLevel: 12

        MapPolyline {
            id: routeLine
            line.width: 6
            line.color: theme.blue
            path: NaviState.routePath
        }

        MapCircle {
            id: originDot
            center:        NaviState.fromCoordinate ?? QtPositioning.coordinate()
            radius:        14
            color:         "#00C853"
            border.color:  "#ffffff"
            border.width:  3
            opacity:       NaviState.fromCoordinate ? 1.0 : 0.0
        }

        MapCircle {
            id: destDot
            center:        NaviState.toCoordinate ?? QtPositioning.coordinate()
            radius:        16
            color:         "#FF1744"
            border.color:  "#ffffff"
            border.width:  3
            opacity:       NaviState.toCoordinate ? 1.0 : 0.0
        }

        Component.onCompleted: {
            mapView.map.addMapItem(routeLine)
            mapView.map.addMapItem(originDot)
            mapView.map.addMapItem(destDot)
        }
    }

    // ── Models ────────────────────────────────────────────────────────────────
    property bool geocoding: false

    RouteModel {
        id: routeModel
        plugin: mapPlugin
        query:  RouteQuery { id: routeQuery }

        onStatusChanged: {
            if (status === RouteModel.Loading) return
            geocoding = false
            if (status !== RouteModel.Ready || count === 0) return

            var route   = get(0)
            var steps   = []

            for (var i = 0; i < route.segments.length; i++) {
                var seg = route.segments[i]
                var man = seg.maneuver
                if (man && man.valid) {
                    steps.push({
                        icon:        dirIcon(man.direction),
                        street:      pullStreet(man.instructionText),
                        instruction: man.instructionText || "",
                        distanceM:   Math.round(seg.distance)
                    })
                }
            }

            // Fallback: at least one step if OSM returned no segments
            if (steps.length === 0) {
                steps.push({
                    icon: "↑", street: toInput.text,
                    instruction: "Head towards " + toInput.text,
                    distanceM: Math.round(route.distance)
                })
            }

            NaviState.setRoute(
                fromInput.text, toInput.text,
                NaviState.fromCoordinate, NaviState.toCoordinate,
                (route.distance / 1000).toFixed(1),
                Math.round(route.travelTime / 60),
                route.path
            )
            NaviState.setSteps(steps)
            mapView.map.visibleRegion = route.bounds
        }
    }

    GeocodeModel {
        id: fromGeocode
        plugin: mapPlugin
        onStatusChanged: {
            if (status === GeocodeModel.Ready && count > 0) {
                NaviState.fromCoordinate = get(0).coordinate
                if (NaviState.toCoordinate) calcRoute()
            }
            if (status !== GeocodeModel.Loading) geocoding = false
        }
    }

    GeocodeModel {
        id: toGeocode
        plugin: mapPlugin
        onStatusChanged: {
            if (status === GeocodeModel.Ready && count > 0) {
                NaviState.toCoordinate = get(0).coordinate
                if (NaviState.fromCoordinate) calcRoute()
            }
            if (status !== GeocodeModel.Loading) geocoding = false
        }
    }

    function calcRoute() {
        routeQuery.clearWaypoints()
        routeQuery.addWaypoint(NaviState.fromCoordinate)
        routeQuery.addWaypoint(NaviState.toCoordinate)
        routeModel.update()
    }

    function dirIcon(d) {
        switch (d) {
            case 1:  return "↑"
            case 2:  return "↗"
            case 3:  case 4: return "→"
            case 5:  return "⤵"
            case 6:  case 7: return "↩"
            case 8:  return "⤴"
            case 9:  case 10: return "←"
            case 11: return "↖"
            default: return "↑"
        }
    }

    function pullStreet(text) {
        if (!text) return ""
        var m = text.match(/onto (.+)$/i) || text.match(/on (.+)$/i)
        return m ? m[1] : text
    }

    function fmtDist(m) {
        return m >= 1000 ? (m / 1000).toFixed(1) + " km" : m + " m"
    }

    // ══════════════════════════════════════════════════════════════════════════
    // TOP OVERLAY — Home + Search (hidden when navigating)
    // ══════════════════════════════════════════════════════════════════════════
    Rectangle {
        id: topOverlay
        anchors.top:              parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin:        14
        width:  380
        height: topCol.implicitHeight + 20
        radius: 14
        color:  "#E50d1f2e"
        visible: !NaviState.isNavigating
        z: 30

        Column {
            id: topCol
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 10 }
            spacing: 8

            // ── Row: back button ────────────────────────────────────────────
            Row {
                spacing: 8; width: parent.width

                Rectangle {
                    width: 90; height: 34; radius: 9
                    color: backHov.containsMouse ? theme.bgHover : theme.bgCard
                    border.color: theme.blue; border.width: 1
                    Behavior on color { ColorAnimation { duration: 140 } }

                    Text {
                        anchors.centerIn: parent; text: "← Home"
                        font.pixelSize: 13; font.family: theme.displayFont
                        color: theme.blue
                    }
                    MouseArea {
                        id: backHov; anchors.fill: parent; hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (naviRoot.StackView.view) naviRoot.StackView.view.pop()
                    }
                }

                // Status chip
                Rectangle {
                    height: 34; radius: 9
                    width: statusChipText.implicitWidth + 20
                    color: NaviState.hasActiveRoute ? "#0D2E0D" : "transparent"
                    border.color: NaviState.hasActiveRoute ? "#00C853" : "transparent"
                    border.width: 1
                    visible: NaviState.hasActiveRoute || geocoding

                    Text {
                        id: statusChipText
                        anchors.centerIn: parent
                        text: geocoding ? "Calculating…" : (NaviState.totalDistance + " km  ·  " + NaviState.travelTime + " min")
                        font.pixelSize: 12; font.family: theme.displayFont
                        color: geocoding ? theme.t1 : "#00C853"
                    }
                }
            }

            // ── FROM ───────────────────────────────────────────────────────
            Rectangle {
                width: parent.width; height: 40; radius: 9
                color: theme.bgDeep; border.color: theme.blue; border.width: 1

                Row {
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 12 }
                    spacing: 8
                    Rectangle { width: 8; height: 8; radius: 4; color: "#00C853"; anchors.verticalCenter: parent.verticalCenter }
                    TextField {
                        id: fromInput
                        width: topOverlay.width - 52; height: parent.parent.height
                        color: theme.t0; font.pixelSize: 13; font.family: theme.displayFont
                        placeholderText: "From  (e.g. Cairo, Egypt)"
                        placeholderTextColor: theme.t1
                        background: Item {}
                        text: NaviState.fromCity
                        onAccepted: {
                            geocoding = true
                            fromGeocode.query = text
                            fromGeocode.update()
                            focus = false
                        }
                    }
                }
            }

            // ── TO ─────────────────────────────────────────────────────────
            Rectangle {
                width: parent.width; height: 40; radius: 9
                color: theme.bgDeep; border.color: "#FF1744"; border.width: 1

                Row {
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 12 }
                    spacing: 8
                    Rectangle { width: 8; height: 8; radius: 4; color: "#FF1744"; anchors.verticalCenter: parent.verticalCenter }
                    TextField {
                        id: toInput
                        width: topOverlay.width - 52; height: parent.parent.height
                        color: theme.t0; font.pixelSize: 13; font.family: theme.displayFont
                        placeholderText: "To  (e.g. Giza, Egypt)"
                        placeholderTextColor: theme.t1
                        background: Item {}
                        text: NaviState.toCity
                        onAccepted: {
                            geocoding = true
                            toGeocode.query = text
                            toGeocode.update()
                            focus = false
                        }
                    }
                }
            }
        }
    }

    // ══════════════════════════════════════════════════════════════════════════
    // DRIVING HUD — top strip (shown when navigating)
    // ══════════════════════════════════════════════════════════════════════════
    Rectangle {
        id: drivingHUD
        anchors.top:   parent.top
        anchors.left:  parent.left
        anchors.right: parent.right
        height: 96
        color:  "#F00d1f2e"
        visible: NaviState.isNavigating
        z: 30

        Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 2; color: theme.blue; opacity: 0.5 }

        Row {
            anchors { fill: parent; leftMargin: 16; rightMargin: 16; topMargin: 12; bottomMargin: 12 }
            spacing: 14

            // Direction arrow box
            Rectangle {
                width: 68; height: 68; radius: 16; anchors.verticalCenter: parent.verticalCenter
                color: Qt.rgba(theme.blue.r, theme.blue.g, theme.blue.b, 0.10); border.color: theme.blue; border.width: 1.5

                Text {
                    anchors.centerIn: parent; text: NaviState.turnIcon
                    font.pixelSize: 36; color: "#ffffff"
                }
            }

            // Street + distance
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 5
                width: parent.width - 68 - 150 - 28

                Text {
                    text: fmtDist(NaviState.distanceToTurn)
                    font.pixelSize: 14; font.family: theme.displayFont; font.letterSpacing: 0.5
                    color: theme.blue
                }
                Text {
                    text: NaviState.nextStreet
                    font.pixelSize: 22; font.weight: Font.DemiBold; font.family: theme.displayFont
                    color: theme.t0; elide: Text.ElideRight; width: parent.width
                }
                Text {
                    visible: NaviState.steps.length > 1
                    text: "Step " + (NaviState.currentStep + 1) + " / " + NaviState.steps.length
                    font.pixelSize: 10; font.family: theme.displayFont; color: theme.t1
                }
            }

            // Right side: next / stop
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6; width: 140

                Rectangle {
                    width: 140; height: 30; radius: 15
                    visible: NaviState.currentStep < NaviState.steps.length - 1
                    color: nextBtn.containsMouse ? theme.blue : Qt.rgba(theme.blue.r, theme.blue.g, theme.blue.b, 0.10)
                    border.color: theme.blue; border.width: 1
                    Behavior on color { ColorAnimation { duration: 130 } }
                    Text {
                        anchors.centerIn: parent; text: "Next turn  ›"
                        font.pixelSize: 12; font.family: theme.displayFont; color: "#ffffff"
                    }
                    MouseArea { id: nextBtn; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: NaviState.advanceStep() }
                }

                Rectangle {
                    width: 140; height: 30; radius: 15
                    color: stopBtn.containsMouse ? "#C62828" : "#1AC62828"
                    border.color: "#EF5350"; border.width: 1
                    Behavior on color { ColorAnimation { duration: 130 } }
                    Text {
                        anchors.centerIn: parent; text: "■  Stop Nav"
                        font.pixelSize: 12; font.family: theme.displayFont; color: "#EF9A9A"
                    }
                    MouseArea { id: stopBtn; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: NaviState.isNavigating = false }
                }
            }
        }
    }

    // ══════════════════════════════════════════════════════════════════════════
    // STEPS PANEL — right side (only when navigating)
    // ══════════════════════════════════════════════════════════════════════════
    Rectangle {
        id: stepsPanel
        anchors.right:       parent.right
        anchors.top:         drivingHUD.bottom
        anchors.bottom:      routeBar.top
        anchors.topMargin:   10
        anchors.rightMargin: 10
        anchors.bottomMargin: 10
        width: 250
        radius: 14
        color:  "#E00d1f2e"
        border.color: theme.b2; border.width: 1
        visible: NaviState.isNavigating && NaviState.steps.length > 0
        clip: true
        z: 20

        Text {
            id: stepsTitle
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 12 }
            text: "TURNS"
            font.pixelSize: 9; font.family: theme.displayFont; font.letterSpacing: 3
            color: theme.t1
        }

        ListView {
            anchors { top: stepsTitle.bottom; left: parent.left; right: parent.right; bottom: parent.bottom; margins: 8; topMargin: 4 }
            clip: true
            model: NaviState.steps

            delegate: Item {
                width: parent ? parent.width : 0
                height: 50

                Rectangle {
                    anchors { fill: parent; margins: 2 }
                    radius: 10
                    color:  NaviState.currentStep === index ? Qt.rgba(theme.blue.r, theme.blue.g, theme.blue.b, 0.10) : "transparent"
                    border.color: NaviState.currentStep === index ? theme.blue : "transparent"
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 180 } }
                }

                Row {
                    anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: 10; rightMargin: 6 }
                    spacing: 10

                    Text {
                        text: modelData.icon; font.pixelSize: 20
                        color: NaviState.currentStep === index ? theme.blue : theme.t2
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on color { ColorAnimation { duration: 180 } }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 34; spacing: 2

                        Text {
                            width: parent.width
                            text: modelData.street || modelData.instruction
                            font.pixelSize: 11; font.family: theme.displayFont; font.weight: Font.Medium
                            color: NaviState.currentStep === index ? theme.t0 : theme.t1
                            elide: Text.ElideRight
                            Behavior on color { ColorAnimation { duration: 180 } }
                        }
                        Text {
                            text: fmtDist(modelData.distanceM)
                            font.pixelSize: 10; font.family: theme.displayFont
                            color: NaviState.currentStep === index ? theme.blue : theme.t2
                            Behavior on color { ColorAnimation { duration: 180 } }
                        }
                    }
                }
            }
        }
    }

    // ══════════════════════════════════════════════════════════════════════════
    // ROUTE BAR — bottom (route info + start/clear)
    // ══════════════════════════════════════════════════════════════════════════
    Rectangle {
        id: routeBar
        anchors.bottom: parent.bottom
        anchors.left:   parent.left
        anchors.right:  parent.right
        height:  NaviState.hasActiveRoute ? 78 : 0
        visible: NaviState.hasActiveRoute
        color:   "#F00d1f2e"
        z: 20

        Behavior on height { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        Rectangle { anchors.top: parent.top; width: parent.width; height: 1; color: theme.b2 }

        Row {
            anchors.centerIn: parent; spacing: 18

            // Distance
            Column {
                spacing: 2; anchors.verticalCenter: parent.verticalCenter
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: "DISTANCE"; font.pixelSize: 8; font.family: theme.displayFont; font.letterSpacing: 2; color: theme.t1 }
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: NaviState.totalDistance + " km"; font.pixelSize: 22; font.weight: Font.Bold; font.family: theme.displayFont; color: theme.blue }
            }

            Rectangle { width: 1; height: 40; color: theme.b2; anchors.verticalCenter: parent.verticalCenter }

            // Time
            Column {
                spacing: 2; anchors.verticalCenter: parent.verticalCenter
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: "TIME"; font.pixelSize: 8; font.family: theme.displayFont; font.letterSpacing: 2; color: theme.t1 }
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: NaviState.travelTime + " min"; font.pixelSize: 22; font.weight: Font.Bold; font.family: theme.displayFont; color: theme.blue }
            }

            Rectangle { width: 1; height: 40; color: theme.b2; anchors.verticalCenter: parent.verticalCenter }

            // ETA
            Column {
                spacing: 2; anchors.verticalCenter: parent.verticalCenter
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: "ETA"; font.pixelSize: 8; font.family: theme.displayFont; font.letterSpacing: 2; color: theme.t1 }
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: NaviState.eta; font.pixelSize: 22; font.weight: Font.Bold; font.family: theme.displayFont; color: "#00E676" }
            }

            Rectangle { width: 1; height: 40; color: theme.b2; anchors.verticalCenter: parent.verticalCenter }

            // Start / Stop button
            Rectangle {
                width: 130; height: 46; radius: 23; anchors.verticalCenter: parent.verticalCenter
                color: NaviState.isNavigating
                       ? (startHov.containsMouse ? "#C62828" : "#B71C1C")
                       : (startHov.containsMouse ? "#1565C0" : theme.blue)
                Behavior on color { ColorAnimation { duration: 130 } }

                Row {
                    anchors.centerIn: parent; spacing: 7
                    Text { text: NaviState.isNavigating ? "■" : "▶"; font.pixelSize: 12; color: "#ffffff"; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: NaviState.isNavigating ? "Stop" : "Start"; font.pixelSize: 14; font.weight: Font.DemiBold; font.family: theme.displayFont; color: "#ffffff"; anchors.verticalCenter: parent.verticalCenter }
                }
                MouseArea { id: startHov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: { if (NaviState.isNavigating) NaviState.isNavigating = false; else NaviState.startNavigation() }
                }
            }

            // Clear button
            Rectangle {
                width: 38; height: 38; radius: 19; anchors.verticalCenter: parent.verticalCenter
                color: clearHov.containsMouse ? "#3a1515" : "transparent"
                border.color: "#3A2020"; border.width: 1
                Behavior on color { ColorAnimation { duration: 130 } }
                Text { anchors.centerIn: parent; text: "✕"; font.pixelSize: 15; color: "#7A3535" }
                MouseArea { id: clearHov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: { NaviState.clearRoute(); fromInput.text = ""; toInput.text = ""; routeQuery.clearWaypoints() }
                }
            }
        }
    }

    // ── Home button when navigating ───────────────────────────────────────────
    Rectangle {
        anchors.top: parent.top; anchors.left: parent.left
        anchors.topMargin: 10; anchors.leftMargin: 10
        width: 90; height: 32; radius: 9
        color:  navHomeHov.containsMouse ? theme.bgHover : "#CC0d1f2e"
        border.color: theme.blue; border.width: 1
        visible: NaviState.isNavigating
        z: 31
        Behavior on color { ColorAnimation { duration: 130 } }
        Text { anchors.centerIn: parent; text: "← Home"; font.pixelSize: 12; font.family: theme.displayFont; color: theme.blue }
        MouseArea { id: navHomeHov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
            onClicked: { NaviState.isNavigating = false; if (naviRoot.StackView.view) naviRoot.StackView.view.pop() }
        }
    }
}
