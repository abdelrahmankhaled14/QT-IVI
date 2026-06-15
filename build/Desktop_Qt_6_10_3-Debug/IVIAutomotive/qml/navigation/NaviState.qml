pragma Singleton
import QtQuick
import QtPositioning

QtObject {
    id: navState

    // ── Route ────────────────────────────────────────────────────────────────
    property bool   hasActiveRoute: false
    property bool   isNavigating:   false    // driving mode active

    property string fromCity: ""
    property string toCity:   ""
    property var    fromCoordinate: undefined
    property var    toCoordinate:   undefined

    property real   totalDistance: 0         // km
    property int    travelTime:    0         // minutes
    property string eta:           "--:--"
    property real   heading:       0         // degrees
    property var    routePath:     []        // full coordinate array

    // ── Turn-by-turn steps ────────────────────────────────────────────────────
    property var    steps:          []       // [{icon, street, instruction, distanceM}]
    property int    currentStep:    0

    // Current step convenience accessors
    property string nextStreet:      ""
    property int    distanceToTurn:  0
    property string turnIcon:        "↑"

    // ── Set route (called from Navi.qml after route calculation) ────────────
    function setRoute(from, to, fromCoord, toCoord, distance, time, path) {
        fromCity       = from
        toCity         = to
        fromCoordinate = fromCoord
        toCoordinate   = toCoord
        totalDistance  = distance
        travelTime     = time
        routePath      = path
        eta            = calculateETA(time)
        heading        = calculateBearing(fromCoord, toCoord)
        hasActiveRoute = true
        isNavigating   = false   // user must press Start
    }

    // ── Called with the step list extracted from route segments ──────────────
    function setSteps(stepList) {
        steps = stepList
        currentStep = 0
        applyStep(0)
    }

    function startNavigation() {
        if (!hasActiveRoute) return
        isNavigating = true
        currentStep  = 0
        applyStep(0)
    }

    function advanceStep() {
        if (currentStep < steps.length - 1) {
            currentStep++
            applyStep(currentStep)
        }
    }

    function applyStep(idx) {
        if (steps.length === 0) {
            nextStreet     = toCity
            distanceToTurn = Math.round(totalDistance * 1000 * 0.15)
            turnIcon       = "↱"
            return
        }
        var s = steps[idx]
        nextStreet     = s.street      || toCity
        distanceToTurn = s.distanceM   || 0
        turnIcon       = s.icon        || "↑"
    }

    function clearRoute() {
        hasActiveRoute = false
        isNavigating   = false
        fromCity = ""; toCity = ""
        fromCoordinate = undefined; toCoordinate = undefined
        totalDistance  = 0; travelTime = 0
        eta = "--:--"; heading = 0
        routePath = []; steps = []
        currentStep = 0
        nextStreet = ""; distanceToTurn = 0; turnIcon = "↑"
    }

    // ── Helpers ──────────────────────────────────────────────────────────────
    function calculateETA(minutes) {
        var now = new Date()
        now.setMinutes(now.getMinutes() + minutes)
        return Qt.formatTime(now, "hh:mm")
    }

    function calculateBearing(from, to) {
        if (!from || !to) return 0
        var dLon = (to.longitude - from.longitude) * Math.PI / 180
        var lat1 = from.latitude  * Math.PI / 180
        var lat2 = to.latitude    * Math.PI / 180
        var y = Math.sin(dLon) * Math.cos(lat2)
        var x = Math.cos(lat1) * Math.sin(lat2) -
                Math.sin(lat1) * Math.cos(lat2) * Math.cos(dLon)
        return ((Math.atan2(y, x) * 180 / Math.PI) + 360) % 360
    }
}
