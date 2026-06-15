#include "VideoManager.h"
#include <QDir>
#include <QFileInfo>
#include <QStandardPaths>
#include <QDebug>

VideoManager::VideoManager(QObject *parent) : QObject(parent)
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

QVariantList VideoManager::playlist()     const { return m_playlist; }
QString      VideoManager::currentTitle() const { return m_currentTitle; }
bool         VideoManager::playing()      const { return m_playing; }
int          VideoManager::volume()       const { return m_volume; }
int          VideoManager::position()     const { return m_position; }
int          VideoManager::duration()     const { return m_duration; }
QString      VideoManager::statusMsg()    const { return m_statusMsg; }
int          VideoManager::currentIndex() const { return m_currentIndex; }
QMediaPlayer* VideoManager::player()      const { return m_player; }
bool         VideoManager::loading()      const { return m_loading; }

QString VideoManager::defaultVideoPath() const
{
    QString path = QStandardPaths::writableLocation(QStandardPaths::MoviesLocation);
    if (path.isEmpty()) {
        path = QDir::homePath() + "/Videos";
    }
    return path;
}

void VideoManager::updateStatus(const QString &msg)
{
    m_statusMsg = msg;
    emit statusChanged();
}

void VideoManager::scanFolderInternal(const QString &path, bool clearFirst)
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
        "*.mp4", "*.mkv", "*.avi", "*.mov",
        "*.wmv", "*.flv", "*.webm", "*.m4v"
    };

    QFileInfoList files = dir.entryInfoList(
        filters,
        QDir::Files | QDir::NoDotAndDotDot,
        QDir::Name
        );

    for (const QFileInfo &file : files) {
        QVariantMap video;
        video["title"] = file.baseName();
        video["path"]  = file.absoluteFilePath();

        m_playlist.append(video);
    }

    // Also scan subdirectories
    QFileInfoList subdirs = dir.entryInfoList(
        QDir::Dirs | QDir::NoDotAndDotDot
        );

    for (const QFileInfo &subdir : subdirs) {
        scanFolderInternal(subdir.absoluteFilePath(), false);
    }
}

void VideoManager::scanFolder(const QString &path)
{
    m_loading = true;
    emit loadingChanged();
    updateStatus("Scanning folder...");

    scanFolderInternal(path, true);

    emit playlistChanged();

    m_loading = false;
    emit loadingChanged();

    if (m_playlist.isEmpty())
        updateStatus("No video files found in " + path);
    else
        updateStatus("Found " + QString::number(m_playlist.size()) + " videos");
}

void VideoManager::scanUSB()
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
        updateStatus("No USB drives found or no video files on them");
    else
        updateStatus("Found " + QString::number(m_playlist.size()) + " videos on USB");
}

void VideoManager::loadVideo(int index)
{
    if (index < 0 || index >= m_playlist.size()) return;

    m_loading = true;
    emit loadingChanged();

    QVariantMap video = m_playlist[index].toMap();
    QString path      = video["path"].toString();

    m_currentTitle = video["title"].toString();
    m_currentIndex = index;

    emit currentVideoChanged();

    m_player->setSource(QUrl::fromLocalFile(path));
    updateStatus("Now playing: " + m_currentTitle);
}

void VideoManager::playVideo(int index)
{
    loadVideo(index);
    m_player->play();
}

void VideoManager::playPause()
{
    if (m_playlist.isEmpty()) {
        updateStatus("No videos loaded!");
        return;
    }

    if (m_currentIndex < 0) {
        playVideo(0);
        return;
    }

    if (m_player->playbackState() == QMediaPlayer::PlayingState)
        m_player->pause();
    else
        m_player->play();
}

void VideoManager::stop()
{
    m_player->stop();
    m_playing = false;
    emit playingChanged();
    updateStatus("Stopped");
}

void VideoManager::next()
{
    if (m_playlist.isEmpty()) return;

    int nextIndex = m_currentIndex + 1;
    if (nextIndex >= m_playlist.size())
        nextIndex = 0;

    playVideo(nextIndex);
}

void VideoManager::previous()
{
    if (m_playlist.isEmpty()) return;

    if (m_position > 3000) {
        m_player->setPosition(0);
        return;
    }

    int prevIndex = m_currentIndex - 1;
    if (prevIndex < 0)
        prevIndex = m_playlist.size() - 1;

    playVideo(prevIndex);
}

void VideoManager::setVolume(int volume)
{
    m_volume = qBound(0, volume, 100);
    m_audioOutput->setVolume(m_volume / 100.0f);
    emit volumeChanged();
}

void VideoManager::seek(int position)
{
    m_player->setPosition(static_cast<qint64>(position));
}
