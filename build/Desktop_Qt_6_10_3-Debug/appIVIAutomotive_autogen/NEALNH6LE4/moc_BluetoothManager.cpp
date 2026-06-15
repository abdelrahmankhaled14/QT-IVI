/****************************************************************************
** Meta object code from reading C++ file 'BluetoothManager.h'
**
** Created by: The Qt Meta Object Compiler version 69 (Qt 6.10.3)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../../qml/media/BluetoothManager.h"
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'BluetoothManager.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 69
#error "This file was generated using the moc from 6.10.3. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

#ifndef Q_CONSTINIT
#define Q_CONSTINIT
#endif

QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
QT_WARNING_DISABLE_GCC("-Wuseless-cast")
namespace {
struct qt_meta_tag_ZN16BluetoothManagerE_t {};
} // unnamed namespace

template <> constexpr inline auto BluetoothManager::qt_create_metaobjectdata<qt_meta_tag_ZN16BluetoothManagerE_t>()
{
    namespace QMC = QtMocConstants;
    QtMocHelpers::StringRefStorage qt_stringData {
        "BluetoothManager",
        "bluetoothAvailableChanged",
        "",
        "scanningChanged",
        "connectedChanged",
        "devicesChanged",
        "statusChanged",
        "discoverableChanged",
        "playingChanged",
        "volumeChanged",
        "hfpConnectedChanged",
        "avrcpChanged",
        "trackChanged",
        "onScanTimeout",
        "onInterfacesAdded",
        "QDBusMessage",
        "msg",
        "onInterfacesRemoved",
        "onPropertiesChanged",
        "onPollTimer",
        "startScan",
        "stopScan",
        "connectDevice",
        "address",
        "disconnectDevice",
        "setDiscoverable",
        "on",
        "setVolume",
        "vol",
        "retryAudio",
        "mediaPlay",
        "mediaPause",
        "mediaPlayPause",
        "mediaNext",
        "mediaPrevious",
        "bluetoothAvailable",
        "scanning",
        "connected",
        "connectedDevice",
        "devices",
        "QVariantList",
        "statusMsg",
        "discoverable",
        "playing",
        "volume",
        "hfpConnected",
        "avrcpAvailable",
        "avrcpStatus",
        "trackTitle",
        "trackArtist",
        "trackAlbum"
    };

    QtMocHelpers::UintData qt_methods {
        // Signal 'bluetoothAvailableChanged'
        QtMocHelpers::SignalData<void()>(1, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'scanningChanged'
        QtMocHelpers::SignalData<void()>(3, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'connectedChanged'
        QtMocHelpers::SignalData<void()>(4, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'devicesChanged'
        QtMocHelpers::SignalData<void()>(5, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'statusChanged'
        QtMocHelpers::SignalData<void()>(6, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'discoverableChanged'
        QtMocHelpers::SignalData<void()>(7, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'playingChanged'
        QtMocHelpers::SignalData<void()>(8, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'volumeChanged'
        QtMocHelpers::SignalData<void()>(9, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'hfpConnectedChanged'
        QtMocHelpers::SignalData<void()>(10, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'avrcpChanged'
        QtMocHelpers::SignalData<void()>(11, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'trackChanged'
        QtMocHelpers::SignalData<void()>(12, 2, QMC::AccessPublic, QMetaType::Void),
        // Slot 'onScanTimeout'
        QtMocHelpers::SlotData<void()>(13, 2, QMC::AccessPrivate, QMetaType::Void),
        // Slot 'onInterfacesAdded'
        QtMocHelpers::SlotData<void(const QDBusMessage &)>(14, 2, QMC::AccessPrivate, QMetaType::Void, {{
            { 0x80000000 | 15, 16 },
        }}),
        // Slot 'onInterfacesRemoved'
        QtMocHelpers::SlotData<void(const QDBusMessage &)>(17, 2, QMC::AccessPrivate, QMetaType::Void, {{
            { 0x80000000 | 15, 16 },
        }}),
        // Slot 'onPropertiesChanged'
        QtMocHelpers::SlotData<void(const QDBusMessage &)>(18, 2, QMC::AccessPrivate, QMetaType::Void, {{
            { 0x80000000 | 15, 16 },
        }}),
        // Slot 'onPollTimer'
        QtMocHelpers::SlotData<void()>(19, 2, QMC::AccessPrivate, QMetaType::Void),
        // Method 'startScan'
        QtMocHelpers::MethodData<void()>(20, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'stopScan'
        QtMocHelpers::MethodData<void()>(21, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'connectDevice'
        QtMocHelpers::MethodData<void(const QString &)>(22, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 23 },
        }}),
        // Method 'disconnectDevice'
        QtMocHelpers::MethodData<void()>(24, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'setDiscoverable'
        QtMocHelpers::MethodData<void(bool)>(25, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Bool, 26 },
        }}),
        // Method 'setVolume'
        QtMocHelpers::MethodData<void(int)>(27, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Int, 28 },
        }}),
        // Method 'retryAudio'
        QtMocHelpers::MethodData<void()>(29, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'mediaPlay'
        QtMocHelpers::MethodData<void()>(30, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'mediaPause'
        QtMocHelpers::MethodData<void()>(31, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'mediaPlayPause'
        QtMocHelpers::MethodData<void()>(32, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'mediaNext'
        QtMocHelpers::MethodData<void()>(33, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'mediaPrevious'
        QtMocHelpers::MethodData<void()>(34, 2, QMC::AccessPublic, QMetaType::Void),
    };
    QtMocHelpers::UintData qt_properties {
        // property 'bluetoothAvailable'
        QtMocHelpers::PropertyData<bool>(35, QMetaType::Bool, QMC::DefaultPropertyFlags, 0),
        // property 'scanning'
        QtMocHelpers::PropertyData<bool>(36, QMetaType::Bool, QMC::DefaultPropertyFlags, 1),
        // property 'connected'
        QtMocHelpers::PropertyData<bool>(37, QMetaType::Bool, QMC::DefaultPropertyFlags, 2),
        // property 'connectedDevice'
        QtMocHelpers::PropertyData<QString>(38, QMetaType::QString, QMC::DefaultPropertyFlags, 2),
        // property 'devices'
        QtMocHelpers::PropertyData<QVariantList>(39, 0x80000000 | 40, QMC::DefaultPropertyFlags | QMC::EnumOrFlag, 3),
        // property 'statusMsg'
        QtMocHelpers::PropertyData<QString>(41, QMetaType::QString, QMC::DefaultPropertyFlags, 4),
        // property 'discoverable'
        QtMocHelpers::PropertyData<bool>(42, QMetaType::Bool, QMC::DefaultPropertyFlags, 5),
        // property 'playing'
        QtMocHelpers::PropertyData<bool>(43, QMetaType::Bool, QMC::DefaultPropertyFlags, 6),
        // property 'volume'
        QtMocHelpers::PropertyData<int>(44, QMetaType::Int, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 7),
        // property 'hfpConnected'
        QtMocHelpers::PropertyData<bool>(45, QMetaType::Bool, QMC::DefaultPropertyFlags, 8),
        // property 'avrcpAvailable'
        QtMocHelpers::PropertyData<bool>(46, QMetaType::Bool, QMC::DefaultPropertyFlags, 9),
        // property 'avrcpStatus'
        QtMocHelpers::PropertyData<QString>(47, QMetaType::QString, QMC::DefaultPropertyFlags, 9),
        // property 'trackTitle'
        QtMocHelpers::PropertyData<QString>(48, QMetaType::QString, QMC::DefaultPropertyFlags, 10),
        // property 'trackArtist'
        QtMocHelpers::PropertyData<QString>(49, QMetaType::QString, QMC::DefaultPropertyFlags, 10),
        // property 'trackAlbum'
        QtMocHelpers::PropertyData<QString>(50, QMetaType::QString, QMC::DefaultPropertyFlags, 10),
    };
    QtMocHelpers::UintData qt_enums {
    };
    return QtMocHelpers::metaObjectData<BluetoothManager, qt_meta_tag_ZN16BluetoothManagerE_t>(QMC::MetaObjectFlag{}, qt_stringData,
            qt_methods, qt_properties, qt_enums);
}
Q_CONSTINIT const QMetaObject BluetoothManager::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN16BluetoothManagerE_t>.stringdata,
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN16BluetoothManagerE_t>.data,
    qt_static_metacall,
    nullptr,
    qt_staticMetaObjectRelocatingContent<qt_meta_tag_ZN16BluetoothManagerE_t>.metaTypes,
    nullptr
} };

void BluetoothManager::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = static_cast<BluetoothManager *>(_o);
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: _t->bluetoothAvailableChanged(); break;
        case 1: _t->scanningChanged(); break;
        case 2: _t->connectedChanged(); break;
        case 3: _t->devicesChanged(); break;
        case 4: _t->statusChanged(); break;
        case 5: _t->discoverableChanged(); break;
        case 6: _t->playingChanged(); break;
        case 7: _t->volumeChanged(); break;
        case 8: _t->hfpConnectedChanged(); break;
        case 9: _t->avrcpChanged(); break;
        case 10: _t->trackChanged(); break;
        case 11: _t->onScanTimeout(); break;
        case 12: _t->onInterfacesAdded((*reinterpret_cast<std::add_pointer_t<QDBusMessage>>(_a[1]))); break;
        case 13: _t->onInterfacesRemoved((*reinterpret_cast<std::add_pointer_t<QDBusMessage>>(_a[1]))); break;
        case 14: _t->onPropertiesChanged((*reinterpret_cast<std::add_pointer_t<QDBusMessage>>(_a[1]))); break;
        case 15: _t->onPollTimer(); break;
        case 16: _t->startScan(); break;
        case 17: _t->stopScan(); break;
        case 18: _t->connectDevice((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1]))); break;
        case 19: _t->disconnectDevice(); break;
        case 20: _t->setDiscoverable((*reinterpret_cast<std::add_pointer_t<bool>>(_a[1]))); break;
        case 21: _t->setVolume((*reinterpret_cast<std::add_pointer_t<int>>(_a[1]))); break;
        case 22: _t->retryAudio(); break;
        case 23: _t->mediaPlay(); break;
        case 24: _t->mediaPause(); break;
        case 25: _t->mediaPlayPause(); break;
        case 26: _t->mediaNext(); break;
        case 27: _t->mediaPrevious(); break;
        default: ;
        }
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        switch (_id) {
        default: *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType(); break;
        case 12:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType(); break;
            case 0:
                *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType::fromType< QDBusMessage >(); break;
            }
            break;
        case 13:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType(); break;
            case 0:
                *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType::fromType< QDBusMessage >(); break;
            }
            break;
        case 14:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType(); break;
            case 0:
                *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType::fromType< QDBusMessage >(); break;
            }
            break;
        }
    }
    if (_c == QMetaObject::IndexOfMethod) {
        if (QtMocHelpers::indexOfMethod<void (BluetoothManager::*)()>(_a, &BluetoothManager::bluetoothAvailableChanged, 0))
            return;
        if (QtMocHelpers::indexOfMethod<void (BluetoothManager::*)()>(_a, &BluetoothManager::scanningChanged, 1))
            return;
        if (QtMocHelpers::indexOfMethod<void (BluetoothManager::*)()>(_a, &BluetoothManager::connectedChanged, 2))
            return;
        if (QtMocHelpers::indexOfMethod<void (BluetoothManager::*)()>(_a, &BluetoothManager::devicesChanged, 3))
            return;
        if (QtMocHelpers::indexOfMethod<void (BluetoothManager::*)()>(_a, &BluetoothManager::statusChanged, 4))
            return;
        if (QtMocHelpers::indexOfMethod<void (BluetoothManager::*)()>(_a, &BluetoothManager::discoverableChanged, 5))
            return;
        if (QtMocHelpers::indexOfMethod<void (BluetoothManager::*)()>(_a, &BluetoothManager::playingChanged, 6))
            return;
        if (QtMocHelpers::indexOfMethod<void (BluetoothManager::*)()>(_a, &BluetoothManager::volumeChanged, 7))
            return;
        if (QtMocHelpers::indexOfMethod<void (BluetoothManager::*)()>(_a, &BluetoothManager::hfpConnectedChanged, 8))
            return;
        if (QtMocHelpers::indexOfMethod<void (BluetoothManager::*)()>(_a, &BluetoothManager::avrcpChanged, 9))
            return;
        if (QtMocHelpers::indexOfMethod<void (BluetoothManager::*)()>(_a, &BluetoothManager::trackChanged, 10))
            return;
    }
    if (_c == QMetaObject::ReadProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast<bool*>(_v) = _t->bluetoothAvailable(); break;
        case 1: *reinterpret_cast<bool*>(_v) = _t->scanning(); break;
        case 2: *reinterpret_cast<bool*>(_v) = _t->connected(); break;
        case 3: *reinterpret_cast<QString*>(_v) = _t->connectedDevice(); break;
        case 4: *reinterpret_cast<QVariantList*>(_v) = _t->devices(); break;
        case 5: *reinterpret_cast<QString*>(_v) = _t->statusMsg(); break;
        case 6: *reinterpret_cast<bool*>(_v) = _t->discoverable(); break;
        case 7: *reinterpret_cast<bool*>(_v) = _t->playing(); break;
        case 8: *reinterpret_cast<int*>(_v) = _t->volume(); break;
        case 9: *reinterpret_cast<bool*>(_v) = _t->hfpConnected(); break;
        case 10: *reinterpret_cast<bool*>(_v) = _t->avrcpAvailable(); break;
        case 11: *reinterpret_cast<QString*>(_v) = _t->avrcpStatus(); break;
        case 12: *reinterpret_cast<QString*>(_v) = _t->trackTitle(); break;
        case 13: *reinterpret_cast<QString*>(_v) = _t->trackArtist(); break;
        case 14: *reinterpret_cast<QString*>(_v) = _t->trackAlbum(); break;
        default: break;
        }
    }
    if (_c == QMetaObject::WriteProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 8: _t->setVolume(*reinterpret_cast<int*>(_v)); break;
        default: break;
        }
    }
}

const QMetaObject *BluetoothManager::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *BluetoothManager::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_staticMetaObjectStaticContent<qt_meta_tag_ZN16BluetoothManagerE_t>.strings))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int BluetoothManager::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 28)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 28;
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 28)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 28;
    }
    if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::BindableProperty
            || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 15;
    }
    return _id;
}

// SIGNAL 0
void BluetoothManager::bluetoothAvailableChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}

// SIGNAL 1
void BluetoothManager::scanningChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 1, nullptr);
}

// SIGNAL 2
void BluetoothManager::connectedChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 2, nullptr);
}

// SIGNAL 3
void BluetoothManager::devicesChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 3, nullptr);
}

// SIGNAL 4
void BluetoothManager::statusChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 4, nullptr);
}

// SIGNAL 5
void BluetoothManager::discoverableChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 5, nullptr);
}

// SIGNAL 6
void BluetoothManager::playingChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 6, nullptr);
}

// SIGNAL 7
void BluetoothManager::volumeChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 7, nullptr);
}

// SIGNAL 8
void BluetoothManager::hfpConnectedChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 8, nullptr);
}

// SIGNAL 9
void BluetoothManager::avrcpChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 9, nullptr);
}

// SIGNAL 10
void BluetoothManager::trackChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 10, nullptr);
}
QT_WARNING_POP
