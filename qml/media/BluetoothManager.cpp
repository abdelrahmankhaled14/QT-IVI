#include "BluetoothManager.h"

#include <QDBusReply>
#include <QDBusArgument>
#include <QDBusMetaType>
#include <QDebug>
#include <QTimer>
#include <QProcess>

#include <QDBusPendingCall>
#include <QDBusPendingCallWatcher>
#include <QDBusPendingReply>

// GStreamer headers
#include <gst/gst.h>

// ─── BlueZ D-Bus constants ────────────────────────────────────────────────────
static const char* BLUEZ_SERVICE   = "org.bluez";
static const char* BLUEZ_ADAPTER   = "org.bluez.Adapter1";
static const char* BLUEZ_DEVICE    = "org.bluez.Device1";
static const char* BLUEZ_PLAYER    = "org.bluez.MediaPlayer1";   // AVRCP
static const char* DBUS_PROPS      = "org.freedesktop.DBus.Properties";
static const char* DBUS_OBJ_MGR    = "org.freedesktop.DBus.ObjectManager";

// ─── Constructor ─────────────────────────────────────────────────────────────

BluetoothManager::BluetoothManager(QObject *parent) : QObject(parent)
{
    // Initialise GStreamer (safe to call multiple times)
    gst_init(nullptr, nullptr);

    m_scanTimer = new QTimer(this);
    m_scanTimer->setSingleShot(true);
    m_scanTimer->setInterval(15000);
    connect(m_scanTimer, &QTimer::timeout, this, &BluetoothManager::onScanTimeout);

    m_gstTimer = new QTimer(this);
    m_gstTimer->setInterval(100);
    connect(m_gstTimer, &QTimer::timeout, this, &BluetoothManager::onPollTimer);

    updateStatus("Initialising Bluetooth…");
    initDBus();
}

BluetoothManager::~BluetoothManager()
{
    stopGStreamer();
}

// ─── D-Bus initialisation ─────────────────────────────────────────────────────

// ─── D-Bus initialisation ─────────────────────────────────────────────────────

void BluetoothManager::initDBus()
{
    if (!m_bus.isConnected()) {
        updateStatus("Cannot connect to system D-Bus.");
        return;
    }

    // Single raw call — GetManagedObjects returns a{oa{sa{sv}}}
    QDBusMessage msg = m_bus.call(
        QDBusMessage::createMethodCall(
            BLUEZ_SERVICE, "/", DBUS_OBJ_MGR, "GetManagedObjects"));

    if (msg.type() == QDBusMessage::ErrorMessage) {
        updateStatus("BlueZ not running. Run: sudo systemctl start bluetooth");
        return;
    }

    if (msg.arguments().isEmpty()) {
        updateStatus("No BlueZ objects found.");
        return;
    }

    // a{oa{sa{sv}}}
    const QDBusArgument &topArg =
        *reinterpret_cast<const QDBusArgument*>(msg.arguments().at(0).constData());

    topArg.beginMap();
    while (!topArg.atEnd()) {
        QString path;
        topArg.beginMapEntry();
        topArg >> path;                          // o  (object path as string)

        // a{sa{sv}}  — interface map
        QMap<QString, QMap<QString, QVariant>> interfaces;
        topArg.beginMap();                        // begin outer interface map
        while (!topArg.atEnd()) {
            QString iface;
            topArg.beginMapEntry();
            topArg >> iface;

            // a{sv}  — property map
            QMap<QString, QVariant> props;
            topArg.beginMap();
            while (!topArg.atEnd()) {
                QString key;
                QDBusVariant val;
                topArg.beginMapEntry();
                topArg >> key >> val;
                props[key] = val.variant();
                topArg.endMapEntry();
            }
            topArg.endMap();

            interfaces[iface] = props;
            topArg.endMapEntry();
        }
        topArg.endMap();                          // end interface map
        topArg.endMapEntry();

        // ── Adapter ──
        if (interfaces.contains(BLUEZ_ADAPTER) && m_adapterPath.isEmpty())
            m_adapterPath = path;

        // ── Device ──
        if (interfaces.contains(BLUEZ_DEVICE)) {
            const auto &props = interfaces[BLUEZ_DEVICE];
            QString address = props.value("Address", "").toString();
            QString name    = props.value("Alias",   props.value("Name", "")).toString();
            bool    paired  = props.value("Paired",  false).toBool();
            bool    conn    = props.value("Connected", false).toBool();

            if (!address.isEmpty())
                addOrUpdateDevice(address, name, paired);

            if (conn && m_connectedAddress.isEmpty()) {
                m_connected        = true;
                m_connectedAddress = address;
                m_connectedDevice  = name.isEmpty() ? address : name;
                m_connectedPath    = path;
                emit connectedChanged();
                startGStreamer(address);
            }
        }

        // ── AVRCP MediaPlayer (phone already streaming at startup) ──
        if (interfaces.contains(BLUEZ_PLAYER))
            setPlayerPath(path, interfaces[BLUEZ_PLAYER]);
    }
    topArg.endMap();

    if (m_adapterPath.isEmpty()) {
        updateStatus("No Bluetooth adapter found. Is one plugged in?");
        return;
    }

    m_bluetoothAvailable = true;
    emit bluetoothAvailableChanged();

    // ── Signal connections ──
    // InterfacesAdded: sender, path, interface, name, args
    m_bus.connect(BLUEZ_SERVICE, "/",
                  DBUS_OBJ_MGR, "InterfacesAdded",
                  this, SLOT(onInterfacesAdded(QDBusMessage)));

    // InterfacesRemoved: used to drop the AVRCP player when it goes away
    m_bus.connect(BLUEZ_SERVICE, "/",
                  DBUS_OBJ_MGR, "InterfacesRemoved",
                  this, SLOT(onInterfacesRemoved(QDBusMessage)));

    // PropertiesChanged on any BlueZ path
    m_bus.connect(BLUEZ_SERVICE, "",
                  "org.freedesktop.DBus.Properties", "PropertiesChanged",
                  this, SLOT(onPropertiesChanged(QDBusMessage)));

    // Discoverable state
    QDBusInterface props(BLUEZ_SERVICE, m_adapterPath, DBUS_PROPS, m_bus);
    QDBusReply<QDBusVariant> discReply =
        props.call("Get", QString(BLUEZ_ADAPTER), QString("Discoverable"));
    if (discReply.isValid())
        m_discoverable = discReply.value().variant().toBool();
    // Register a real BlueZ agent so pairing callbacks are handled properly
    m_agent.registerAgent();

    updateStatus("Bluetooth ready. Tap 'Make Discoverable' so your phone can find this device.");
}

// registerAgent() removed — registering a ghost path causes "invalid pin value"
// errors because BlueZ routes pairing requests to our path but no D-Bus object
// exists there to respond. Let the system's default BlueZ agent handle pairing.

// ─── Public invokables ────────────────────────────────────────────────────────

void BluetoothManager::startScan()
{
    if (!m_bluetoothAvailable || m_adapterPath.isEmpty()) return;
    if (m_scanning) return;

    QDBusInterface adapter(BLUEZ_SERVICE, m_adapterPath, BLUEZ_ADAPTER, m_bus);
    adapter.call("StartDiscovery");

    m_scanning = true;
    emit scanningChanged();
    updateStatus("Scanning for devices (15 s)…");
    m_scanTimer->start();
}

void BluetoothManager::stopScan()
{
    if (!m_scanning) return;
    m_scanTimer->stop();
    onScanTimeout();
}

void BluetoothManager::connectDevice(const QString &address)
{
    if (!m_bluetoothAvailable || address.isEmpty()) return;

    QString path = addressToPath(address);
    updateStatus("Connecting to " + address + "…");

    for (const QVariant &v : std::as_const(m_devices)) {
        QVariantMap d = v.toMap();
        if (d["address"].toString() == address) {
            m_connectedDevice = d["name"].toString();
            break;
        }
    }
    m_connectedAddress = address;
    m_connectedPath    = path;

    // Check if already paired — skip Pair() if so
    QDBusInterface propsIface(BLUEZ_SERVICE, path, DBUS_PROPS, m_bus);
    QDBusReply<QDBusVariant> pairedReply =
        propsIface.call("Get", QString(BLUEZ_DEVICE), QString("Paired"));

    bool alreadyPaired = pairedReply.isValid() &&
                         pairedReply.value().variant().toBool();

    if (alreadyPaired) {
        doConnect(path);
        return;
    }

    // Async pair — won't block UI while phone shows confirmation
    updateStatus("Check your phone and confirm the pairing request…");

    QDBusInterface dev(BLUEZ_SERVICE, path, BLUEZ_DEVICE, m_bus);
    QDBusPendingCall pairCall = dev.asyncCall("Pair");
    QDBusPendingCallWatcher *watcher =
        new QDBusPendingCallWatcher(pairCall, this);

    connect(watcher, &QDBusPendingCallWatcher::finished,
            this, [this, path, watcher]() {
                watcher->deleteLater();
                QDBusPendingReply<> reply = *watcher;

                if (reply.isError()) {
                    QString err = reply.error().message();
                    if (err.contains("Already Exists") || err.contains("AlreadyExists")) {
                        m_connectRetryCount = 0;
                        QTimer::singleShot(300, this, [this, path]() { doConnect(path); });
                    } else {
                        updateStatus("Pairing failed: " + err);
                        m_connectedAddress.clear();
                        m_connectedPath.clear();
                    }
                    return;
                }

                // Pairing succeeded — trust device, then wait 500 ms before connecting
                // (phones need time to set up A2DP/HFP profiles after pairing)
                QDBusInterface propsIface(BLUEZ_SERVICE, path, DBUS_PROPS, m_bus);
                propsIface.call("Set", QString(BLUEZ_DEVICE), QString("Trusted"),
                                QVariant::fromValue(QDBusVariant(true)));
                m_connectRetryCount = 0;
                updateStatus("Paired! Waiting for profiles to be ready…");
                QTimer::singleShot(500, this, [this, path]() { doConnect(path); });
            });
}
void BluetoothManager::doConnect(const QString &path)
{
    updateStatus("Paired! Connecting…");

    QDBusInterface dev(BLUEZ_SERVICE, path, BLUEZ_DEVICE, m_bus);
    QDBusPendingCall connCall = dev.asyncCall("Connect");
    QDBusPendingCallWatcher *watcher =
        new QDBusPendingCallWatcher(connCall, this);

    connect(watcher, &QDBusPendingCallWatcher::finished,
            this, [this, watcher]() {
                watcher->deleteLater();
                QDBusPendingReply<> reply = *watcher;

                if (reply.isError()) {
                    QString err = reply.error().message();
                    // Retry up to 2 times for transient "not ready" errors
                    bool transient = err.contains("Resource") ||
                                     err.contains("NotReady") ||
                                     err.contains("not ready") ||
                                     err.contains("Protocol not available") ||
                                     err.contains("Profile") ||
                                     err.contains("in progress", Qt::CaseInsensitive);
                    if (transient && m_connectRetryCount < 2) {
                        m_connectRetryCount++;
                        updateStatus(QString("Profile not ready, retrying (%1/2)…").arg(m_connectRetryCount));
                        QString retryPath = m_connectedPath;
                        QTimer::singleShot(1500, this, [this, retryPath]() { doConnect(retryPath); });
                        return;
                    }
                    updateStatus("Connect failed: " + err);
                    m_connectRetryCount = 0;
                    m_connectedAddress.clear();
                    m_connectedPath.clear();
                    return;
                }
                m_connectRetryCount = 0;

                m_connected = true;
                emit connectedChanged();
                updateStatus("Connected to " + m_connectedDevice + ". Looking for audio source…");
                checkHfpProfile(m_connectedPath);
                findBtSourceAndStart(m_connectedAddress);
            });
}
void BluetoothManager::disconnectDevice()
{
    if (!m_connected || m_connectedPath.isEmpty()) return;
    stopGStreamer();
    clearPlayer();

    QDBusInterface dev(BLUEZ_SERVICE, m_connectedPath, BLUEZ_DEVICE, m_bus);
    dev.call("Disconnect");

    m_connected       = false;
    m_connectedDevice.clear();
    m_connectedAddress.clear();
    m_connectedPath.clear();
    emit connectedChanged();
    updateStatus("Disconnected.");
}

void BluetoothManager::setDiscoverable(bool on)
{
    if (!m_bluetoothAvailable || m_adapterPath.isEmpty()) return;

    QDBusInterface props(BLUEZ_SERVICE, m_adapterPath, DBUS_PROPS, m_bus);
    props.call("Set", QString(BLUEZ_ADAPTER), QString("Discoverable"),
               QVariant::fromValue(QDBusVariant(on)));
    props.call("Set", QString(BLUEZ_ADAPTER), QString("Pairable"),
               QVariant::fromValue(QDBusVariant(on)));

    m_discoverable = on;
    emit discoverableChanged();

    if (on)
        updateStatus("Discoverable ON — open Bluetooth on your phone, find this device and tap it to pair.");
    else
        updateStatus("Discoverable off.");
}

void BluetoothManager::setVolume(int vol)
{
    m_volume = qBound(0, vol, 100);
    emit volumeChanged();

    if (m_volume_el) {
        double v = m_volume / 100.0;
        g_object_set(G_OBJECT(m_volume_el), "volume", v, nullptr);
    }
}

// ─── GStreamer / audio source ─────────────────────────────────────────────────

// Force PulseAudio to activate the A2DP profile for the connected BT card.
static void activateA2dpProfile(const QString &addr)
{
    // Find the bluez card index for this address then set its profile to a2dp_sink
    auto *proc = new QProcess();
    proc->start("pactl", QStringList() << "list" << "cards" << "short");
    QObject::connect(proc,
                     QOverload<int,QProcess::ExitStatus>::of(&QProcess::finished),
                     proc, [proc, addr](int) {
        QString out = QString::fromUtf8(proc->readAllStandardOutput());
        proc->deleteLater();
        QString needle = QString(addr).toLower().replace(":", "_");
        for (const QString &line : out.split('\n')) {
            QStringList cols = line.split('\t');
            if (cols.size() < 2) continue;
            QString cardName = cols.value(1).trimmed().toLower();
            if (cardName.contains(needle) || cardName.contains("bluez")) {
                QString idx = cols.value(0).trimmed();
                // Try a2dp_sink first, then a2dp-sink, then a2dp
                QProcess::startDetached("pactl",
                    QStringList() << "set-card-profile" << idx << "a2dp_sink");
                qDebug() << "[BT] Activated a2dp_sink on card" << idx;
                return;
            }
        }
        qDebug() << "[BT] No bluez card found in pactl yet";
    });
}

// Use pactl to find the exact PulseAudio source BlueZ created, with retries.
static void findPactlSource(const QString &addr,
                             std::function<void(const QString&)> cb)
{
    auto *proc = new QProcess();
    proc->start("pactl", QStringList() << "list" << "sources" << "short");
    QObject::connect(proc,
                     QOverload<int,QProcess::ExitStatus>::of(&QProcess::finished),
                     proc, [proc, addr, cb](int) {
        QString out = QString::fromUtf8(proc->readAllStandardOutput());
        proc->deleteLater();
        QString needle = QString(addr).toUpper().replace(":", "_");
        QString needleLo = needle.toLower();
        for (const QString &line : out.split('\n')) {
            QString name = line.split('\t').value(1).trimmed();
            if (name.isEmpty()) continue;
            QString nameLo = name.toLower();
            // Match by address, or any bluez source/input (but not .monitor)
            if (nameLo.contains(needleLo)
                || (nameLo.contains("bluez") && !nameLo.contains(".monitor")
                    && (nameLo.contains("source") || nameLo.contains("input")))) {
                cb(name);
                return;
            }
        }
        cb(QString());
    });
}

void BluetoothManager::findBtSourceAndStart(const QString &address, int attempt)
{
    // Kick A2DP profile activation on first attempt
    if (attempt == 0)
        activateA2dpProfile(address);

    findPactlSource(address, [this, address, attempt](const QString &src) {
        if (!src.isEmpty()) {
            qDebug() << "[BT] Found PulseAudio source:" << src;
            startGStreamer(address, src);
            return;
        }
        if (attempt < 6) {
            updateStatus(QString("Waiting for audio source (%1/6)…").arg(attempt + 1));
            QTimer::singleShot(1500, this, [this, address, attempt]() {
                findBtSourceAndStart(address, attempt + 1);
            });
        } else {
            // Best-guess fallback — common PulseAudio bluez naming
            QString addrU = QString(address).toUpper().replace(":", "_");
            QString addrL = QString(address).toLower().replace(":", "_");
            // Try lowercase form (PipeWire) then uppercase (legacy PulseAudio)
            QString src1 = QString("bluez_input.%1.0").arg(addrL);
            QString src2 = QString("bluez_source.%1.a2dp_source").arg(addrU);
            qDebug() << "[BT] Fallback pipeline with" << src1;
            startGStreamer(address, src1, src2);
        }
    });
}

void BluetoothManager::retryAudio()
{
    if (!m_connected || m_connectedAddress.isEmpty()) return;
    m_connectRetryCount = 0;
    updateStatus("Retrying audio…");
    stopGStreamer();
    findBtSourceAndStart(m_connectedAddress, 0);
}

void BluetoothManager::startGStreamer(const QString &btAddress,
                                      const QString &sourceName,
                                      const QString &fallbackSource)
{
    stopGStreamer();
    m_gstFallbackSource  = fallbackSource;
    m_gstCurrentAddress  = btAddress;
    double vol = m_volume / 100.0;

    QString pipelineStr;
    if (!sourceName.isEmpty()) {
        pipelineStr = QString(
            "pulsesrc device=\"%1\" ! audioconvert ! audioresample ! "
            "queue max-size-time=200000000 ! volume name=vol volume=%2 ! autoaudiosink"
        ).arg(sourceName).arg(vol);
    } else {
        // No source name at all — let PulseAudio pick the default BT source
        pipelineStr = QString(
            "pulsesrc ! audioconvert ! audioresample ! "
            "queue max-size-time=200000000 ! volume name=vol volume=%2 ! autoaudiosink"
        ).arg(vol);
    }

    qDebug() << "[BT] Pipeline:" << pipelineStr;
    GError *err = nullptr;
    m_pipeline = gst_parse_launch(pipelineStr.toUtf8().constData(), &err);
    if (!m_pipeline || err) {
        updateStatus("Audio pipeline error: " + (err ? QString::fromUtf8(err->message) : "failed"));
        if (err) g_error_free(err);
        if (!m_gstFallbackSource.isEmpty()) {
            QString fb = m_gstFallbackSource;
            m_gstFallbackSource.clear();
            QTimer::singleShot(500, this, [this, fb]() {
                startGStreamer(m_gstCurrentAddress, fb);
            });
        }
        return;
    }
    m_volume_el = gst_bin_get_by_name(GST_BIN(m_pipeline), "vol");
    gst_element_set_state(m_pipeline, GST_STATE_PLAYING);
    m_gstTimer->start();
    m_playing = true;
    emit playingChanged();
    updateStatus("Streaming audio from " + m_connectedDevice);
}

// ─── HFP profile check ────────────────────────────────────────────────────────
void BluetoothManager::checkHfpProfile(const QString &path)
{
    QDBusInterface propsIface(BLUEZ_SERVICE, path, DBUS_PROPS, m_bus);
    QDBusReply<QDBusVariant> reply =
        propsIface.call("Get", QString(BLUEZ_DEVICE), QString("UUIDs"));

    bool hfp = false;
    if (reply.isValid()) {
        const QStringList uuids = reply.value().variant().toStringList();
        for (const QString &uuid : uuids) {
            if (uuid.startsWith("0000111e", Qt::CaseInsensitive) ||
                uuid.startsWith("0000111f", Qt::CaseInsensitive)) {
                hfp = true; break;
            }
        }
    }
    if (m_hfpConnected != hfp) {
        m_hfpConnected = hfp;
        emit hfpConnectedChanged();
    }
}

void BluetoothManager::stopGStreamer()
{
    m_gstTimer->stop();

    if (m_pipeline) {
        gst_element_set_state(m_pipeline, GST_STATE_NULL);
        if (m_volume_el) {
            gst_object_unref(m_volume_el);
            m_volume_el = nullptr;
        }
        gst_object_unref(m_pipeline);
        m_pipeline = nullptr;
    }

    if (m_playing) {
        m_playing = false;
        emit playingChanged();
    }
}

// ─── Scan timeout ─────────────────────────────────────────────────────────────

void BluetoothManager::onScanTimeout()
{
    if (!m_adapterPath.isEmpty()) {
        QDBusInterface adapter(BLUEZ_SERVICE, m_adapterPath, BLUEZ_ADAPTER, m_bus);
        adapter.call("StopDiscovery");
    }
    m_scanning = false;
    emit scanningChanged();
    updateStatus("Scan complete — found " +
                 QString::number(m_devices.size()) +
                 " device(s). Tap one to connect.");
}

// ─── GStreamer bus poll ───────────────────────────────────────────────────────

void BluetoothManager::onPollTimer()
{
    if (!m_pipeline) return;

    GstBus *bus = gst_element_get_bus(m_pipeline);
    GstMessage *msg;

    while ((msg = gst_bus_pop(bus)) != nullptr) {
        switch (GST_MESSAGE_TYPE(msg)) {
        case GST_MESSAGE_ERROR: {
            GError *err = nullptr;
            gchar  *dbg = nullptr;
            gst_message_parse_error(msg, &err, &dbg);
            QString errStr = err ? QString::fromUtf8(err->message) : "GStreamer error";
            if (err) g_error_free(err);
            if (dbg) g_free(dbg);
            gst_message_unref(msg);
            gst_object_unref(bus);
            QString fb = m_gstFallbackSource;
            QString addr = m_gstCurrentAddress;
            m_gstFallbackSource.clear();
            stopGStreamer();
            if (!fb.isEmpty()) {
                updateStatus("Retrying audio with fallback source…");
                QTimer::singleShot(500, this, [this, addr, fb]() {
                    startGStreamer(addr, fb);
                });
            } else {
                updateStatus("Audio error: " + errStr);
            }
            return;
        }
        case GST_MESSAGE_EOS:
            // End of stream — phone stopped sending audio
            stopGStreamer();
            updateStatus("Audio stream ended (phone paused/stopped).");
            break;
        default:
            break;
        }
        gst_message_unref(msg);
    }
    gst_object_unref(bus);
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

void BluetoothManager::updateStatus(const QString &msg)
{
    m_statusMsg = msg;
    emit statusChanged();
    qDebug() << "[BT]" << msg;
}

void BluetoothManager::addOrUpdateDevice(const QString &address,
                                         const QString &name,
                                         bool paired)
{
    if (address.isEmpty()) return;
    QString displayName = name.isEmpty() ? address : name;

    for (int i = 0; i < m_devices.size(); ++i) {
        QVariantMap d = m_devices[i].toMap();
        if (d["address"].toString() == address) {
            d["name"]   = displayName;
            if (paired) d["paired"] = true;
            m_devices[i] = d;
            emit devicesChanged();
            return;
        }
    }

    QVariantMap dev;
    dev["name"]    = displayName;
    dev["address"] = address;
    dev["paired"]  = paired;
    m_devices.append(dev);
    emit devicesChanged();
}

// Converts "AA:BB:CC:DD:EE:FF"  →  "/org/bluez/hci0/dev_AA_BB_CC_DD_EE_FF"
QString BluetoothManager::addressToPath(const QString &address) const
{
    QString a = address;
    a.replace(":", "_");
    return m_adapterPath + "/dev_" + a;
}

void BluetoothManager::onInterfacesAdded(const QDBusMessage &msg)
{
    if (msg.arguments().size() < 2) return;

    QString path = msg.arguments().at(0).value<QDBusObjectPath>().path();
    const QDBusArgument &ifaceArg =
        *reinterpret_cast<const QDBusArgument*>(msg.arguments().at(1).constData());

    ifaceArg.beginMap();
    while (!ifaceArg.atEnd()) {
        QString iface;
        ifaceArg.beginMapEntry();
        ifaceArg >> iface;

        QMap<QString, QVariant> props;
        ifaceArg.beginMap();
        while (!ifaceArg.atEnd()) {
            QString key; QDBusVariant val;
            ifaceArg.beginMapEntry();
            ifaceArg >> key >> val;
            props[key] = val.variant();
            ifaceArg.endMapEntry();
        }
        ifaceArg.endMap();
        ifaceArg.endMapEntry();

        if (iface == BLUEZ_DEVICE) {
            QString address = props.value("Address", "").toString();
            QString name    = props.value("Alias", props.value("Name", "")).toString();
            bool    paired  = props.value("Paired", false).toBool();
            if (!address.isEmpty())
                addOrUpdateDevice(address, name, paired);
        }

        // ── AVRCP MediaPlayer appeared (phone started its media player) ──
        if (iface == BLUEZ_PLAYER)
            setPlayerPath(path, props);
    }
    ifaceArg.endMap();
}

// InterfacesRemoved(o path, as interfaces) — drop the AVRCP player when gone.
void BluetoothManager::onInterfacesRemoved(const QDBusMessage &msg)
{
    if (msg.arguments().isEmpty()) return;
    const QString path = msg.arguments().at(0).value<QDBusObjectPath>().path();
    if (!path.isEmpty() && path == m_playerPath)
        clearPlayer();
}

void BluetoothManager::onPropertiesChanged(const QDBusMessage &msg)
{
    if (msg.arguments().size() < 2) return;
    const QString iface = msg.arguments().at(0).toString();
    if (iface != BLUEZ_DEVICE && iface != BLUEZ_PLAYER) return;

    const QDBusArgument &propsArg =
        *reinterpret_cast<const QDBusArgument*>(msg.arguments().at(1).constData());

    QMap<QString, QVariant> changed;
    propsArg.beginMap();
    while (!propsArg.atEnd()) {
        QString key; QDBusVariant val;
        propsArg.beginMapEntry();
        propsArg >> key >> val;
        changed[key] = val.variant();
        propsArg.endMapEntry();
    }
    propsArg.endMap();

    // ── AVRCP player (phone's media player) updates ──
    if (iface == BLUEZ_PLAYER) {
        if (m_playerPath.isEmpty())
            setPlayerPath(msg.path(), changed);
        else if (msg.path() == m_playerPath) {
            if (changed.contains("Track"))  parseTrack(changed.value("Track"));
            if (changed.contains("Status")) applyAvrcpStatus(changed.value("Status").toString());
        }
        return;
    }

    const QString devPath = msg.path();

    // ── Pairing status changed (e.g. user paired from the phone side) ──
    // BlueZ fires this with "Paired" (and no "Connected"), so handle it before
    // the Connected-only early-return below, otherwise the app never shows the
    // device as paired.
    if (changed.contains("Paired") || changed.contains("Alias") || changed.contains("Name")) {
        QDBusInterface p(BLUEZ_SERVICE, devPath, DBUS_PROPS, m_bus);
        QDBusReply<QDBusVariant> addrR = p.call("Get", QString(BLUEZ_DEVICE), QString("Address"));
        QDBusReply<QDBusVariant> nameR = p.call("Get", QString(BLUEZ_DEVICE), QString("Alias"));
        QDBusReply<QDBusVariant> pairR = p.call("Get", QString(BLUEZ_DEVICE), QString("Paired"));
        if (addrR.isValid()) {
            const QString addr  = addrR.value().variant().toString();
            const QString name  = nameR.isValid() ? nameR.value().variant().toString() : addr;
            const bool    pair  = pairR.isValid() && pairR.value().variant().toBool();
            addOrUpdateDevice(addr, name, pair);
        }
    }

    if (!changed.contains("Connected")) return;

    bool conn = changed["Connected"].toBool();
    if (conn && !m_connected) {
        QString path = msg.path();
        QDBusInterface propsIface(BLUEZ_SERVICE, path, DBUS_PROPS, m_bus);
        QDBusReply<QDBusVariant> addrR =
            propsIface.call("Get", QString(BLUEZ_DEVICE), QString("Address"));
        QDBusReply<QDBusVariant> nameR =
            propsIface.call("Get", QString(BLUEZ_DEVICE), QString("Alias"));

        m_connectedAddress = addrR.isValid() ? addrR.value().variant().toString() : "";
        m_connectedDevice  = nameR.isValid() ? nameR.value().variant().toString()
                                            : m_connectedAddress;
        m_connectedPath    = path;
        m_connected        = true;
        emit connectedChanged();
        updateStatus(m_connectedDevice + " connected. Looking for audio source…");
        checkHfpProfile(m_connectedPath);
        findBtSourceAndStart(m_connectedAddress);

    } else if (!conn && m_connected) {
        stopGStreamer();
        clearPlayer();
        m_connected = false;
        m_connectedDevice.clear();
        m_connectedAddress.clear();
        m_connectedPath.clear();
        emit connectedChanged();
        updateStatus("Device disconnected.");
    }
}

// ─── AVRCP — control the phone's media player over Bluetooth ──────────────────

void BluetoothManager::setPlayerPath(const QString &path,
                                     const QMap<QString, QVariant> &props)
{
    if (path.isEmpty()) return;
    const bool isNew = (m_playerPath != path);
    m_playerPath = path;

    // Initial Track metadata — from the signal payload if present, else fetch it.
    if (props.contains("Track")) {
        parseTrack(props.value("Track"));
    } else {
        QDBusInterface p(BLUEZ_SERVICE, path, DBUS_PROPS, m_bus);
        QDBusReply<QDBusVariant> tr =
            p.call("Get", QString(BLUEZ_PLAYER), QString("Track"));
        if (tr.isValid()) parseTrack(tr.value().variant());
    }

    // Initial playback Status
    QString status = props.value("Status").toString();
    if (status.isEmpty()) {
        QDBusInterface p(BLUEZ_SERVICE, path, DBUS_PROPS, m_bus);
        QDBusReply<QDBusVariant> st =
            p.call("Get", QString(BLUEZ_PLAYER), QString("Status"));
        if (st.isValid()) status = st.value().variant().toString();
    }

    if (isNew) {
        qDebug() << "[BT] AVRCP player available at" << path;
        emit avrcpChanged();
    }
    if (!status.isEmpty()) applyAvrcpStatus(status);
}

void BluetoothManager::clearPlayer()
{
    if (m_playerPath.isEmpty() && m_trackTitle.isEmpty() &&
        m_trackArtist.isEmpty() && m_avrcpStatus.isEmpty())
        return;

    m_playerPath.clear();
    m_avrcpStatus.clear();
    m_trackTitle.clear();
    m_trackArtist.clear();
    m_trackAlbum.clear();
    emit trackChanged();
    emit avrcpChanged();
}

void BluetoothManager::callPlayer(const QString &method)
{
    if (m_playerPath.isEmpty()) {
        updateStatus("No media control available on the connected phone.");
        return;
    }
    QDBusInterface player(BLUEZ_SERVICE, m_playerPath, BLUEZ_PLAYER, m_bus);
    player.asyncCall(method);
    qDebug() << "[BT] AVRCP" << method;
}

void BluetoothManager::applyAvrcpStatus(const QString &status)
{
    if (m_avrcpStatus != status) {
        m_avrcpStatus = status;
        emit avrcpChanged();
    }
    // When the phone resumes playback, make sure our audio pipeline is running
    // again — it gets torn down on EOS when the phone pauses/stops.
    if (status == "playing" && m_connected && !m_pipeline &&
        !m_connectedAddress.isEmpty()) {
        findBtSourceAndStart(m_connectedAddress, 0);
    }
}

void BluetoothManager::parseTrack(const QVariant &trackVariant)
{
    QMap<QString, QVariant> track;

    if (trackVariant.canConvert<QDBusArgument>()) {
        QDBusArgument arg = trackVariant.value<QDBusArgument>();
        arg.beginMap();
        while (!arg.atEnd()) {
            QString key; QDBusVariant val;
            arg.beginMapEntry();
            arg >> key >> val;
            arg.endMapEntry();
            track[key] = val.variant();
        }
        arg.endMap();
    } else {
        track = trackVariant.toMap();
    }

    const QString title  = track.value("Title").toString();
    const QString artist = track.value("Artist").toString();
    const QString album  = track.value("Album").toString();

    bool changed = false;
    if (title  != m_trackTitle)  { m_trackTitle  = title;  changed = true; }
    if (artist != m_trackArtist) { m_trackArtist = artist; changed = true; }
    if (album  != m_trackAlbum)  { m_trackAlbum  = album;  changed = true; }
    if (changed) emit trackChanged();
}

void BluetoothManager::mediaPlay()     { callPlayer("Play"); }
void BluetoothManager::mediaPause()    { callPlayer("Pause"); }
void BluetoothManager::mediaNext()     { callPlayer("Next"); }
void BluetoothManager::mediaPrevious() { callPlayer("Previous"); }
void BluetoothManager::mediaPlayPause()
{
    if (m_avrcpStatus == "playing") callPlayer("Pause");
    else                            callPlayer("Play");
}
