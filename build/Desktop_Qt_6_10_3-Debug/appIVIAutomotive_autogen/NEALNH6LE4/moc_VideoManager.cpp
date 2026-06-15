/****************************************************************************
** Meta object code from reading C++ file 'VideoManager.h'
**
** Created by: The Qt Meta Object Compiler version 69 (Qt 6.10.3)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../../qml/media/VideoManager.h"
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'VideoManager.h' doesn't include <QObject>."
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
struct qt_meta_tag_ZN12VideoManagerE_t {};
} // unnamed namespace

template <> constexpr inline auto VideoManager::qt_create_metaobjectdata<qt_meta_tag_ZN12VideoManagerE_t>()
{
    namespace QMC = QtMocConstants;
    QtMocHelpers::StringRefStorage qt_stringData {
        "VideoManager",
        "playlistChanged",
        "",
        "currentVideoChanged",
        "playingChanged",
        "volumeChanged",
        "positionChanged",
        "durationChanged",
        "statusChanged",
        "loadingChanged",
        "scanFolder",
        "path",
        "scanUSB",
        "playVideo",
        "index",
        "playPause",
        "next",
        "previous",
        "setVolume",
        "volume",
        "seek",
        "position",
        "stop",
        "playlist",
        "QVariantList",
        "currentTitle",
        "playing",
        "duration",
        "statusMsg",
        "currentIndex",
        "player",
        "QMediaPlayer*",
        "loading",
        "defaultVideoPath"
    };

    QtMocHelpers::UintData qt_methods {
        // Signal 'playlistChanged'
        QtMocHelpers::SignalData<void()>(1, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'currentVideoChanged'
        QtMocHelpers::SignalData<void()>(3, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'playingChanged'
        QtMocHelpers::SignalData<void()>(4, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'volumeChanged'
        QtMocHelpers::SignalData<void()>(5, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'positionChanged'
        QtMocHelpers::SignalData<void()>(6, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'durationChanged'
        QtMocHelpers::SignalData<void()>(7, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'statusChanged'
        QtMocHelpers::SignalData<void()>(8, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'loadingChanged'
        QtMocHelpers::SignalData<void()>(9, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'scanFolder'
        QtMocHelpers::MethodData<void(const QString &)>(10, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 11 },
        }}),
        // Method 'scanUSB'
        QtMocHelpers::MethodData<void()>(12, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'playVideo'
        QtMocHelpers::MethodData<void(int)>(13, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Int, 14 },
        }}),
        // Method 'playPause'
        QtMocHelpers::MethodData<void()>(15, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'next'
        QtMocHelpers::MethodData<void()>(16, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'previous'
        QtMocHelpers::MethodData<void()>(17, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'setVolume'
        QtMocHelpers::MethodData<void(int)>(18, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Int, 19 },
        }}),
        // Method 'seek'
        QtMocHelpers::MethodData<void(int)>(20, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Int, 21 },
        }}),
        // Method 'stop'
        QtMocHelpers::MethodData<void()>(22, 2, QMC::AccessPublic, QMetaType::Void),
    };
    QtMocHelpers::UintData qt_properties {
        // property 'playlist'
        QtMocHelpers::PropertyData<QVariantList>(23, 0x80000000 | 24, QMC::DefaultPropertyFlags | QMC::EnumOrFlag, 0),
        // property 'currentTitle'
        QtMocHelpers::PropertyData<QString>(25, QMetaType::QString, QMC::DefaultPropertyFlags, 1),
        // property 'playing'
        QtMocHelpers::PropertyData<bool>(26, QMetaType::Bool, QMC::DefaultPropertyFlags, 2),
        // property 'volume'
        QtMocHelpers::PropertyData<int>(19, QMetaType::Int, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 3),
        // property 'position'
        QtMocHelpers::PropertyData<int>(21, QMetaType::Int, QMC::DefaultPropertyFlags, 4),
        // property 'duration'
        QtMocHelpers::PropertyData<int>(27, QMetaType::Int, QMC::DefaultPropertyFlags, 5),
        // property 'statusMsg'
        QtMocHelpers::PropertyData<QString>(28, QMetaType::QString, QMC::DefaultPropertyFlags, 6),
        // property 'currentIndex'
        QtMocHelpers::PropertyData<int>(29, QMetaType::Int, QMC::DefaultPropertyFlags, 1),
        // property 'player'
        QtMocHelpers::PropertyData<QMediaPlayer*>(30, 0x80000000 | 31, QMC::DefaultPropertyFlags | QMC::EnumOrFlag | QMC::Constant),
        // property 'loading'
        QtMocHelpers::PropertyData<bool>(32, QMetaType::Bool, QMC::DefaultPropertyFlags, 7),
        // property 'defaultVideoPath'
        QtMocHelpers::PropertyData<QString>(33, QMetaType::QString, QMC::DefaultPropertyFlags | QMC::Constant),
    };
    QtMocHelpers::UintData qt_enums {
    };
    return QtMocHelpers::metaObjectData<VideoManager, qt_meta_tag_ZN12VideoManagerE_t>(QMC::MetaObjectFlag{}, qt_stringData,
            qt_methods, qt_properties, qt_enums);
}
Q_CONSTINIT const QMetaObject VideoManager::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN12VideoManagerE_t>.stringdata,
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN12VideoManagerE_t>.data,
    qt_static_metacall,
    nullptr,
    qt_staticMetaObjectRelocatingContent<qt_meta_tag_ZN12VideoManagerE_t>.metaTypes,
    nullptr
} };

void VideoManager::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = static_cast<VideoManager *>(_o);
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: _t->playlistChanged(); break;
        case 1: _t->currentVideoChanged(); break;
        case 2: _t->playingChanged(); break;
        case 3: _t->volumeChanged(); break;
        case 4: _t->positionChanged(); break;
        case 5: _t->durationChanged(); break;
        case 6: _t->statusChanged(); break;
        case 7: _t->loadingChanged(); break;
        case 8: _t->scanFolder((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1]))); break;
        case 9: _t->scanUSB(); break;
        case 10: _t->playVideo((*reinterpret_cast<std::add_pointer_t<int>>(_a[1]))); break;
        case 11: _t->playPause(); break;
        case 12: _t->next(); break;
        case 13: _t->previous(); break;
        case 14: _t->setVolume((*reinterpret_cast<std::add_pointer_t<int>>(_a[1]))); break;
        case 15: _t->seek((*reinterpret_cast<std::add_pointer_t<int>>(_a[1]))); break;
        case 16: _t->stop(); break;
        default: ;
        }
    }
    if (_c == QMetaObject::IndexOfMethod) {
        if (QtMocHelpers::indexOfMethod<void (VideoManager::*)()>(_a, &VideoManager::playlistChanged, 0))
            return;
        if (QtMocHelpers::indexOfMethod<void (VideoManager::*)()>(_a, &VideoManager::currentVideoChanged, 1))
            return;
        if (QtMocHelpers::indexOfMethod<void (VideoManager::*)()>(_a, &VideoManager::playingChanged, 2))
            return;
        if (QtMocHelpers::indexOfMethod<void (VideoManager::*)()>(_a, &VideoManager::volumeChanged, 3))
            return;
        if (QtMocHelpers::indexOfMethod<void (VideoManager::*)()>(_a, &VideoManager::positionChanged, 4))
            return;
        if (QtMocHelpers::indexOfMethod<void (VideoManager::*)()>(_a, &VideoManager::durationChanged, 5))
            return;
        if (QtMocHelpers::indexOfMethod<void (VideoManager::*)()>(_a, &VideoManager::statusChanged, 6))
            return;
        if (QtMocHelpers::indexOfMethod<void (VideoManager::*)()>(_a, &VideoManager::loadingChanged, 7))
            return;
    }
    if (_c == QMetaObject::RegisterPropertyMetaType) {
        switch (_id) {
        default: *reinterpret_cast<int*>(_a[0]) = -1; break;
        case 8:
            *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< QMediaPlayer* >(); break;
        }
    }
    if (_c == QMetaObject::ReadProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast<QVariantList*>(_v) = _t->playlist(); break;
        case 1: *reinterpret_cast<QString*>(_v) = _t->currentTitle(); break;
        case 2: *reinterpret_cast<bool*>(_v) = _t->playing(); break;
        case 3: *reinterpret_cast<int*>(_v) = _t->volume(); break;
        case 4: *reinterpret_cast<int*>(_v) = _t->position(); break;
        case 5: *reinterpret_cast<int*>(_v) = _t->duration(); break;
        case 6: *reinterpret_cast<QString*>(_v) = _t->statusMsg(); break;
        case 7: *reinterpret_cast<int*>(_v) = _t->currentIndex(); break;
        case 8: *reinterpret_cast<QMediaPlayer**>(_v) = _t->player(); break;
        case 9: *reinterpret_cast<bool*>(_v) = _t->loading(); break;
        case 10: *reinterpret_cast<QString*>(_v) = _t->defaultVideoPath(); break;
        default: break;
        }
    }
    if (_c == QMetaObject::WriteProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 3: _t->setVolume(*reinterpret_cast<int*>(_v)); break;
        default: break;
        }
    }
}

const QMetaObject *VideoManager::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *VideoManager::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_staticMetaObjectStaticContent<qt_meta_tag_ZN12VideoManagerE_t>.strings))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int VideoManager::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 17)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 17;
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 17)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 17;
    }
    if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::BindableProperty
            || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 11;
    }
    return _id;
}

// SIGNAL 0
void VideoManager::playlistChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}

// SIGNAL 1
void VideoManager::currentVideoChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 1, nullptr);
}

// SIGNAL 2
void VideoManager::playingChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 2, nullptr);
}

// SIGNAL 3
void VideoManager::volumeChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 3, nullptr);
}

// SIGNAL 4
void VideoManager::positionChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 4, nullptr);
}

// SIGNAL 5
void VideoManager::durationChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 5, nullptr);
}

// SIGNAL 6
void VideoManager::statusChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 6, nullptr);
}

// SIGNAL 7
void VideoManager::loadingChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 7, nullptr);
}
QT_WARNING_POP
