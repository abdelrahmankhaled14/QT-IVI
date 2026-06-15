import QtQuick 2.15
import QtQuick.Controls 2.15
import QtWebEngine

Item {
    id: root
    signal closeApp()

    WebEngineProfile {
        id: ytProfile
        storageName: "yt_music_standalone"
        offTheRecord: false
        persistentCookiesPolicy: WebEngineProfile.ForcePersistentCookies
        // A current desktop-Chrome user-agent: pages load reliably and it gives
        // the best shot at Google sign-in (an outdated UA is itself rejected).
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
            border.color: theme.youtubeAc; border.width: 1
            anchors.left: parent.left; anchors.leftMargin: 16; anchors.verticalCenter: parent.verticalCenter

            Text {
                text: "← Home"
                font.family: theme.displayFont
                font.pixelSize: 13; color: theme.youtubeAc
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
            text: "YOUTUBE MUSIC"
            font.family: theme.displayFont
            font.pixelSize: 13; color: theme.youtubeAc; font.weight: 600
            anchors.centerIn: parent
        }
    }

    WebEngineView {
        id: webView
        anchors.top: topBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        profile: ytProfile
        url: "https://music.youtube.com"

        settings.javascriptEnabled: true
        settings.javascriptCanOpenWindows: true
        settings.playbackRequiresUserGesture: false
        settings.pluginsEnabled: true
        settings.localStorageEnabled: true

        // Sign-in opens the Google account chooser in a popup window. Without
        // handling this, the popup never opens and login stalls. Route it back
        // into this same view so the flow completes.
        onNewWindowRequested: function(request) {
            request.openIn(webView)
        }
    }
}