#ifndef RADIOMANAGER_H
#define RADIOMANAGER_H

#include <QObject>
#include <QMediaPlayer>
#include <QAudioOutput>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QVariantList>
#include <QString>

class RadioManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QVariantList stations READ stations NOTIFY stationsChanged)
    Q_PROPERTY(QString currentStation READ currentStation NOTIFY currentStationChanged)
    Q_PROPERTY(QString currentUrl READ currentUrl NOTIFY currentStationChanged)
    Q_PROPERTY(QString statusMsg READ statusMsg NOTIFY statusChanged)
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)
    Q_PROPERTY(bool playing READ playing NOTIFY playingChanged)
    Q_PROPERTY(int volume READ volume WRITE setVolume NOTIFY volumeChanged)

public:
    explicit RadioManager(QObject *parent = nullptr);

    QVariantList stations() const;
    QString currentStation() const;
    QString currentUrl() const;
    QString statusMsg() const;
    bool loading() const;
    bool playing() const;
    int volume() const;

    Q_INVOKABLE void fetchStations(const QString &tag);
    Q_INVOKABLE void playStation(const QString &url, const QString &name);
    Q_INVOKABLE void stop();
    Q_INVOKABLE void setVolume(int volume);
    Q_INVOKABLE void togglePlayPause();

signals:
    void stationsChanged();
    void currentStationChanged();
    void statusChanged();
    void loadingChanged();
    void playingChanged();
    void volumeChanged();

private slots:
    void onStationsReply(QNetworkReply *reply);

private:
    void updateStatus(const QString &msg);

    QNetworkAccessManager *m_network;
    QMediaPlayer *m_player;
    QAudioOutput *m_audioOutput;
    QVariantList m_stations;
    QString m_currentStation;
    QString m_currentUrl;
    QString m_statusMsg;
    bool m_loading;
    bool m_playing;
    int m_volume;
};

#endif // RADIOMANAGER_H
