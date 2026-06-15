pragma Singleton
import QtQuick

QtObject {
    id: hvacState

    // ══════════════════════════════════════════════════════════════════
    // PERSISTENT HVAC STATE
    // ══════════════════════════════════════════════════════════════════
    property bool systemOn:    false   // Master on/off
    property bool heating:     false   // Only valid when systemOn=true
    property int  temperature: 22
    property int  fanSpeed:    2
    property bool ventsOpen:   true

    // Derived properties
    readonly property string modeText:      !systemOn ? "OFF" : (heating ? "HOT" : "COLD")
    readonly property string modeIcon:      !systemOn ? "⏻" : (heating ? "🔥" : "❄️")
    readonly property string fanSpeedText:  (["Low","Medium","High","Very High","Max"])[fanSpeed - 1] || "Medium"
    readonly property string statusText:    !systemOn ? "System Off" : (heating ? "Heating Active" : "Cooling Active")

    // ══════════════════════════════════════════════════════════════════
    // METHODS
    // ══════════════════════════════════════════════════════════════════
    function toggleSystem() {
        systemOn = !systemOn
        if (!systemOn) {
            heating = false
        }
        console.log("HVACState: System", systemOn ? "ON" : "OFF")
    }

    function setTemperature(temp) {
        if (temp >= 16 && temp <= 30) {
            temperature = temp
        }
    }

    function setFanSpeed(speed) {
        if (speed >= 1 && speed <= 5) {
            fanSpeed = speed
        }
    }

    function toggleHeating() {
        if (!systemOn) {
            systemOn = true  // Auto-enable when changing mode
        }
        heating = !heating
        console.log("HVACState: Mode changed to", heating ? "HEATING" : "COOLING")
    }

    function setMode(mode) {
        // mode: "off", "cold", "hot"
        if (mode === "off") {
            systemOn = false
            heating = false
        } else if (mode === "cold") {
            systemOn = true
            heating = false
        } else if (mode === "hot") {
            systemOn = true
            heating = true
        }
        console.log("HVACState: Mode set to", mode)
    }

    function toggleVents() {
        if (!systemOn) return  // Can't toggle vents when off
        ventsOpen = !ventsOpen
    }
}