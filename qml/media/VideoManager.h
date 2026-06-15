#ifndef VIDEOMANAGER_H
#define VIDEOMANAGER_H

#include <QObject>
#include <QMediaPlayer>
#include <QAudioOutput>
#include <QVariantList>
#include <QString>

class VideoManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QVariantList playlist READ playlist NOTIFY playlistChanged)
    Q_PROPERTY(QString currentTitle READ currentTitle NOTIFY currentVideoChanged)
    Q_PROPERTY(bool playing READ playing NOTIFY playingChanged)
    Q_PROPERTY(int volume READ volume WRITE setVolume NOTIFY volumeChanged)
    Q_PROPERTY(int position READ position NOTIFY positionChanged)
    Q_PROPERTY(int duration READ duration NOTIFY durationChanged)
    Q_PROPERTY(QString statusMsg READ statusMsg NOTIFY statusChanged)
    Q_PROPERTY(int currentIndex READ currentIndex NOTIFY currentVideoChanged)
    Q_PROPERTY(QMediaPlayer* player READ player CONSTANT)
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)
    Q_PROPERTY(QString defaultVideoPath READ defaultVideoPath CONSTANT)

public:
    explicit VideoManager(QObject *parent = nullptr);

    QVariantList playlist() const;
    QString currentTitle() const;
    bool playing() const;
    int volume() const;
    int position() const;
    int duration() const;
    QString statusMsg() const;
    int currentIndex() const;
    QMediaPlayer* player() const;
    bool loading() const;
    QString defaultVideoPath() const;

    Q_INVOKABLE void scanFolder(const QString &path);
    Q_INVOKABLE void scanUSB();
    Q_INVOKABLE void playVideo(int index);
    Q_INVOKABLE void playPause();
    Q_INVOKABLE void next();
    Q_INVOKABLE void previous();
    Q_INVOKABLE void setVolume(int volume);
    Q_INVOKABLE void seek(int position);
    Q_INVOKABLE void stop();

signals:
    void playlistChanged();
    void currentVideoChanged();
    void playingChanged();
    void volumeChanged();
    void positionChanged();
    void durationChanged();
    void statusChanged();
    void loadingChanged();

private:
    void updateStatus(const QString &msg);
    void loadVideo(int index);
    void scanFolderInternal(const QString &path, bool clearFirst);

    QMediaPlayer *m_player;
    QAudioOutput *m_audioOutput;
    QVariantList m_playlist;
    QString m_currentTitle;
    QString m_statusMsg;
    bool m_playing;
    bool m_loading;
    int m_volume;
    int m_position;
    int m_duration;
    int m_currentIndex;
};

#endif // VIDEOMANAGER_H
