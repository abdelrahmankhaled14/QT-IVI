#pragma once
#include <QDBusVirtualObject>
#include <QDBusConnection>
#include <QDBusMessage>
#include <QDBusObjectPath>
#include <QDBusInterface>
#include <QDebug>

// ─── BluetoothAgent ────────────────────────────────────────────────────────────
//
// A real org.bluez.Agent1 implementation using QDBusVirtualObject.
// Registered at AGENT_PATH on the system bus so BlueZ can actually call back.
//
// Capability "NoInputNoOutput" → just-works pairing:
//   - Auto-confirm RequestConfirmation (no PIN shown to user)
//   - Return "0000" for RequestPinCode (legacy PIN devices)
//   - Return 0 for RequestPasskey
//   - Auto-authorize AuthorizeService (A2DP, HFP, etc.)
// ─────────────────────────────────────────────────────────────────────────────
class BluetoothAgent : public QDBusVirtualObject
{
    Q_OBJECT
public:
    static constexpr const char* PATH = "/org/ivi/bluetooth/agent";

    explicit BluetoothAgent(QObject *parent = nullptr)
        : QDBusVirtualObject(parent) {}

    // Register on the system bus. Returns true on success.
    bool registerAgent()
    {
        QDBusConnection bus = QDBusConnection::systemBus();

        if (!bus.registerVirtualObject(PATH, this,
                QDBusConnection::VirtualObjectRegisterOption::SingleNode)) {
            qWarning() << "[BTAgent] registerVirtualObject failed:"
                       << bus.lastError().message();
            return false;
        }

        QDBusMessage reg = QDBusMessage::createMethodCall(
            "org.bluez", "/org/bluez", "org.bluez.AgentManager1", "RegisterAgent");
        reg << QVariant::fromValue(QDBusObjectPath(PATH))
            << QString("NoInputNoOutput");

        QDBusMessage r1 = bus.call(reg);
        if (r1.type() == QDBusMessage::ErrorMessage)
            qWarning() << "[BTAgent] RegisterAgent:" << r1.errorMessage();

        QDBusMessage def = QDBusMessage::createMethodCall(
            "org.bluez", "/org/bluez", "org.bluez.AgentManager1", "RequestDefaultAgent");
        def << QVariant::fromValue(QDBusObjectPath(PATH));
        bus.call(def);   // best-effort

        qDebug() << "[BTAgent] Registered at" << PATH;
        return true;
    }

    // ── QDBusVirtualObject interface ─────────────────────────────────────────
    QString introspect(const QString &) const override
    {
        return R"(
<interface name="org.bluez.Agent1">
  <method name="Release"/>
  <method name="RequestPinCode">
    <arg name="device"  type="o" direction="in"/>
    <arg name="pincode" type="s" direction="out"/>
  </method>
  <method name="DisplayPinCode">
    <arg name="device"  type="o" direction="in"/>
    <arg name="pincode" type="s" direction="in"/>
  </method>
  <method name="RequestPasskey">
    <arg name="device"   type="o" direction="in"/>
    <arg name="passkey"  type="u" direction="out"/>
  </method>
  <method name="DisplayPasskey">
    <arg name="device"  type="o" direction="in"/>
    <arg name="passkey" type="u" direction="in"/>
    <arg name="entered" type="q" direction="in"/>
  </method>
  <method name="RequestConfirmation">
    <arg name="device"  type="o" direction="in"/>
    <arg name="passkey" type="u" direction="in"/>
  </method>
  <method name="RequestAuthorization">
    <arg name="device" type="o" direction="in"/>
  </method>
  <method name="AuthorizeService">
    <arg name="device" type="o" direction="in"/>
    <arg name="uuid"   type="s" direction="in"/>
  </method>
  <method name="Cancel"/>
</interface>
)";
    }

    bool handleMessage(const QDBusMessage &msg,
                       const QDBusConnection &conn) override
    {
        if (msg.type()      != QDBusMessage::MethodCallMessage) return false;
        if (msg.interface() != QLatin1String("org.bluez.Agent1")) return false;

        const QString method = msg.member();
        qDebug() << "[BTAgent]" << method;

        if (method == QLatin1String("RequestPinCode")) {
            conn.send(msg.createReply(QString("0000")));
            return true;
        }
        if (method == QLatin1String("RequestPasskey")) {
            conn.send(msg.createReply(QVariant::fromValue(quint32(0))));
            return true;
        }
        if (method == QLatin1String("RequestConfirmation") ||
            method == QLatin1String("RequestAuthorization") ||
            method == QLatin1String("AuthorizeService")     ||
            method == QLatin1String("DisplayPinCode")       ||
            method == QLatin1String("DisplayPasskey")       ||
            method == QLatin1String("Release")              ||
            method == QLatin1String("Cancel")) {
            conn.send(msg.createReply());
            return true;
        }

        return false;
    }
};
