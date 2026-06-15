cmake_minimum_required(VERSION 3.16)

project(IVIAutomotive VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTORCC ON)
find_package(ALSA REQUIRED)
find_package(Qt6 REQUIRED COMPONENTS Quick WebEngineQuick Location Positioning  Quick3D Network DBus Multimedia VirtualKeyboard)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appIVIAutomotive
    main.cpp
)
find_package(PkgConfig REQUIRED)
pkg_check_modules(GSTREAMER REQUIRED gstreamer-1.0)

target_include_directories(appIVIAutomotive PRIVATE
    ${GSTREAMER_INCLUDE_DIRS}
)
qt_add_qml_module(appIVIAutomotive
    URI IVIAutomotive
    QML_FILES
        Main.qml
        QML_FILES
        QML_FILES qml/weather/weather.qml
        QML_FILES
        QML_FILES qml/HVAC/HVAC.qml
        QML_FILES
        RESOURCES
        RESOURCES assets.qrc
        QML_FILES qml/applauncher/Applauncher.qml
        QML_FILES
        QML_FILES
        QML_FILES
        QML_FILES
        QML_FILES
        QML_FILES qml/youtube/Youtube.qml
        QML_FILES qml/navigation/Navi.qml
        SOURCES qml/weather/WeatherData.h
        SOURCES qml/weather/networkhandler.h qml/weather/networkhandler.cpp
        SOURCES qml/weather/weatherviewmodel.h qml/weather/weatherviewmodel.cpp
        QML_FILES
        QML_FILES qml/weather/MainScreen.qml
        QML_FILES qml/weather/SplashScreen.qml
        QML_FILES AppTheme.qml
        QML_FILES qml/spotify/Spotify.qml
        QML_FILES
        QML_FILES qml/settings/qml/pages/ThemePage.qml
        QML_FILES qml/settings/qml/pages/VolumePage.qml
        QML_FILES qml/settings/qml/pages/WifiPage.qml
        QML_FILES qml/settings/qml/pages/BluetoothPage.qml
        QML_FILES qml/settings/qml/components/PageHeader.qml
        QML_FILES
        QML_FILES qml/settings/qml/components/SettingsGroup.qml
        QML_FILES qml/settings/qml/components/SettingsRow.qml
        QML_FILES qml/settings/qml/components/StyledSlider.qml
        QML_FILES qml/settings/qml/components/StyledToggle.qml
        QML_FILES qml/settings/qml/sidebar/Sidebar.qml
        QML_FILES qml/settings/qml/sidebar/SidebarItem.qml
        SOURCES
        SOURCES qml/settings/backend/settingsmanager.h qml/settings/backend/settingsmanager.cpp
        SOURCES
        SOURCES qml/settings/backend/soundmanager.h qml/settings/backend/soundmanager.cpp
        SOURCES qml/settings/backend/wifimanager.h qml/settings/backend/wifimanager.cpp
        QML_FILES qml/settings/settings.qml
        SOURCES qml/media/AudioManager.h qml/media/AudioManager.cpp
        SOURCES qml/media/BluetoothAgent.h
        SOURCES qml/media/BluetoothManager.h qml/media/BluetoothManager.cpp
        SOURCES qml/media/RadioManager.h qml/media/RadioManager.cpp
        SOURCES qml/media/VideoManager.h qml/media/VideoManager.cpp
        QML_FILES qml/media/AudioPage.qml
        QML_FILES qml/media/RadioPage.qml
        QML_FILES qml/media/VideoPage.qml
        QML_FILES qml/media/Media.qml
        QML_FILES qml/phone/phone.qml
        SOURCES qml/phone/PhoneManager.h qml/phone/PhoneManager.cpp
        QML_FILES qml/navigation/NaviState.qml
        RESOURCES qml/navigation/qmldir
        QML_FILES qml/HVAC/HVACState.qml
        RESOURCES qml/HVAC/qmldir
        QML_FILES qml/media/MediaState.qml
        RESOURCES qml/media/qmldir
        QML_FILES qml/weather/DetailCard.qml
        QML_FILES qml/applauncher/DashCard.qml
        QML_FILES qml/applauncher/VehiclePage.qml
        QML_FILES qml/applauncher/SeatHeatPage.qml
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appIVIAutomotive PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appIVIAutomotive
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appIVIAutomotive
    PRIVATE Qt6::Quick
    Qt6::WebEngineQuick
    Qt6::Location        # ← add
    Qt6::Positioning     # ← add
    Qt6::Quick3D
    Qt6::Network
    Qt6::DBus
    ALSA::ALSA
    Qt6::Multimedia
    Qt6::VirtualKeyboard
    ${GSTREAMER_LIBRARIES}
)

include(GNUInstallDirs)
install(TARGETS appIVIAutomotive
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
