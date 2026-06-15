

// // #include <QGuiApplication>
// // #include <QQmlApplicationEngine>
// // #include <QtWebEngineQuick/qtwebenginequickglobal.h>
// // #include <QQmlContext>
// // #include "qml/weather/weatherviewmodel.h"
// // #include <QLoggingCategory>
// // #include "qml/settings/backend/settingsmanager.h"
// // int main(int argc, char *argv[])
// // {
// //         qputenv("QTWEBENGINE_CHROMIUM_FLAGS", "--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36");
// //     QtWebEngineQuick::initialize();
// //     QGuiApplication app(argc, argv);

// //     QQmlApplicationEngine engine;
// //     WeatherViewModel weatherVM;
// //     engine.rootContext()->setContextProperty("weatherVM", &weatherVM);
// //     const QUrl url("../../Main.qml");

// //     QObject::connect(
// //         &engine,
// //         &QQmlApplicationEngine::objectCreationFailed,
// //         &app,
// //         []() { QCoreApplication::exit(-1); },
// //         Qt::QueuedConnection
// //         );

// //     engine.load(url);

// //     return app.exec();
// // }

// #include <QGuiApplication>
// #include <QQmlApplicationEngine>
// #include <QQmlContext>
// #include <QDebug>
// #include <QCoreApplication>
// #include <QtWebEngineQuick/qtwebenginequickglobal.h>
// #include <QLoggingCategory>

// // #include "qml/mediaplayer_2/backend/RadioManager.h"
// // #include "qml/mediaplayer_2/backend/AudioManager.h"
// // #include "qml/mediaplayer_2/backend/VideoManager.h"
// // #include "qml/mediaplayer_2/backend/BluetoothManager.h"

// // ── Backend Headers ─────────────────────────────────────────────────────────
// #include "qml/settings/backend/settingsmanager.h"
// #include "qml/weather/weatherviewmodel.h"

// int main(int argc, char *argv[])
// {
//     // ── 1. Environment & WebEngine Initialization ───────────────────────────
//     // MUST be set before initialize() and QGuiApplication
//     qputenv("QTWEBENGINE_CHROMIUM_FLAGS",
//             "--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
//             "(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36");

//     // MUST be called before QGuiApplication
//     QtWebEngineQuick::initialize();


//     // RadioManager    radioManager;
//     // AudioManager    audioManager;
//     // VideoManager    videoManager;
//     // BluetoothManager bluetoothManager;

//     // ── 2. Application Setup ────────────────────────────────────────────────
//     QGuiApplication app(argc, argv);
//     app.setApplicationName("IVIAutomotive");
//     app.setOrganizationName("YourOrg");

//     // ── 3. Register Meta-Types ──────────────────────────────────────────────
//     // Required for signals/slots passing custom types
//     qRegisterMetaType<WifiNetwork>();

//     // Expose model type to QML without allowing direct instantiation
//     qmlRegisterUncreatableType<WifiNetworkModel>(
//         "App.Models", 1, 0, "WifiNetworkModel",
//         "WifiNetworkModel is provided by SettingsManager; do not create in QML."
//         );

//     // ── 4. Instantiate Backend Objects ──────────────────────────────────────
//     SettingsManager settings;
//     WeatherViewModel weatherVM;

//     // ── 5. QML Engine & Context Properties ──────────────────────────────────
//     QQmlApplicationEngine engine;
//     QQmlContext *ctx = engine.rootContext();

//     // Expose backends to QML
//     ctx->setContextProperty("SettingsManager", &settings);
//     ctx->setContextProperty("weatherVM", &weatherVM);

//     // ── 6. Error Handling ───────────────────────────────────────────────────
//     QObject::connect(
//         &engine,
//         &QQmlApplicationEngine::objectCreationFailed,
//         &app,
//         []() {
//             qCritical() << "❌ QML Engine: Failed to load root component.";
//             QCoreApplication::exit(-1);
//         },
//         Qt::QueuedConnection
//         );

//     // ── 7. Load QML ─────────────────────────────────────────────────────────
//     // OPTION A: Module-based loading (Recommended for Qt 6)
//     // Ensure your CMakeLists.txt defines a module named "settings" with Main.qml
//     engine.loadFromModule("IVIAutomotive", "Main");


//     return app.exec();
// }


#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QCoreApplication>
#include <QtWebEngineQuick/qtwebenginequickglobal.h>
#include <QLoggingCategory>

// Backend headers
#include "qml/settings/backend/settingsmanager.h"
#include "qml/weather/weatherviewmodel.h"

#include "qml/media/RadioManager.h"
#include "qml/media/AudioManager.h"
#include "qml/media/VideoManager.h"
#include "qml/media/BluetoothManager.h"
#include "qml/phone/PhoneManager.h"

int main(int argc, char *argv[])
{
    // ── 1. WebEngine Setup ─────────────────────────────────────────
    // Allow media to autoplay without a user gesture (IVI / kiosk use-case).
    // NOTE: the user-agent is set per-WebEngineProfile in QML (Youtube/Spotify),
    // because spaces in a CHROMIUM_FLAGS --user-agent value get split into
    // separate args and never take effect here.
    qputenv("QTWEBENGINE_CHROMIUM_FLAGS",
            "--autoplay-policy=no-user-gesture-required");

    // ── On-screen virtual keyboard ─────────────────────────────────
    // Touch-screen head unit has no physical keyboard. Loading the
    // virtual-keyboard input method here makes it pop up for every text
    // field — QML TextFields (Navigation, Weather) and the web inputs
    // inside the WebEngine views (YouTube, SoundCloud) alike. The actual
    // keyboard is rendered by the InputPanel declared in Main.qml.
    qputenv("QT_IM_MODULE", "qtvirtualkeyboard");

    QtWebEngineQuick::initialize();

    // ── 2. Create App ──────────────────────────────────────────────
    QGuiApplication app(argc, argv);
    app.setApplicationName("IVIAutomotive");
    app.setOrganizationName("YourOrg");

    // ── 3. Backend Objects ─────────────────────────────────────────
    SettingsManager settings;
    WeatherViewModel weatherVM;

    RadioManager     radioManager;
    AudioManager     audioManager;
    VideoManager     videoManager;
    BluetoothManager bluetoothManager;
    PhoneManager     phoneManager;

    // ── 4. QML Engine ──────────────────────────────────────────────
    QQmlApplicationEngine engine;
    QQmlContext *ctx = engine.rootContext();

    // Expose backends to QML
    ctx->setContextProperty("SettingsManager", &settings);
    ctx->setContextProperty("weatherVM", &weatherVM);

    ctx->setContextProperty("radioManager",     &radioManager);
    ctx->setContextProperty("audioManager",     &audioManager);
    ctx->setContextProperty("videoManager",     &videoManager);
    ctx->setContextProperty("bluetoothManager", &bluetoothManager);
    ctx->setContextProperty("phoneManager",     &phoneManager);

    // ── 5. Error Handling ──────────────────────────────────────────
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() {
            qCritical() << "❌ Failed to load QML root object.";
            QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection
        );

    // ── 6. Load QML Module (Qt6 Style) ────────────────────────────
    engine.loadFromModule("IVIAutomotive", "Main");

    return app.exec();
}