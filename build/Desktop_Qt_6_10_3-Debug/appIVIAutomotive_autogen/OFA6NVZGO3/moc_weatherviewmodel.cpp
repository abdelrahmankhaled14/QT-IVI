/****************************************************************************
** Meta object code from reading C++ file 'weatherviewmodel.h'
**
** Created by: The Qt Meta Object Compiler version 69 (Qt 6.10.3)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../../qml/weather/weatherviewmodel.h"
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'weatherviewmodel.h' doesn't include <QObject>."
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
struct qt_meta_tag_ZN16WeatherViewModelE_t {};
} // unnamed namespace

template <> constexpr inline auto WeatherViewModel::qt_create_metaobjectdata<qt_meta_tag_ZN16WeatherViewModelE_t>()
{
    namespace QMC = QtMocConstants;
    QtMocHelpers::StringRefStorage qt_stringData {
        "WeatherViewModel",
        "stateChanged",
        "",
        "dataChanged",
        "errorMessageChanged",
        "splashDoneChanged",
        "handleWeatherData",
        "WeatherData",
        "data",
        "handleError",
        "msg",
        "fetchWeather",
        "city",
        "refresh",
        "appState",
        "isLoading",
        "splashDone",
        "errorMessage",
        "cityName",
        "country",
        "pressure",
        "temperature",
        "feelsLike",
        "tempMin",
        "tempMax",
        "humidity",
        "windSpeed",
        "condition",
        "description",
        "State",
        "Idle",
        "Loading",
        "Success",
        "Error"
    };

    QtMocHelpers::UintData qt_methods {
        // Signal 'stateChanged'
        QtMocHelpers::SignalData<void()>(1, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'dataChanged'
        QtMocHelpers::SignalData<void()>(3, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'errorMessageChanged'
        QtMocHelpers::SignalData<void()>(4, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'splashDoneChanged'
        QtMocHelpers::SignalData<void()>(5, 2, QMC::AccessPublic, QMetaType::Void),
        // Slot 'handleWeatherData'
        QtMocHelpers::SlotData<void(const WeatherData &)>(6, 2, QMC::AccessPrivate, QMetaType::Void, {{
            { 0x80000000 | 7, 8 },
        }}),
        // Slot 'handleError'
        QtMocHelpers::SlotData<void(const QString &)>(9, 2, QMC::AccessPrivate, QMetaType::Void, {{
            { QMetaType::QString, 10 },
        }}),
        // Method 'fetchWeather'
        QtMocHelpers::MethodData<void(const QString &)>(11, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 12 },
        }}),
        // Method 'refresh'
        QtMocHelpers::MethodData<void()>(13, 2, QMC::AccessPublic, QMetaType::Void),
    };
    QtMocHelpers::UintData qt_properties {
        // property 'appState'
        QtMocHelpers::PropertyData<int>(14, QMetaType::Int, QMC::DefaultPropertyFlags, 0),
        // property 'isLoading'
        QtMocHelpers::PropertyData<bool>(15, QMetaType::Bool, QMC::DefaultPropertyFlags, 0),
        // property 'splashDone'
        QtMocHelpers::PropertyData<bool>(16, QMetaType::Bool, QMC::DefaultPropertyFlags, 3),
        // property 'errorMessage'
        QtMocHelpers::PropertyData<QString>(17, QMetaType::QString, QMC::DefaultPropertyFlags, 2),
        // property 'cityName'
        QtMocHelpers::PropertyData<QString>(18, QMetaType::QString, QMC::DefaultPropertyFlags, 1),
        // property 'country'
        QtMocHelpers::PropertyData<QString>(19, QMetaType::QString, QMC::DefaultPropertyFlags, 1),
        // property 'pressure'
        QtMocHelpers::PropertyData<int>(20, QMetaType::Int, QMC::DefaultPropertyFlags, 1),
        // property 'temperature'
        QtMocHelpers::PropertyData<double>(21, QMetaType::Double, QMC::DefaultPropertyFlags, 1),
        // property 'feelsLike'
        QtMocHelpers::PropertyData<double>(22, QMetaType::Double, QMC::DefaultPropertyFlags, 1),
        // property 'tempMin'
        QtMocHelpers::PropertyData<double>(23, QMetaType::Double, QMC::DefaultPropertyFlags, 1),
        // property 'tempMax'
        QtMocHelpers::PropertyData<double>(24, QMetaType::Double, QMC::DefaultPropertyFlags, 1),
        // property 'humidity'
        QtMocHelpers::PropertyData<int>(25, QMetaType::Int, QMC::DefaultPropertyFlags, 1),
        // property 'windSpeed'
        QtMocHelpers::PropertyData<double>(26, QMetaType::Double, QMC::DefaultPropertyFlags, 1),
        // property 'condition'
        QtMocHelpers::PropertyData<QString>(27, QMetaType::QString, QMC::DefaultPropertyFlags, 1),
        // property 'description'
        QtMocHelpers::PropertyData<QString>(28, QMetaType::QString, QMC::DefaultPropertyFlags, 1),
    };
    QtMocHelpers::UintData qt_enums {
        // enum 'State'
        QtMocHelpers::EnumData<enum State>(29, 29, QMC::EnumFlags{}).add({
            {   30, State::Idle },
            {   31, State::Loading },
            {   32, State::Success },
            {   33, State::Error },
        }),
    };
    return QtMocHelpers::metaObjectData<WeatherViewModel, qt_meta_tag_ZN16WeatherViewModelE_t>(QMC::MetaObjectFlag{}, qt_stringData,
            qt_methods, qt_properties, qt_enums);
}
Q_CONSTINIT const QMetaObject WeatherViewModel::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN16WeatherViewModelE_t>.stringdata,
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN16WeatherViewModelE_t>.data,
    qt_static_metacall,
    nullptr,
    qt_staticMetaObjectRelocatingContent<qt_meta_tag_ZN16WeatherViewModelE_t>.metaTypes,
    nullptr
} };

void WeatherViewModel::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = static_cast<WeatherViewModel *>(_o);
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: _t->stateChanged(); break;
        case 1: _t->dataChanged(); break;
        case 2: _t->errorMessageChanged(); break;
        case 3: _t->splashDoneChanged(); break;
        case 4: _t->handleWeatherData((*reinterpret_cast<std::add_pointer_t<WeatherData>>(_a[1]))); break;
        case 5: _t->handleError((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1]))); break;
        case 6: _t->fetchWeather((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1]))); break;
        case 7: _t->refresh(); break;
        default: ;
        }
    }
    if (_c == QMetaObject::IndexOfMethod) {
        if (QtMocHelpers::indexOfMethod<void (WeatherViewModel::*)()>(_a, &WeatherViewModel::stateChanged, 0))
            return;
        if (QtMocHelpers::indexOfMethod<void (WeatherViewModel::*)()>(_a, &WeatherViewModel::dataChanged, 1))
            return;
        if (QtMocHelpers::indexOfMethod<void (WeatherViewModel::*)()>(_a, &WeatherViewModel::errorMessageChanged, 2))
            return;
        if (QtMocHelpers::indexOfMethod<void (WeatherViewModel::*)()>(_a, &WeatherViewModel::splashDoneChanged, 3))
            return;
    }
    if (_c == QMetaObject::ReadProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast<int*>(_v) = _t->appState(); break;
        case 1: *reinterpret_cast<bool*>(_v) = _t->isLoading(); break;
        case 2: *reinterpret_cast<bool*>(_v) = _t->splashDone(); break;
        case 3: *reinterpret_cast<QString*>(_v) = _t->errorMessage(); break;
        case 4: *reinterpret_cast<QString*>(_v) = _t->cityName(); break;
        case 5: *reinterpret_cast<QString*>(_v) = _t->country(); break;
        case 6: *reinterpret_cast<int*>(_v) = _t->pressure(); break;
        case 7: *reinterpret_cast<double*>(_v) = _t->temperature(); break;
        case 8: *reinterpret_cast<double*>(_v) = _t->feelsLike(); break;
        case 9: *reinterpret_cast<double*>(_v) = _t->tempMin(); break;
        case 10: *reinterpret_cast<double*>(_v) = _t->tempMax(); break;
        case 11: *reinterpret_cast<int*>(_v) = _t->humidity(); break;
        case 12: *reinterpret_cast<double*>(_v) = _t->windSpeed(); break;
        case 13: *reinterpret_cast<QString*>(_v) = _t->condition(); break;
        case 14: *reinterpret_cast<QString*>(_v) = _t->description(); break;
        default: break;
        }
    }
}

const QMetaObject *WeatherViewModel::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *WeatherViewModel::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_staticMetaObjectStaticContent<qt_meta_tag_ZN16WeatherViewModelE_t>.strings))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int WeatherViewModel::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 8)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 8;
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 8)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 8;
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
void WeatherViewModel::stateChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}

// SIGNAL 1
void WeatherViewModel::dataChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 1, nullptr);
}

// SIGNAL 2
void WeatherViewModel::errorMessageChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 2, nullptr);
}

// SIGNAL 3
void WeatherViewModel::splashDoneChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 3, nullptr);
}
QT_WARNING_POP
