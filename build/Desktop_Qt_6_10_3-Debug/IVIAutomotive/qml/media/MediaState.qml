// MediaState.qml
pragma Singleton
import QtQuick

QtObject {
    id: mediaState

    // ══════════════════════════════════════════════════════════════════
    // UNIFIED MEDIA STATE (works with Radio + Audio)
    // ══════════════════════════════════════════════════════════
    property bool isPlaying: false
    property bool isRadioMode: true     // true = radio, false = audio
    property string currentTitle: ""
    property string currentArtist: ""  // For audio: artist, For radio: station + country
    property string statusText: "No media playing"
    property int  volume: 80

    // ══════════════════════════════════════════════════════════
    // METHODS FOR RADIO
    // ══════════════════════════════════════════════════════════════════
    function updateFromRadio(station, country, tags, playing) {
        isRadioMode = true
        isPlaying = playing
        currentTitle = station || "No Station"
        currentArtist = country + (tags ? " • " + tags.split(",")[0] : "")
        statusText = playing ? "Radio: " + station : "Radio Stopped"
        console.log("MediaState: Radio updated -", station, playing ? "playing" : "stopped")
    }

    // ══════════════════════════════════════════════════════════
    // METHODS FOR AUDIO
    // ══════════════════════════════════════════════════════════
    function updateFromAudio(title, artist, playing) {
        isRadioMode = false
        isPlaying = playing
        currentTitle = title || "No Track"
        currentArtist = artist || "Unknown Artist"
        statusText = playing ? title : "Audio Stopped"
        console.log("MediaState: Audio updated -", title, playing ? "playing" : "stopped")
    }

    // ══════════════════════════════════════════════════════════════════
    // PLAYBACK CONTROLS
    // ══════════════════════════════════════════════════════════════════
    function togglePlayPause() {
        isPlaying = !isPlaying
        statusText = isPlaying ? (isRadioMode ? "Radio Playing" : currentTitle) : "Paused"
    }

    function stop() {
        isPlaying = false
        statusText = "Stopped"
    }

    function setVolume(vol) {
        volume = Math.max(0, Math.min(100, vol))
    }
}