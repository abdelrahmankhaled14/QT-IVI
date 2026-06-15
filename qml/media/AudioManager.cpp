#include "AudioManager.h"
#include <QDir>
#include <QFileInfo>
#include <QStandardPaths>
#include <QDebug>

AudioManager::AudioManager(QObject *parent) : QObject(parent)
{
    m_playing      = false;
    m_loading      = false;
    m_volume       = 80;
    m_position     = 0;
    m_duration     = 0;
    m_currentIndex = -1;
    m_statusMsg    = "Scan a folder or USB to get started!";

    m_player      = new QMediaPlayer(this);
    m_audioOutput = new QAudioOutput(this);
    m_player->setAudioOutput(m_audioOutput);
    m_audioOutput->setVolume(m_volume / 100.0f);

    connect(m_player, &QMediaPlayer::playbackStateChanged,
            this, [this](QMediaPlayer::PlaybackState state) {
                m_playing = (state == QMediaPlayer::PlayingState);
                emit playingChanged();
            });

    connect(m_player, &QMediaPlayer::positionChanged,
            this, [this](qint64 pos) {
                m_position = static_cast<int>(pos);
                emit positionChanged();
            });

    connect(m_player, &QMediaPlayer::durationChanged,
            this, [this](qint64 dur) {
                m_duration = static_cast<int>(dur);
                emit durationChanged();
            });

    connect(m_player, &QMediaPlayer::mediaStatusChanged,
            this, [this](QMediaPlayer::MediaStatus status) {
                if (status == QMediaPlayer::EndOfMedia)
                    next();

                if (status == QMediaPlayer::LoadedMedia ||
                    status == QMediaPlayer::BufferedMedia ||
                    status == QMediaPlayer::EndOfMedia ||
                    status == QMediaPlayer::InvalidMedia) {
                    m_loading = false;
                    emit loadingChanged();
                }
            });

    connect(m_player, &QMediaPlayer::errorOccurred,
            this, [this](QMediaPlayer::Error error, const QString &msg) {
                Q_UNUSED(error)
                m_loading = false;
                emit loadingChanged();
                updateStatus("Error: " + msg);
            });
}

QVariantList AudioManager::playlist()      const { return m_playlist; }
QString      AudioManager::currentTitle()  const { return m_currentTitle; }
QString      AudioManager::currentArtist() const { return m_currentArtist; }
QString      AudioManager::currentArt()    const { return m_currentArt; }
bool         AudioManager::playing()       const { return m_playing; }
int          AudioManager::volume()        const { return m_volume; }
int          AudioManager::position()      const { return m_position; }
int          AudioManager::duration()      const { return m_duration; }
QString      AudioManager::statusMsg()     const { return m_statusMsg; }
int          AudioManager::currentIndex()  const { return m_currentIndex; }
bool         AudioManager::loading()       const { return m_loading; }

QString AudioManager::defaultMusicPath() const
{
    QString path = QStandardPaths::writableLocation(QStandardPaths::MusicLocation);
    if (path.isEmpty()) {
        path = QDir::homePath() + "/Music";
    }
    return path;
}

void AudioManager::updateStatus(const QString &msg)
{
    m_statusMsg = msg;
    emit statusChanged();
}

void AudioManager::scanFolderInternal(const QString &path, bool clearFirst)
{
    if (path.isEmpty()) {
        updateStatus("No path provided");
        return;
    }

    QDir dir(path);
    if (!dir.exists()) {
        updateStatus("Folder not found: " + path);
        return;
    }

    if (clearFirst) {
        m_playlist.clear();
    }

    QStringList filters = {
        "*.mp3", "*.wav", "*.flac", "*.ogg",
        "*.aac", "*.m4a", "*.wma", "*.opus"
    };

    QFileInfoList files = dir.entryInfoList(
        filters,
        QDir::Files | QDir::NoDotAndDotDot,
        QDir::Name
        );

    for (const QFileInfo &file : files) {
        QVariantMap track;
        track["title"]  = file.baseName();
        track["artist"] = "Unknown Artist";
        track["path"]   = file.absoluteFilePath();
        track["art"]    = "";

        m_playlist.append(track);
    }

    // Also scan subdirectories
    QFileInfoList subdirs = dir.entryInfoList(
        QDir::Dirs | QDir::NoDotAndDotDot
        );

    for (const QFileInfo &subdir : subdirs) {
        scanFolderInternal(subdir.absoluteFilePath(), false);
    }
}

void AudioManager::scanFolder(const QString &path)
{
    m_loading = true;
    emit loadingChanged();
    updateStatus("Scanning folder...");

    scanFolderInternal(path, true);

    emit playlistChanged();

    m_loading = false;
    emit loadingChanged();

    if (m_playlist.isEmpty())
        updateStatus("No audio files found in " + path);
    else
        updateStatus("Found " + QString::number(m_playlist.size()) + " tracks");
}

void AudioManager::scanUSB()
{
    m_loading = true;
    emit loadingChanged();
    updateStatus("Scanning for USB devices...");

    QString username = qgetenv("USER");
    QStringList searchPaths;

#ifdef Q_OS_LINUX
    searchPaths = {
        "/media/" + username,
        "/run/media/" + username,
        "/mnt"
    };
#elif defined(Q_OS_WIN)
    // Windows: Check drive letters D: through Z:
    for (char drive = 'D'; drive <= 'Z'; drive++) {
        QString drivePath = QString("%1:/").arg(drive);
        if (QDir(drivePath).exists()) {
            searchPaths.append(drivePath);
        }
    }
#elif defined(Q_OS_MAC)
    searchPaths = { "/Volumes" };
#endif

    m_playlist.clear();

    for (const QString &basePath : searchPaths) {
        QDir baseDir(basePath);
        if (!baseDir.exists()) continue;

        QFileInfoList drives = baseDir.entryInfoList(
            QDir::Dirs | QDir::NoDotAndDotDot
            );

        for (const QFileInfo &drive : drives) {
            qDebug() << "Found drive:" << drive.absoluteFilePath();
            scanFolderInternal(drive.absoluteFilePath(), false);
        }
    }

    emit playlistChanged();

    m_loading = false;
    emit loadingChanged();

    if (m_playlist.isEmpty())
        updateStatus("No USB drives found or no audio files on them");
    else
        updateStatus("Found " + QString::number(m_playlist.size()) + " tracks on USB");
}

void AudioManager::loadTrack(int index)
{
    if (index < 0 || index >= m_playlist.size()) return;

    m_loading = true;
    emit loadingChanged();

    QVariantMap track = m_playlist[index].toMap();
    QString path      = track["path"].toString();

    m_currentTitle  = track["title"].toString();
    m_currentArtist = track["artist"].toString();
    m_currentArt    = track["art"].toString();
    m_currentIndex  = index;

    emit currentTrackChanged();

    m_player->setSource(QUrl::fromLocalFile(path));
    updateStatus("Now playing: " + m_currentTitle);
}

void AudioManager::playTrack(int index)
{
    loadTrack(index);
    m_player->play();
}

void AudioManager::playPause()
{
    if (m_playlist.isEmpty()) {
        updateStatus("No tracks loaded!");
        return;
    }

    if (m_currentIndex < 0) {
        playTrack(0);
        return;
    }

    if (m_player->playbackState() == QMediaPlayer::PlayingState)
        m_player->pause();
    else
        m_player->play();
}

void AudioManager::stop()
{
    m_player->stop();
    m_playing = false;
    emit playingChanged();
    updateStatus("Stopped");
}

void AudioManager::next()
{
    if (m_playlist.isEmpty()) return;

    int nextIndex = m_currentIndex + 1;

    if (nextIndex >= m_playlist.size())
        nextIndex = 0;

    playTrack(nextIndex);
}

void AudioManager::previous()
{
    if (m_playlist.isEmpty()) return;

    if (m_position > 3000) {
        m_player->setPosition(0);
        return;
    }

    int prevIndex = m_currentIndex - 1;

    if (prevIndex < 0)
        prevIndex = m_playlist.size() - 1;

    playTrack(prevIndex);
}

void AudioManager::setVolume(int volume)
{
    m_volume = qBound(0, volume, 100);
    m_audioOutput->setVolume(m_volume / 100.0f);
    emit volumeChanged();
}

void AudioManager::seek(int position)
{
    m_player->setPosition(static_cast<qint64>(position));
}
