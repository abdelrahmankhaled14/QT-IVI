/****************************************************************************
** Meta object code from reading C++ file 'PhoneManager.h'
**
** Created by: The Qt Meta Object Compiler version 69 (Qt 6.10.3)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../../qml/phone/PhoneManager.h"
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'PhoneManager.h' doesn't include <QObject>."
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
struct qt_meta_tag_ZN12PhoneManagerE_t {};
} // unnamed namespace

template <> constexpr inline auto PhoneManager::qt_create_metaobjectdata<qt_meta_tag_ZN12PhoneManagerE_t>()
{
    namespace QMC = QtMocConstants;
    QtMocHelpers::StringRefStorage qt_stringData {
        "PhoneManager",
        "phoneConnectedChanged",
        "",
        "contactsChanged",
        "recentsChanged",
        "syncingChanged",
        "statusChanged",
        "callStateChanged",
        "callSecondsChanged",
        "refreshConnectedDevice",
        "onTransferPropertiesChanged",
        "QDBusMessage",
        "msg",
        "onTick",
        "onPaEvent",
        "syncPhonebook",
        "dial",
        "number",
        "name",
        "answer",
        "hangup",
        "phoneConnected",
        "deviceName",
        "contacts",
        "QVariantList",
        "recents",
        "syncing",
        "statusMsg",
        "callState",
        "activeNumber",
        "activeName",
        "callSeconds"
    };

    QtMocHelpers::UintData qt_methods {
        // Signal 'phoneConnectedChanged'
        QtMocHelpers::SignalData<void()>(1, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'contactsChanged'
        QtMocHelpers::SignalData<void()>(3, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'recentsChanged'
        QtMocHelpers::SignalData<void()>(4, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'syncingChanged'
        QtMocHelpers::SignalData<void()>(5, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'statusChanged'
        QtMocHelpers::SignalData<void()>(6, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'callStateChanged'
        QtMocHelpers::SignalData<void()>(7, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'callSecondsChanged'
        QtMocHelpers::SignalData<void()>(8, 2, QMC::AccessPublic, QMetaType::Void),
        // Slot 'refreshConnectedDevice'
        QtMocHelpers::SlotData<void()>(9, 2, QMC::AccessPrivate, QMetaType::Void),
        // Slot 'onTransferPropertiesChanged'
        QtMocHelpers::SlotData<void(const QDBusMessage &)>(10, 2, QMC::AccessPrivate, QMetaType::Void, {{
            { 0x80000000 | 11, 12 },
        }}),
        // Slot 'onTick'
        QtMocHelpers::SlotData<void()>(13, 2, QMC::AccessPrivate, QMetaType::Void),
        // Slot 'onPaEvent'
        QtMocHelpers::SlotData<void()>(14, 2, QMC::AccessPrivate, QMetaType::Void),
        // Method 'syncPhonebook'
        QtMocHelpers::MethodData<void()>(15, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'dial'
        QtMocHelpers::MethodData<void(const QString &, const QString &)>(16, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 17 }, { QMetaType::QString, 18 },
        }}),
        // Method 'dial'
        QtMocHelpers::MethodData<void(const QString &)>(16, 2, QMC::AccessPublic | QMC::MethodCloned, QMetaType::Void, {{
            { QMetaType::QString, 17 },
        }}),
        // Method 'answer'
        QtMocHelpers::MethodData<void()>(19, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'hangup'
        QtMocHelpers::MethodData<void()>(20, 2, QMC::AccessPublic, QMetaType::Void),
    };
    QtMocHelpers::UintData qt_properties {
        // property 'phoneConnected'
        QtMocHelpers::PropertyData<bool>(21, QMetaType::Bool, QMC::DefaultPropertyFlags, 0),
        // property 'deviceName'
        QtMocHelpers::PropertyData<QString>(22, QMetaType::QString, QMC::DefaultPropertyFlags, 0),
        // property 'contacts'
        QtMocHelpers::PropertyData<QVariantList>(23, 0x80000000 | 24, QMC::DefaultPropertyFlags | QMC::EnumOrFlag, 1),
        // property 'recents'
        QtMocHelpers::PropertyData<QVariantList>(25, 0x80000000 | 24, QMC::DefaultPropertyFlags | QMC::EnumOrFlag, 2),
        // property 'syncing'
        QtMocHelpers::PropertyData<bool>(26, QMetaType::Bool, QMC::DefaultPropertyFlags, 3),
        // property 'statusMsg'
        QtMocHelpers::PropertyData<QString>(27, QMetaType::QString, QMC::DefaultPropertyFlags, 4),
        // property 'callState'
        QtMocHelpers::PropertyData<QString>(28, QMetaType::QString, QMC::DefaultPropertyFlags, 5),
        // property 'activeNumber'
        QtMocHelpers::PropertyData<QString>(29, QMetaType::QString, QMC::DefaultPropertyFlags, 5),
        // property 'activeName'
        QtMocHelpers::PropertyData<QString>(30, QMetaType::QString, QMC::DefaultPropertyFlags, 5),
        // property 'callSeconds'
        QtMocHelpers::PropertyData<int>(31, QMetaType::Int, QMC::DefaultPropertyFlags, 6),
    };
    QtMocHelpers::UintData qt_enums {
    };
    return QtMocHelpers::metaObjectData<PhoneManager, qt_meta_tag_ZN12PhoneManagerE_t>(QMC::MetaObjectFlag{}, qt_stringData,
            qt_methods, qt_properties, qt_enums);
}
Q_CONSTINIT const QMetaObject PhoneManager::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN12PhoneManagerE_t>.stringdata,
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN12PhoneManagerE_t>.data,
    qt_static_metacall,
    nullptr,
    qt_staticMetaObjectRelocatingContent<qt_meta_tag_ZN12PhoneManagerE_t>.metaTypes,
    nullptr
} };

void PhoneManager::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = static_cast<PhoneManager *>(_o);
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: _t->phoneConnectedChanged(); break;
        case 1: _t->contactsChanged(); break;
        case 2: _t->recentsChanged(); break;
        case 3: _t->syncingChanged(); break;
        case 4: _t->statusChanged(); break;
        case 5: _t->callStateChanged(); break;
        case 6: _t->callSecondsChanged(); break;
        case 7: _t->refreshConnectedDevice(); break;
        case 8: _t->onTransferPropertiesChanged((*reinterpret_cast<std::add_pointer_t<QDBusMessage>>(_a[1]))); break;
        case 9: _t->onTick(); break;
        case 10: _t->onPaEvent(); break;
        case 11: _t->syncPhonebook(); break;
        case 12: _t->dial((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[2]))); break;
        case 13: _t->dial((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1]))); break;
        case 14: _t->answer(); break;
        case 15: _t->hangup(); break;
        default: ;
        }
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        switch (_id) {
        default: *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType(); break;
        case 8:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType(); break;
            case 0:
                *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType::fromType< QDBusMessage >(); break;
            }
            break;
        }
    }
    if (_c == QMetaObject::IndexOfMethod) {
        if (QtMocHelpers::indexOfMethod<void (PhoneManager::*)()>(_a, &PhoneManager::phoneConnectedChanged, 0))
            return;
        if (QtMocHelpers::indexOfMethod<void (PhoneManager::*)()>(_a, &PhoneManager::contactsChanged, 1))
            return;
        if (QtMocHelpers::indexOfMethod<void (PhoneManager::*)()>(_a, &PhoneManager::recentsChanged, 2))
            return;
        if (QtMocHelpers::indexOfMethod<void (PhoneManager::*)()>(_a, &PhoneManager::syncingChanged, 3))
            return;
        if (QtMocHelpers::indexOfMethod<void (PhoneManager::*)()>(_a, &PhoneManager::statusChanged, 4))
            return;
        if (QtMocHelpers::indexOfMethod<void (PhoneManager::*)()>(_a, &PhoneManager::callStateChanged, 5))
            return;
        if (QtMocHelpers::indexOfMethod<void (PhoneManager::*)()>(_a, &PhoneManager::callSecondsChanged, 6))
            return;
    }
    if (_c == QMetaObject::ReadProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast<bool*>(_v) = _t->phoneConnected(); break;
        case 1: *reinterpret_cast<QString*>(_v) = _t->deviceName(); break;
        case 2: *reinterpret_cast<QVariantList*>(_v) = _t->contacts(); break;
        case 3: *reinterpret_cast<QVariantList*>(_v) = _t->recents(); break;
        case 4: *reinterpret_cast<bool*>(_v) = _t->syncing(); break;
        case 5: *reinterpret_cast<QString*>(_v) = _t->statusMsg(); break;
        case 6: *reinterpret_cast<QString*>(_v) = _t->callState(); break;
        case 7: *reinterpret_cast<QString*>(_v) = _t->activeNumber(); break;
        case 8: *reinterpret_cast<QString*>(_v) = _t->activeName(); break;
        case 9: *reinterpret_cast<int*>(_v) = _t->callSeconds(); break;
        default: break;
        }
    }
}

const QMetaObject *PhoneManager::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *PhoneManager::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_staticMetaObjectStaticContent<qt_meta_tag_ZN12PhoneManagerE_t>.strings))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int PhoneManager::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 16)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 16;
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 16)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 16;
    }
    if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::BindableProperty
            || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 10;
    }
    return _id;
}

// SIGNAL 0
void PhoneManager::phoneConnectedChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}

// SIGNAL 1
void PhoneManager::contactsChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 1, nullptr);
}

// SIGNAL 2
void PhoneManager::recentsChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 2, nullptr);
}

// SIGNAL 3
void PhoneManager::syncingChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 3, nullptr);
}

// SIGNAL 4
void PhoneManager::statusChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 4, nullptr);
}

// SIGNAL 5
void PhoneManager::callStateChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 5, nullptr);
}

// SIGNAL 6
void PhoneManager::callSecondsChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 6, nullptr);
}
QT_WARNING_POP
