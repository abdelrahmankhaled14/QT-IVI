import QtQuick
import QtQuick.Controls
import QtWebEngine

Item {
    id: mediaPlayerRoot
    signal closeApp()

    // Create a persistent profile that saves login cookies
    WebEngineProfile {
        id: soundcloudProfile
        storageName: "SoundCloudSession"
        offTheRecord: false
        persistentCookiesPolicy: WebEngineProfile.ForcePersistentCookies

        // Use a realistic browser user agent
        httpUserAgent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    }

    // Top bar
    Rectangle {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 48
        color: "#050a12"
        z: 10

        Rectangle {
            id: backBtn
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            width: 130; height: 34
            radius: 8
            color: backMouse.containsMouse ? "#1e4060" : "#0a1420"
            border.color: "#00aaff"
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "← Home"
                font.family: "monospace"
                font.pixelSize: 13
                font.letterSpacing: 1
                color: "#00aaff"
            }

            MouseArea {
                id: backMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: mediaPlayerRoot.closeApp()
            }
        }

        Text {
            anchors.centerIn: parent
            text: popupView.visible ? "SOUNDCLOUD - LOGIN" : "SOUNDCLOUD"
            font.family: "monospace"
            font.pixelSize: 13
            font.letterSpacing: 4
            color: "#2a5070"
        }
    }

    // Main SoundCloud View
    WebEngineView {
        id: mainView
        anchors.top: topBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        visible: !popupView.visible

    url: "https://music.youtube.com"
        profile: soundcloudProfile

        // Enable all features needed for login
        settings.pluginsEnabled: true
        settings.javascriptEnabled: true
        settings.localStorageEnabled: true
        settings.javascriptCanOpenWindows: true          // CRITICAL for login popups
        settings.allowWindowActivationFromJavaScript: true
        settings.localContentCanAccessRemoteUrls: true
        settings.playbackRequiresUserGesture: false

        // Handle popup windows (like Google/Facebook login)
        onNewWindowRequested: function(request) {
            console.log("Popup window requested:", request.requestedUrl)

            // Load the popup URL in the popup view
            popupView.url = request.requestedUrl
            popupView.visible = true

            // Accept the request but don't actually create a new window
            request.openIn(popupView)
        }

        onLoadingChanged: function(loadRequest) {
            if (loadRequest.status === WebEngineView.LoadSucceededStatus) {
                console.log("Main view loaded:", loadRequest.url)
            }
        }
    }

    // Popup View (for login windows)
    WebEngineView {
        id: popupView
        anchors.top: topBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        visible: false
        profile: soundcloudProfile

        settings.pluginsEnabled: true
        settings.javascriptEnabled: true
        settings.localStorageEnabled: true
        settings.javascriptCanOpenWindows: true
        settings.allowWindowActivationFromJavaScript: true

        onLoadingChanged: function(loadRequest) {
            if (loadRequest.status === WebEngineView.LoadSucceededStatus) {
                console.log("Popup loaded:", loadRequest.url)

                // If we successfully logged in, close the popup and refresh main view
                if (loadRequest.url.toString().indexOf("soundcloud.com") !== -1 &&
                    loadRequest.url.toString().indexOf("oauth") === -1 &&
                    loadRequest.url.toString().indexOf("login") === -1) {

                    console.log("Login successful! Closing popup...")
                    popupView.visible = false
                    mainView.reload()
                }
            }
        }

        // Allow the popup to open more popups (for Google/Facebook)
        onNewWindowRequested: function(request) {
            console.log("Nested popup requested:", request.requestedUrl)
            request.openIn(popupView)
        }
    }

    // Close popup button overlay
    Rectangle {
        anchors.top: topBar.bottom
        anchors.right: parent.right
        anchors.margins: 20
        width: 120; height: 36
        radius: 8
        color: closeMouse.containsMouse ? "#cc4444" : "#881111"
        border.color: "#ff4444"
        border.width: 1
        visible: popupView.visible
        z: 20

        Text {
            anchors.centerIn: parent
            text: "✕ Close"
            font.family: "monospace"
            font.pixelSize: 13
            color: "#ffffff"
        }

        MouseArea {
            id: closeMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                popupView.visible = false
                mainView.reload()
            }
        }
    }
}


