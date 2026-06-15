#include "PhoneManager.h"

#include <QDBusInterface>
#include <QDBusReply>
#include <QDBusArgument>
#include <QDBusVariant>
#include <QDBusPendingCall>
#include <QDBusPendingCallWatcher>
#include <QDBusPendingReply>
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QDateTime>
#include <QDebug>
#include <QRegularExpression>

// ─── D-Bus constants ──────────────────────────────────────────────────────────
static const char* BLUEZ_SERVICE = "org.bluez";
static const char* BLUEZ_DEVICE  = "org.bluez.Device1";
static const char* DBUS_OBJ_MGR  = "org.freedesktop.DBus.ObjectManager";
static const char* DBUS_PROPS    = "org.freedesktop.DBus.Properties";

static const char* OBEX_SERVICE  = "org.bluez.obex";
static const char* OBEX_PATH     = "/org/bluez/obex";
static const char* OBEX_CLIENT   = "org.bluez.obex.Client1";
static const char* OBEX_PBAP     = "org.bluez.obex.PhonebookAccess1";

static const char* OFONO_SERVICE = "org.ofono";

// ─── Constructor ──────────────────────────────────────────────────────────────

PhoneManager::PhoneManager(QObject *parent) : QObject(parent)
{
    m_callTimer = new QTimer(this);
    m_callTimer->setSingleShot(true);
    connect(m_callTimer, &QTimer::timeout, this, [this]() {
        if (m_callState == "dialing")
            setCallState("active", m_activeNumber, m_activeName);
    });

    m_durTimer = new QTimer(this);
    m_durTimer->setInterval(1000);
    connect(m_durTimer, &QTimer::timeout, this, &PhoneManager::onTick);

    // Re-check the connected phone every few seconds (cheap, robust)
    m_pollTimer = new QTimer(this);
    m_pollTimer->setInterval(4000);
    connect(m_pollTimer, &QTimer::timeout, this, &PhoneManager::refreshConnectedDevice);
    m_pollTimer->start();

    // Debounce PulseAudio events before re-scanning for call audio
    m_rescanTimer = new QTimer(this);
    m_rescanTimer->setSingleShot(true);
    m_rescanTimer->setInterval(400);
    connect(m_rescanTimer, &QTimer::timeout, this, &PhoneManager::scanAndBridgeHfp);

    // Watch PulseAudio so we can route call audio whenever an HFP call goes
    // active — no matter whether the call was dialled here or on the phone.
    startHfpWatcher();

    // Watch obex transfer property changes (session bus)
    m_sess.connect(QString(), QString(), DBUS_PROPS, "PropertiesChanged",
                   this, SLOT(onTransferPropertiesChanged(QDBusMessage)));

    updateStatus("Connect your phone over Bluetooth, then tap Sync.");
    refreshConnectedDevice();
}

PhoneManager::~PhoneManager()
{
    cleanupPbap();
    // Tear down any active call-audio bridge
    for (const QString &id : std::as_const(m_loopbackModules))
        QProcess::execute("pactl", { "unload-module", id });
    if (m_paSubscribe) {
        m_paSubscribe->kill();
        m_paSubscribe->waitForFinished(500);
    }
}

// ─── Connected-device discovery (BlueZ) ─────────────────────────────────────────

QString PhoneManager::findConnectedDeviceAddress()
{
    QDBusMessage msg = m_sys.call(
        QDBusMessage::createMethodCall(BLUEZ_SERVICE, "/", DBUS_OBJ_MGR, "GetManagedObjects"));
    if (msg.type() == QDBusMessage::ErrorMessage || msg.arguments().isEmpty())
        return {};

    const QDBusArgument top =
        msg.arguments().at(0).value<QDBusArgument>();

    QString foundAddr, foundName;
    top.beginMap();
    while (!top.atEnd()) {
        QDBusObjectPath path;
        top.beginMapEntry();
        top >> path;

        bool isDevice = false, connected = false;
        QString addr, name;

        top.beginMap();                                   // a{sa{sv}}
        while (!top.atEnd()) {
            QString iface;
            top.beginMapEntry();
            top >> iface;

            QVariantMap props;
            top.beginMap();
            while (!top.atEnd()) {
                QString key; QDBusVariant val;
                top.beginMapEntry();
                top >> key >> val;
                props[key] = val.variant();
                top.endMapEntry();
            }
            top.endMap();
            top.endMapEntry();

            if (iface == BLUEZ_DEVICE) {
                isDevice  = true;
                connected = props.value("Connected").toBool();
                addr      = props.value("Address").toString();
                name      = props.value("Alias", props.value("Name")).toString();
            }
        }
        top.endMap();
        top.endMapEntry();

        if (isDevice && connected && !addr.isEmpty()) {
            foundAddr = addr;
            foundName = name.isEmpty() ? addr : name;
            break;
        }
    }
    top.endMap();

    if (!foundAddr.isEmpty())
        m_deviceName = foundName;
    return foundAddr;
}

void PhoneManager::refreshConnectedDevice()
{
    QString addr = findConnectedDeviceAddress();
    bool conn = !addr.isEmpty();

    if (conn != m_phoneConnected || addr != m_deviceAddress) {
        m_phoneConnected = conn;
        m_deviceAddress  = addr;
        emit phoneConnectedChanged();

        if (conn) {
            updateStatus("Phone connected — tap Sync to import contacts.");
        } else {
            m_deviceName.clear();
            updateStatus("No phone connected.");
        }
    }
}

// ─── PBAP phonebook sync (obexd, session bus) ───────────────────────────────────

void PhoneManager::syncPhonebook()
{
    if (m_syncing) return;
    if (m_deviceAddress.isEmpty()) {
        refreshConnectedDevice();
        if (m_deviceAddress.isEmpty()) {
            updateStatus("No phone connected to sync.");
            return;
        }
    }

    m_syncing = true;
    emit syncingChanged();
    updateStatus("Connecting to phonebook…");
    m_pendingHistory = true;
    startPbapSession();
}

void PhoneManager::startPbapSession()
{
    cleanupPbap();

    QDBusInterface client(OBEX_SERVICE, OBEX_PATH, OBEX_CLIENT, m_sess);
    if (!client.isValid()) {
        updateStatus("obexd not available — cannot read phonebook.");
        m_syncing = false; emit syncingChanged();
        return;
    }

    QVariantMap args;
    args["Target"] = "PBAP";

    QDBusReply<QDBusObjectPath> reply =
        client.call("CreateSession", m_deviceAddress, args);

    if (!reply.isValid()) {
        updateStatus("Phonebook access failed: " + reply.error().message());
        m_syncing = false; emit syncingChanged();
        return;
    }

    m_pbapSession = reply.value().path();
    // First pull contacts, then call history (chained on transfer complete)
    pullPhonebook("int", "pb");
}

void PhoneManager::pullPhonebook(const QString &location, const QString &target)
{
    if (m_pbapSession.isEmpty()) return;

    QDBusInterface pbap(OBEX_SERVICE, m_pbapSession, OBEX_PBAP, m_sess);

    QDBusReply<void> sel = pbap.call("Select", location, target);
    if (!sel.isValid()) {
        updateStatus("Select failed: " + sel.error().message());
        // Move on / finish
        if (target == "pb" && m_pendingHistory) {
            m_pendingHistory = false;
            pullPhonebook("int", "cch");
            return;
        }
        m_syncing = false; emit syncingChanged();
        cleanupPbap();
        return;
    }

    m_pbapKind = (target == "pb") ? "contacts" : "history";
    m_pbapFile = QDir::tempPath() + "/ivi_" + m_pbapKind + ".vcf";
    QFile::remove(m_pbapFile);

    // PullAll(targetfile, filters) -> (transfer, properties)
    QDBusMessage call = QDBusMessage::createMethodCall(
        OBEX_SERVICE, m_pbapSession, OBEX_PBAP, "PullAll");
    call << m_pbapFile << QVariantMap();

    QDBusMessage res = m_sess.call(call);
    if (res.type() == QDBusMessage::ErrorMessage) {
        updateStatus("PullAll failed: " + res.errorMessage());
        m_syncing = false; emit syncingChanged();
        cleanupPbap();
        return;
    }
    if (!res.arguments().isEmpty())
        m_pbapTransfer = res.arguments().at(0).value<QDBusObjectPath>().path();

    updateStatus(m_pbapKind == "contacts" ? "Downloading contacts…"
                                          : "Downloading call history…");
}

void PhoneManager::onTransferPropertiesChanged(const QDBusMessage &msg)
{
    if (m_pbapTransfer.isEmpty() || msg.path() != m_pbapTransfer) return;
    if (msg.arguments().size() < 2) return;
    if (msg.arguments().at(0).toString() != "org.bluez.obex.Transfer1") return;

    const QDBusArgument arg = msg.arguments().at(1).value<QDBusArgument>();
    QVariantMap changed;
    arg.beginMap();
    while (!arg.atEnd()) {
        QString key; QDBusVariant val;
        arg.beginMapEntry();
        arg >> key >> val;
        changed[key] = val.variant();
        arg.endMapEntry();
    }
    arg.endMap();

    if (!changed.contains("Status")) return;
    const QString status = changed.value("Status").toString();

    if (status == "complete") {
        QString file = m_pbapFile;
        QString kind = m_pbapKind;
        m_pbapTransfer.clear();
        handleVcardFile(file, kind);

        if (kind == "contacts" && m_pendingHistory) {
            m_pendingHistory = false;
            pullPhonebook("int", "cch");      // now pull call history
        } else {
            m_syncing = false; emit syncingChanged();
            updateStatus("Sync complete — " +
                         QString::number(m_contacts.size()) + " contacts, " +
                         QString::number(m_recents.size()) + " recent calls.");
            cleanupPbap();
        }
    } else if (status == "error") {
        updateStatus("Transfer error while reading " + m_pbapKind + ".");
        m_pbapTransfer.clear();
        m_syncing = false; emit syncingChanged();
        cleanupPbap();
    }
}

void PhoneManager::handleVcardFile(const QString &path, const QString &kind)
{
    QFile f(path);
    if (!f.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "[Phone] cannot open vcard" << path;
        return;
    }
    const QString data = QString::fromUtf8(f.readAll());
    f.close();
    QFile::remove(path);

    if (kind == "contacts") parseContacts(data);
    else                    parseCallHistory(data);
}

// ─── vCard parsing ──────────────────────────────────────────────────────────────

void PhoneManager::parseContacts(const QString &vcard)
{
    QVariantList list;
    const QStringList cards = vcard.split("END:VCARD", Qt::SkipEmptyParts);

    for (const QString &card : cards) {
        QString name, number, type = "Mobile";
        const QStringList lines = card.split(QRegularExpression("[\r\n]+"), Qt::SkipEmptyParts);
        for (const QString &line : lines) {
            if (line.startsWith("FN", Qt::CaseInsensitive)) {
                int c = line.indexOf(':');
                if (c >= 0) name = line.mid(c + 1).trimmed();
            } else if (line.startsWith("TEL", Qt::CaseInsensitive) && number.isEmpty()) {
                int c = line.indexOf(':');
                if (c >= 0) number = line.mid(c + 1).trimmed();
                const QString meta = line.left(c).toUpper();
                if      (meta.contains("WORK")) type = "Work";
                else if (meta.contains("HOME")) type = "Home";
                else if (meta.contains("CELL")) type = "Mobile";
            }
        }
        if (!number.isEmpty()) {
            QVariantMap c;
            c["name"]   = name.isEmpty() ? number : name;
            c["number"] = number;
            c["tag"]    = type;
            list.append(c);
        }
    }

    // Sort alphabetically by name
    std::sort(list.begin(), list.end(), [](const QVariant &a, const QVariant &b) {
        return a.toMap()["name"].toString().localeAwareCompare(
               b.toMap()["name"].toString()) < 0;
    });

    m_contacts = list;
    emit contactsChanged();
}

void PhoneManager::parseCallHistory(const QString &vcard)
{
    QVariantList list;
    const QStringList cards = vcard.split("END:VCARD", Qt::SkipEmptyParts);

    for (const QString &card : cards) {
        QString name, number, direction = "incoming", when;
        const QStringList lines = card.split(QRegularExpression("[\r\n]+"), Qt::SkipEmptyParts);
        for (const QString &line : lines) {
            if (line.startsWith("FN", Qt::CaseInsensitive)) {
                int c = line.indexOf(':');
                if (c >= 0) name = line.mid(c + 1).trimmed();
            } else if (line.startsWith("TEL", Qt::CaseInsensitive) && number.isEmpty()) {
                int c = line.indexOf(':');
                if (c >= 0) number = line.mid(c + 1).trimmed();
            } else if (line.contains("X-IRMC-CALL-DATETIME", Qt::CaseInsensitive)) {
                const QString up = line.toUpper();
                if      (up.contains("MISSED"))   direction = "missed";
                else if (up.contains("DIALED"))   direction = "outgoing";
                else if (up.contains("RECEIVED")) direction = "incoming";
                int c = line.indexOf(':');
                if (c >= 0) {
                    QString dt = line.mid(c + 1).trimmed();   // 20240115T143000
                    QDateTime t = QDateTime::fromString(dt, "yyyyMMddThhmmss");
                    if (t.isValid()) when = t.toString("MMM d, HH:mm");
                }
            }
        }
        if (!number.isEmpty()) {
            QVariantMap c;
            c["name"]      = name.isEmpty() ? number : name;
            c["number"]    = number;
            c["direction"] = direction;
            c["time"]      = when;
            list.append(c);
        }
    }

    m_recents = list;
    emit recentsChanged();
}

void PhoneManager::cleanupPbap()
{
    if (!m_pbapSession.isEmpty()) {
        QDBusInterface client(OBEX_SERVICE, OBEX_PATH, OBEX_CLIENT, m_sess);
        client.call("RemoveSession", QVariant::fromValue(QDBusObjectPath(m_pbapSession)));
    }
    m_pbapSession.clear();
    m_pbapTransfer.clear();
}

// ─── Calls (oFono HFP + simulated fallback) ──────────────────────────────────────

QString PhoneManager::firstOnlineModem()
{
    QDBusMessage msg = m_sys.call(
        QDBusMessage::createMethodCall(OFONO_SERVICE, "/", "org.ofono.Manager", "GetModems"));
    if (msg.type() == QDBusMessage::ErrorMessage || msg.arguments().isEmpty())
        return {};

    const QDBusArgument arg = msg.arguments().at(0).value<QDBusArgument>();
    QString chosen;
    arg.beginArray();
    while (!arg.atEnd()) {
        QDBusObjectPath path; QVariantMap props;
        arg.beginStructure();
        arg >> path >> props;
        arg.endStructure();
        if (props.value("Online").toBool() || props.value("Powered").toBool()) {
            chosen = path.path();
            break;
        }
    }
    arg.endArray();
    return chosen;
}

bool PhoneManager::ofonoDial(const QString &number)
{
    const QString modem = firstOnlineModem();
    if (modem.isEmpty()) return false;

    QDBusInterface vcm(OFONO_SERVICE, modem, "org.ofono.VoiceCallManager", m_sys);
    QDBusReply<QDBusObjectPath> reply = vcm.call("Dial", number, QString("default"));
    if (reply.isValid()) {
        m_ofonoCallPath = reply.value().path();
        m_usingOfono = true;
        return true;
    }
    return false;
}

void PhoneManager::ofonoHangupAll()
{
    const QString modem = firstOnlineModem();
    if (modem.isEmpty()) return;
    QDBusInterface vcm(OFONO_SERVICE, modem, "org.ofono.VoiceCallManager", m_sys);
    vcm.call("HangupAll");
    m_ofonoCallPath.clear();
    m_usingOfono = false;
}

void PhoneManager::dial(const QString &number, const QString &name)
{
    if (number.isEmpty() || m_callState != "idle") return;

    const QString display = name.isEmpty() ? nameForNumber(number) : name;
    setCallState("dialing", number, display);

    if (ofonoDial(number)) {
        updateStatus("Calling " + (display.isEmpty() ? number : display) + "…");
        // oFono call-state changes would advance us; give a soft fallback too
        m_callTimer->start(3000);
    } else {
        // Simulated call: dialing → active after 2s
        updateStatus("Calling " + (display.isEmpty() ? number : display) + "… (simulated)");
        m_callTimer->start(2000);
    }
}

void PhoneManager::answer()
{
    if (m_callState != "incoming") return;
    setCallState("active", m_activeNumber, m_activeName);
}

void PhoneManager::hangup()
{
    if (m_callState == "idle") return;

    if (m_usingOfono) ofonoHangupAll();
    m_callTimer->stop();

    // Log the call to recents
    QString dir = (m_callState == "incoming") ? "missed" : "outgoing";
    logRecent(m_activeName, m_activeNumber, dir);

    setCallState("idle");
    updateStatus(m_phoneConnected ? "Call ended." : "No phone connected.");
}

// ─── HFP call-audio routing ──────────────────────────────────────────────────────
//
// During a call the voice travels over a Bluetooth SCO link. PulseAudio exposes
// it only when the BT card is in the hands-free/headset profile. We switch the
// profile, then bridge:  phone voice (bluez source) → speakers, and
// car mic (default source) → phone (bluez sink), using module-loopback.

static QString runPactl(const QStringList &args)
{
    QProcess p;
    p.start("pactl", args);
    p.waitForFinished(1500);
    return QString::fromUtf8(p.readAllStandardOutput());
}

// Start a persistent `pactl subscribe` and re-scan on every relevant event.
void PhoneManager::startHfpWatcher()
{
    if (m_paSubscribe) return;
    m_paSubscribe = new QProcess(this);
    connect(m_paSubscribe, &QProcess::readyReadStandardOutput,
            this, &PhoneManager::onPaEvent);
    m_paSubscribe->start("pactl", { "subscribe" });
    // Do an initial scan in case a call is already active
    QTimer::singleShot(500, this, &PhoneManager::scanAndBridgeHfp);
}

void PhoneManager::onPaEvent()
{
    const QString out = QString::fromUtf8(m_paSubscribe->readAllStandardOutput());
    // React only to source/sink/card changes (where SCO call audio shows up)
    if (out.contains(" on source") || out.contains(" on sink") || out.contains(" on card"))
        m_rescanTimer->start();   // debounced
}

// The heart of call audio: whenever the phone's HFP voice channel exists,
// bridge it to the car speakers + mic. When it disappears, tear the bridge down.
void PhoneManager::scanAndBridgeHfp()
{
    // Match only the Hands-Free *head unit* role (the car side), never the
    // audio-gateway role (which would route the wrong way).
    auto isHfp = [](const QString &n) {
        const QString lo = n.toLower();
        if (!lo.contains("bluez") || lo.contains("audio_gateway")) return false;
        return lo.contains("head_unit") || lo.contains("head-unit") ||
               lo.contains("handsfree") || lo.contains("hfp") || lo.contains("sco");
    };

    QString hfpSource, hfpSink, micSource, spkSink;
    for (const QString &line : runPactl({ "list", "sources", "short" }).split('\n')) {
        const QString name = line.split('\t').value(1).trimmed();
        if (name.isEmpty() || name.toLower().contains(".monitor")) continue;
        if (isHfp(name)) { if (hfpSource.isEmpty()) hfpSource = name; }
        else if (name.startsWith("alsa_input")) { if (micSource.isEmpty()) micSource = name; }
    }
    for (const QString &line : runPactl({ "list", "sinks", "short" }).split('\n')) {
        const QString name = line.split('\t').value(1).trimmed();
        if (name.isEmpty()) continue;
        if (isHfp(name)) { if (hfpSink.isEmpty()) hfpSink = name; }
        else if (name.startsWith("alsa_output")) { if (spkSink.isEmpty()) spkSink = name; }
    }

    const bool callAudioPresent = !hfpSource.isEmpty() || !hfpSink.isEmpty();

    if (callAudioPresent && !m_hfpBridged) {
        // phone voice → car speakers (explicit hw sink avoids feedback loops)
        if (!hfpSource.isEmpty()) {
            QStringList a = { "load-module", "module-loopback", "source=" + hfpSource,
                              "latency_msec=60", "source_dont_move=true", "sink_dont_move=true" };
            if (!spkSink.isEmpty()) a << ("sink=" + spkSink);
            const QString id = runPactl(a).trimmed();
            if (!id.isEmpty()) m_loopbackModules << id;
        }
        // car mic → phone (explicit hw mic so we don't echo the phone back)
        if (!hfpSink.isEmpty()) {
            QStringList a = { "load-module", "module-loopback", "sink=" + hfpSink,
                              "latency_msec=60", "source_dont_move=true", "sink_dont_move=true" };
            if (!micSource.isEmpty()) a << ("source=" + micSource);
            const QString id = runPactl(a).trimmed();
            if (!id.isEmpty()) m_loopbackModules << id;
        }
        if (!m_loopbackModules.isEmpty()) {
            m_hfpBridged = true;
            updateStatus("Call audio connected.");
            qDebug() << "[Phone] HFP bridged  src=" << hfpSource << " sink=" << hfpSink;
        }
    } else if (!callAudioPresent && m_hfpBridged) {
        for (const QString &id : std::as_const(m_loopbackModules))
            QProcess::execute("pactl", { "unload-module", id });
        m_loopbackModules.clear();
        m_hfpBridged = false;
        qDebug() << "[Phone] HFP bridge torn down";
    }
}

// Switch the BT card to/from a hands-free profile. Used when WE place a call so
// the SCO channel (and thus the HFP source/sink) can come up.
void PhoneManager::forceHfpProfile(bool on)
{
    // Find the bluez card
    QString card;
    for (const QString &line : runPactl({ "list", "cards", "short" }).split('\n')) {
        const QString name = line.split('\t').value(1).trimmed();
        if (name.contains("bluez", Qt::CaseInsensitive)) { card = name; break; }
    }
    if (card.isEmpty()) return;

    if (on) {
        const QStringList hfpProfiles = {
            "headset-head-unit", "handsfree_head_unit", "headset_head_unit",
            "headset-head-unit-msbc", "handsfree-head-unit"
        };
        for (const QString &prof : hfpProfiles) {
            QProcess::execute("pactl", { "set-card-profile", card, prof });
            if (runPactl({ "list", "cards" }).contains("Active Profile: " + prof)) break;
        }
    } else {
        QProcess::execute("pactl", { "set-card-profile", card, "a2dp_sink" });
    }
}

// ─── State helpers ──────────────────────────────────────────────────────────────

void PhoneManager::setCallState(const QString &state, const QString &number, const QString &name)
{
    m_callState    = state;
    m_activeNumber = number;
    m_activeName   = name;

    if (state == "active") {
        m_callSeconds = 0;
        emit callSecondsChanged();
        m_durTimer->start();
        // For calls we placed via oFono, force HFP so the SCO channel comes up;
        // the PulseAudio watcher then bridges the audio automatically.
        if (m_usingOfono) { forceHfpProfile(true); scanAndBridgeHfp(); }
    } else {
        m_durTimer->stop();
        if (state == "idle") {
            m_callSeconds = 0;
            emit callSecondsChanged();
            scanAndBridgeHfp();              // tears down the bridge if audio is gone
            if (m_usingOfono) forceHfpProfile(false);
        }
    }
    emit callStateChanged();
}

void PhoneManager::onTick()
{
    m_callSeconds++;
    emit callSecondsChanged();
}

void PhoneManager::logRecent(const QString &name, const QString &number, const QString &direction)
{
    if (number.isEmpty()) return;
    QVariantMap c;
    c["name"]      = name.isEmpty() ? nameForNumber(number) : name;
    if (c["name"].toString().isEmpty()) c["name"] = number;
    c["number"]    = number;
    c["direction"] = direction;
    c["time"]      = QDateTime::currentDateTime().toString("MMM d, HH:mm");
    m_recents.prepend(c);
    while (m_recents.size() > 50) m_recents.removeLast();
    emit recentsChanged();
}

QString PhoneManager::nameForNumber(const QString &number) const
{
    auto digits = [](const QString &s) {
        QString d; for (QChar ch : s) if (ch.isDigit()) d += ch;
        return d.right(9);                     // compare last 9 digits
    };
    const QString want = digits(number);
    for (const QVariant &v : m_contacts) {
        QVariantMap c = v.toMap();
        if (digits(c["number"].toString()) == want)
            return c["name"].toString();
    }
    return {};
}

void PhoneManager::updateStatus(const QString &msg)
{
    m_statusMsg = msg;
    emit statusChanged();
    qDebug() << "[Phone]" << msg;
}
