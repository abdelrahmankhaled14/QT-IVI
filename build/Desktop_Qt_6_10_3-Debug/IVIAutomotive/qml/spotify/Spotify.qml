import QtQuick 2.15
import QtQuick.Controls 2.15
import QtWebEngine

Item {
    id: root
    signal closeApp()

    WebEngineProfile {
        id: spotifyProfile
        storageName: "spotify_music"
        offTheRecord: false
        persistentCookiesPolicy: WebEngineProfile.ForcePersistentCookies
        // Current desktop-Chrome user-agent so the page loads reliably and
        // sign-in flows aren't rejected for using an outdated browser.
        httpUserAgent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
    }

    Rectangle {
        id: topBar
        height: 48
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        color: theme.bgFooter
        z: 10

        Rectangle {
            width: 100; height: 34; radius: theme.r1
            color: backMouse.containsMouse ? theme.bgHover : theme.bgCard
            border.color: theme.spotifyAc; border.width: 1
            anchors.left: parent.left; anchors.leftMargin: 16; anchors.verticalCenter: parent.verticalCenter

            Text {
                text: "← Home"
                font.family: theme.displayFont
                font.pixelSize: 13; color: theme.spotifyAc
                anchors.centerIn: parent
            }

            MouseArea {
                id: backMouse
                anchors.fill: parent
                hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onClicked: root.closeApp()
            }
        }

        Text {
            text: "Soundcloud"
            font.family: theme.displayFont
            font.pixelSize: 13; color: theme.spotifyAc; font.weight: 600
            anchors.centerIn: parent
        }
    }

    WebEngineView {
        id: webView
        anchors.top: topBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        profile: spotifyProfile
        url: "https://soundcloud.com/"

        settings.javascriptEnabled: true
        settings.javascriptCanOpenWindows: true
        settings.playbackRequiresUserGesture: false
        settings.pluginsEnabled: true
        settings.localStorageEnabled: true

        // SoundCloud's "Continue with Google" opens a popup for the account
        // chooser. Route popups into this view so sign-in can complete.
        onNewWindowRequested: function(request) {
            request.openIn(webView)
        }
    }
}