#ifndef PHONEMANAGER_H
#define PHONEMANAGER_H

#include <QObject>
#include <QVariantList>
#include <QString>
#include <QTimer>
#include <QDBusConnection>
#include <QDBusMessage>
#include <QDBusObjectPath>
#include <QProcess>
#include <QStringList>

// ─────────────────────────────────────────────────────────────────────────────
// PhoneManager
//
// Brings phone functionality to the head unit, exactly like a real car:
//
//   Phone ──PBAP──▶ obexd ──D-Bus──▶ PhoneManager     (contacts + call history)
//   Phone ──HFP───▶ oFono ──D-Bus──▶ PhoneManager     (make / answer / end calls)
//
// 1. PBAP (Phone Book Access Profile) over obexd pulls the phone's contacts
//    and call log as vCards; we parse them into `contacts` and `recents`.
// 2. HFP via oFono places and controls calls. When oFono is unavailable
//    (e.g. on a dev box) we fall back to a simulated call so the UI works.
// ─────────────────────────────────────────────────────────────────────────────

class PhoneManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool         phoneConnected READ phoneConnected NOTIFY phoneConnectedChanged)
    Q_PROPERTY(QString      deviceName     READ deviceName     NOTIFY phoneConnectedChanged)
    Q_PROPERTY(QVariantList contacts       READ contacts       NOTIFY contactsChanged)
    Q_PROPERTY(QVariantList recents        READ recents        NOTIFY recentsChanged)
    Q_PROPERTY(bool         syncing        READ syncing        NOTIFY syncingChanged)
    Q_PROPERTY(QString      statusMsg      READ statusMsg      NOTIFY statusChanged)

    // Call state: "idle" | "dialing" | "incoming" | "active"
    Q_PROPERTY(QString      callState      READ callState      NOTIFY callStateChanged)
    Q_PROPERTY(QString      activeNumber   READ activeNumber   NOTIFY callStateChanged)
    Q_PROPERTY(QString      activeName     READ activeName     NOTIFY callStateChanged)
    Q_PROPERTY(int          callSeconds    READ callSeconds    NOTIFY callSecondsChanged)

public:
    explicit PhoneManager(QObject *parent = nullptr);
    ~PhoneManager();

    bool         phoneConnected() const { return m_phoneConnected; }
    QString      deviceName()     const { return m_deviceName; }
    QVariantList contacts()       const { return m_contacts; }
    QVariantList recents()        const { return m_recents; }
    bool         syncing()        const { return m_syncing; }
    QString      statusMsg()      const { return m_statusMsg; }
    QString      callState()      const { return m_callState; }
    QString      activeNumber()   const { return m_activeNumber; }
    QString      activeName()     const { return m_activeName; }
    int          callSeconds()    const { return m_callSeconds; }

    Q_INVOKABLE void syncPhonebook();          // PBAP pull contacts + call history
    Q_INVOKABLE void dial(const QString &number, const QString &name = {});
    Q_INVOKABLE void answer();
    Q_INVOKABLE void hangup();

signals:
    void phoneConnectedChanged();
    void contactsChanged();
    void recentsChanged();
    void syncingChanged();
    void statusChanged();
    void callStateChanged();
    void callSecondsChanged();

private slots:
    void refreshConnectedDevice();
    void onTransferPropertiesChanged(const QDBusMessage &msg);
    void onTick();
    void onPaEvent();                          // pactl subscribe output

private:
    // ── BlueZ: find the connected phone ──
    QString findConnectedDeviceAddress();      // returns "AA:BB:CC:..." or empty

    // ── PBAP via obexd (session bus) ──
    void    startPbapSession();
    void    pullPhonebook(const QString &store, const QString &target); // "pb"/"cch"
    void    handleVcardFile(const QString &path, const QString &kind);
    void    parseContacts(const QString &vcard);
    void    parseCallHistory(const QString &vcard);
    void    cleanupPbap();

    // ── oFono (HFP) for real calls ──
    bool    ofonoDial(const QString &number);  // true if dispatched to a modem
    void    ofonoHangupAll();
    QString firstOnlineModem();

    // ── HFP call-audio routing (SCO ↔ speakers/mic) ──
    void    startHfpWatcher();                 // watch PulseAudio for call audio
    void    scanAndBridgeHfp();                // bridge/unbridge based on live state
    void    forceHfpProfile(bool on);          // switch BT card to/from HFP profile

    // ── State helpers ──
    void    setCallState(const QString &state, const QString &number = {}, const QString &name = {});
    void    logRecent(const QString &name, const QString &number, const QString &direction);
    void    updateStatus(const QString &msg);
    QString nameForNumber(const QString &number) const;

    // ── D-Bus ──
    QDBusConnection m_sys   { QDBusConnection::systemBus() };
    QDBusConnection m_sess  { QDBusConnection::sessionBus() };

    // PBAP transient state
    QString m_pbapSession;        // obex session object path
    QString m_pbapTransfer;       // active transfer object path
    QString m_pbapFile;           // target vcard file
    QString m_pbapKind;           // "contacts" | "history"
    bool    m_pendingHistory = false;   // pull history after contacts

    // Simulated-call timer (fallback) + duration timer
    QTimer *m_callTimer  = nullptr;     // drives the simulated dialing->active
    QTimer *m_durTimer   = nullptr;     // 1s tick for callSeconds
    QTimer *m_pollTimer  = nullptr;     // re-checks connected device

    // oFono call tracking
    QString m_ofonoCallPath;            // active org.ofono.VoiceCall path
    bool    m_usingOfono = false;

    // HFP audio routing state
    QString     m_btCardName;           // pactl bluez card name
    QString     m_savedProfile;         // profile to restore after the call
    QStringList m_loopbackModules;      // loaded module-loopback ids
    bool        m_hfpBridged = false;   // are call-audio loopbacks active?
    QProcess   *m_paSubscribe = nullptr;// long-running `pactl subscribe`
    QTimer     *m_rescanTimer  = nullptr;// debounce PulseAudio events

    // State
    bool         m_phoneConnected = false;
    QString      m_deviceName;
    QString      m_deviceAddress;
    QVariantList m_contacts;
    QVariantList m_recents;
    bool         m_syncing      = false;
    QString      m_statusMsg;
    QString      m_callState    = "idle";
    QString      m_activeNumber;
    QString      m_activeName;
    int          m_callSeconds  = 0;
};

#endif // PHONEMANAGER_H
