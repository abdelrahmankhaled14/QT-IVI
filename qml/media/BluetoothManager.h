#ifndef BLUETOOTHMANAGER_H
#define BLUETOOTHMANAGER_H

#include <QObject>
#include <QVariantList>
#include <QString>
#include <QProcess>
#include <QTimer>
#include <QDBusInterface>
#include <QDBusConnection>
#include <QDBusMessage>
#include <QDBusObjectPath>
#include <QDBusVariant>
#include <functional>
#include "BluetoothAgent.h"

// ─────────────────────────────────────────────────────────────────────────────
// BluetoothManager
//
// Architecture (exactly like a car head unit):
//
//   Phone  ──A2DP──▶  BlueZ (kernel/system)
//                         │
//                    D-Bus (org.bluez)
//                         │
//                   BluetoothManager  ──▶  GStreamer pipeline  ──▶  speakers
//
// 1. We talk to BlueZ over D-Bus to discover, pair, and connect the phone.
// 2. BlueZ exposes the A2DP audio as a file descriptor once connected.
// 3. GStreamer reads that fd, decodes SBC/AAC, and plays it — driven by us.
// ─────────────────────────────────────────────────────────────────────────────

// Forward-declare GStreamer types so we don't pull in gst headers in .h
typedef struct _GstElement GstElement;
typedef struct _GstBus     GstBus;

class BluetoothManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool    bluetoothAvailable READ bluetoothAvailable NOTIFY bluetoothAvailableChanged)
    Q_PROPERTY(bool    scanning          READ scanning           NOTIFY scanningChanged)
    Q_PROPERTY(bool    connected         READ connected          NOTIFY connectedChanged)
    Q_PROPERTY(QString connectedDevice   READ connectedDevice    NOTIFY connectedChanged)
    Q_PROPERTY(QVariantList devices      READ devices            NOTIFY devicesChanged)
    Q_PROPERTY(QString statusMsg         READ statusMsg          NOTIFY statusChanged)
    Q_PROPERTY(bool    discoverable      READ discoverable       NOTIFY discoverableChanged)
    Q_PROPERTY(bool    playing           READ playing            NOTIFY playingChanged)
    Q_PROPERTY(int     volume            READ volume  WRITE setVolume NOTIFY volumeChanged)
    Q_PROPERTY(bool    hfpConnected      READ hfpConnected       NOTIFY hfpConnectedChanged)

    // ── AVRCP (control the phone's media player over Bluetooth) ──
    Q_PROPERTY(bool    avrcpAvailable    READ avrcpAvailable     NOTIFY avrcpChanged)
    Q_PROPERTY(QString avrcpStatus       READ avrcpStatus        NOTIFY avrcpChanged)
    Q_PROPERTY(QString trackTitle        READ trackTitle         NOTIFY trackChanged)
    Q_PROPERTY(QString trackArtist       READ trackArtist        NOTIFY trackChanged)
    Q_PROPERTY(QString trackAlbum        READ trackAlbum         NOTIFY trackChanged)

public:
    explicit BluetoothManager(QObject *parent = nullptr);
    ~BluetoothManager();

    bool         bluetoothAvailable() const { return m_bluetoothAvailable; }
    bool         scanning()           const { return m_scanning; }
    bool         connected()          const { return m_connected; }
    QString      connectedDevice()    const { return m_connectedDevice; }
    QVariantList devices()            const { return m_devices; }
    QString      statusMsg()          const { return m_statusMsg; }
    bool         discoverable()       const { return m_discoverable; }
    bool         playing()            const { return m_playing; }
    int          volume()             const { return m_volume; }
    bool         hfpConnected()       const { return m_hfpConnected; }

    bool         avrcpAvailable()     const { return !m_playerPath.isEmpty(); }
    QString      avrcpStatus()        const { return m_avrcpStatus; }
    QString      trackTitle()         const { return m_trackTitle; }
    QString      trackArtist()        const { return m_trackArtist; }
    QString      trackAlbum()         const { return m_trackAlbum; }

    void doConnect(const QString &path);
    Q_INVOKABLE void startScan();
    Q_INVOKABLE void stopScan();
    Q_INVOKABLE void connectDevice(const QString &address);
    Q_INVOKABLE void disconnectDevice();
    Q_INVOKABLE void setDiscoverable(bool on);
    Q_INVOKABLE void setVolume(int vol);
    Q_INVOKABLE void retryAudio();

    // ── AVRCP transport — controls the phone over Bluetooth ──
    Q_INVOKABLE void mediaPlay();
    Q_INVOKABLE void mediaPause();
    Q_INVOKABLE void mediaPlayPause();
    Q_INVOKABLE void mediaNext();
    Q_INVOKABLE void mediaPrevious();

signals:
    void bluetoothAvailableChanged();
    void scanningChanged();
    void connectedChanged();
    void devicesChanged();
    void statusChanged();
    void discoverableChanged();
    void playingChanged();
    void volumeChanged();
    void hfpConnectedChanged();
    void avrcpChanged();
    void trackChanged();

private slots:
    void onScanTimeout();
    void onInterfacesAdded(const QDBusMessage &msg);
    void onInterfacesRemoved(const QDBusMessage &msg);
    void onPropertiesChanged(const QDBusMessage &msg);
    void onPollTimer();

private:
    // D-Bus helpers
    void        initDBus();
    void        startGStreamer(const QString &btAddress,
                              const QString &sourceName = {},
                              const QString &fallbackSource = {});
    void        stopGStreamer();
    void        updateStatus(const QString &msg);
    void        addOrUpdateDevice(const QString &address,
                           const QString &name,
                           bool paired = false);
    QDBusInterface* adapterIface();
    QDBusInterface* deviceIface(const QString &path);
    QString     addressToPath(const QString &address) const;
    void        findBtSourceAndStart(const QString &address, int attempt = 0);
    void        checkHfpProfile(const QString &path);

    // AVRCP helpers
    void        setPlayerPath(const QString &path, const QMap<QString, QVariant> &props = {});
    void        clearPlayer();
    void        callPlayer(const QString &method);
    void        applyAvrcpStatus(const QString &status);
    void        parseTrack(const QVariant &trackVariant);

    // BlueZ D-Bus
    QDBusConnection  m_bus       { QDBusConnection::systemBus() };
    QString          m_adapterPath;
    QString          m_connectedPath;
    BluetoothAgent   m_agent;

    // GStreamer (opaque pointers — defined in .cpp)
    GstElement      *m_pipeline  = nullptr;
    GstElement      *m_volume_el = nullptr;
    QTimer          *m_gstTimer  = nullptr;   // polls GstBus messages

    // Scan timer
    QTimer          *m_scanTimer = nullptr;

    // GStreamer fallback state
    QString      m_gstFallbackSource;
    QString      m_gstCurrentAddress;

    // State
    bool         m_bluetoothAvailable = false;
    bool         m_scanning           = false;
    bool         m_connected          = false;
    bool         m_discoverable       = false;
    bool         m_playing            = false;
    bool         m_hfpConnected       = false;
    int          m_volume             = 80;
    int          m_connectRetryCount  = 0;
    QString      m_connectedDevice;
    QString      m_connectedAddress;
    QString      m_statusMsg;
    QVariantList m_devices;

    // AVRCP / phone media player
    QString      m_playerPath;     // org.bluez.MediaPlayer1 object path
    QString      m_avrcpStatus;    // "playing" / "paused" / "stopped"
    QString      m_trackTitle;
    QString      m_trackArtist;
    QString      m_trackAlbum;
};

#endif // BLUETOOTHMANAGER_H
