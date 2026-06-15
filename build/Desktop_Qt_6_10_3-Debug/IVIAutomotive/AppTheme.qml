import QtQuick 2.15

QtObject {
    id: root

    // ═══════════════════════════════════════════════════════════
    // MODE TOGGLE (Change this to switch themes)
    // ═══════════════════════════════════════════════════════════
    property bool isDark: true

    // ═══════════════════════════════════════════════════════════
    // SURFACES
    // ═══════════════════════════════════════════════════════════
    readonly property color bgVoid:    isDark ? "#030508" : "#EBEBF0" // Absolute background
    readonly property color bgSurface: isDark ? "#070A10" : "#F2F2F7" // Main background
    readonly property color bgCard:    isDark ? "#0B1019" : "#FFFFFF" // Card / tile bg
    readonly property color bgHover:   isDark ? "#0F1822" : "#E5E5EA" // Card on hover
    readonly property color bgDeep:    isDark ? "#050E1A" : "#E1E1E6" // Inset / recessed areas
    readonly property color bgFooter:  isDark ? "#050709" : "#FFFFFF" // Top & bottom bars

    // ═══════════════════════════════════════════════════════════
    // BORDERS (rgba)
    // White with opacity in Dark mode, Black with opacity in Light mode
    // ═══════════════════════════════════════════════════════════
    readonly property color b0: isDark ? Qt.rgba(1, 1, 1, 0.04) : Qt.rgba(0, 0, 0, 0.04) // barely there
    readonly property color b1: isDark ? Qt.rgba(1, 1, 1, 0.09) : Qt.rgba(0, 0, 0, 0.08) // subtle divider
    readonly property color b2: isDark ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(0, 0, 0, 0.15) // visible edge

    // ═══════════════════════════════════════════════════════════
    // TYPOGRAPHY COLORS
    // ═══════════════════════════════════════════════════════════
    readonly property color t0: isDark ? "#EDF2FF" : "#1C1C1E" // primary
    readonly property color t1: isDark ? "#6E8099" : "#55555C" // secondary
    readonly property color t2: isDark ? "#2E3E52" : "#85858E" // ghost / decorative

    // ═══════════════════════════════════════════════════════════
    // PRIMARY ACCENT — Tesla Signature Blue
    // ═══════════════════════════════════════════════════════════
    readonly property color blue:      "#4A9FFF"
    readonly property color blueDim:   Qt.rgba(0.290, 0.623, 1.0, 0.10)
    readonly property color blueBord:  Qt.rgba(0.290, 0.623, 1.0, 0.22)
    readonly property color blueGlow:  Qt.rgba(0.290, 0.623, 1.0, 0.08)

    // ═══════════════════════════════════════════════════════════
    // PER-APP ACCENT COLORS (Brand colors remain identical in Light/Dark)
    // ═══════════════════════════════════════════════════════════
    readonly property color weatherAc:      "#4A9FFF"
    readonly property color weatherGlow:    Qt.rgba(0.290, 0.623, 1.0, 0.12)
    readonly property color weatherBord:    Qt.rgba(0.290, 0.623, 1.0, 0.28)

    readonly property color youtubeAc:      "#FF4545"
    readonly property color youtubeGlow:    Qt.rgba(1.0, 0.270, 0.270, 0.12)
    readonly property color youtubeBord:    Qt.rgba(1.0, 0.270, 0.270, 0.28)

    readonly property color climateAc:      "#00D49A"
    readonly property color climateGlow:    Qt.rgba(0.0, 0.831, 0.604, 0.12)
    readonly property color climateBord:    Qt.rgba(0.0, 0.831, 0.604, 0.28)

    readonly property color settingsAc:     "#A855F7"
    readonly property color settingsGlow:   Qt.rgba(0.659, 0.333, 0.969, 0.12)
    readonly property color settingsBord:   Qt.rgba(0.659, 0.333, 0.969, 0.28)

    readonly property color navigationAc:   "#F59E0B"
    readonly property color navigationGlow: Qt.rgba(0.961, 0.620, 0.043, 0.12)
    readonly property color navigationBord: Qt.rgba(0.961, 0.620, 0.043, 0.28)

    readonly property color spotifyAc:      "#1DB954"
    readonly property color spotifyGlow:    Qt.rgba(0.114, 0.725, 0.329, 0.12)
    readonly property color spotifyBord:    Qt.rgba(0.114, 0.725, 0.329, 0.28)

    readonly property color phoneAc:        "#34C759"
    readonly property color phoneGlow:      Qt.rgba(0.204, 0.780, 0.349, 0.12)
    readonly property color phoneBord:      Qt.rgba(0.204, 0.780, 0.349, 0.28)

    readonly property color vehicleAc:      "#A0AAB2"
    readonly property color vehicleGlow:    Qt.rgba(0.627, 0.667, 0.698, 0.12)
    readonly property color vehicleBord:    Qt.rgba(0.627, 0.667, 0.698, 0.28)

    // ═══════════════════════════════════════════════════════════
    // BORDER RADII
    // ═══════════════════════════════════════════════════════════
    readonly property int r1: 10    // small (chips, pills)
    readonly property int r2: 18    // medium (cards, panels)
    readonly property int r3: 24    // large (main tiles)
    readonly property int rFull: 9999

    // ═══════════════════════════════════════════════════════════
    // TYPOGRAPHY
    // ═══════════════════════════════════════════════════════════
    readonly property string displayFont: "Montserrat, Inter, Segoe UI, sans-serif"
    readonly property string bodyFont:    "Inter, Segoe UI, Roboto, sans-serif"
    readonly property string monoFont:    "JetBrains Mono, Consolas, monospace"

    // ═══════════════════════════════════════════════════════════
    // ANIMATION DURATIONS (ms)
    // ═══════════════════════════════════════════════════════════
    readonly property int fast:   150
    readonly property int normal: 250
    readonly property int slow:   400

    // ═══════════════════════════════════════════════════════════
    // TILE ENTRY STAGGER
    // ═══════════════════════════════════════════════════════════
    readonly property int tileStagger:  75   // ms between each tile
    readonly property int tileDelay:    60   // initial delay before first tile

    // ═══════════════════════════════════════════════════════════
    // LEGACY / EXTRA SETTINGS (Retained exactly as you had them)
    // ═══════════════════════════════════════════════════════════
    property color background:     isDark ? "#1e1e2e" : "#f2f2f7"
    property color surface:        isDark ? "#2a2a3e" : "#ffffff"
    property color sidebarBg:      isDark ? "#16161e" : "#e8e8ed"
    property color sidebarHover:   isDark ? "#2a2a3e" : "#d8d8e0"
    property color sidebarActive:  blue
    property color divider:        b2

    property color textPrimary:    isDark ? "#e8e8f0" : "#1c1c1e"
    property color textSecondary:  isDark ? "#9999bb" : "#6e6e80"
    property color textOnAccent:   "#ffffff"

    property color accent:         blue
    property color accentHover:    "#6FB2FF"
    property color success:        "#34C759"
    property color warning:        navigationAc
    property color danger:         youtubeAc
    property color surfaceVariant: bgHover

    property int radiusSmall:  6
    property int radiusMedium: 10
    property int radiusLarge:  16

    property int spacingSmall:  8
    property int spacingMedium: 16
    property int spacingLarge:  24

    property int fontSizeXSmall:  11
    property int fontSizeSmall:   13
    property int fontSizeBody:    15
    property int fontSizeTitle:   20
    property int fontSizeHeading: 24
    property int fontWeightNormal: Font.Normal
    property int fontWeightMedium: Font.Medium
    property int fontWeightBold:   Font.Bold

    property int sidebarWidth:    240
    property int sidebarItemH:    44

    property int animFast:   120
    property int animNormal: 200
}