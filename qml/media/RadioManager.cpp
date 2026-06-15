#include "RadioManager.h"
#include <QNetworkRequest>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QUrl>
#include <QDebug>

RadioManager::RadioManager(QObject *parent) : QObject(parent)
{
    m_loading = false;
    m_playing = false;
    m_volume  = 80;
    m_statusMsg = "Search for a genre to get started!";

    m_network = new QNetworkAccessManager(this);
    connect(m_network, &QNetworkAccessManager::finished,
            this, &RadioManager::onStationsReply);

    m_player = new QMediaPlayer(this);
    m_audioOutput = new QAudioOutput(this);

    m_player->setAudioOutput(m_audioOutput);
    m_audioOutput->setVolume(m_volume / 100.0f);

    connect(m_player, &QMediaPlayer::playbackStateChanged,
            this, [this](QMediaPlayer::PlaybackState state) {
                m_playing = (state == QMediaPlayer::PlayingState);
                emit playingChanged();
            });

    connect(m_player, &QMediaPlayer::errorOccurred,
            this, [this](QMediaPlayer::Error error, const QString &msg) {
                Q_UNUSED(error)
                updateStatus("Stream error: " + msg);
                m_playing = false;
                emit playingChanged();
            });
}

QVariantList RadioManager::stations()       const { return m_stations; }
QString      RadioManager::currentStation() const { return m_currentStation; }
QString      RadioManager::currentUrl()     const { return m_currentUrl; }
QString      RadioManager::statusMsg()      const { return m_statusMsg; }
bool         RadioManager::loading()        const { return m_loading; }
bool         RadioManager::playing()        const { return m_playing; }
int          RadioManager::volume()         const { return m_volume; }

void RadioManager::updateStatus(const QString &msg)
{
    m_statusMsg = msg;
    emit statusChanged();
}

void RadioManager::fetchStations(const QString &tag)
{
    if (tag.trimmed().isEmpty()) {
        updateStatus("Please enter a genre!");
        return;
    }

    m_loading = true;
    emit loadingChanged();
    updateStatus("Searching for " + tag + " stations...");

    QString url = "https://de1.api.radio-browser.info/json/stations/bytag/"
                  + tag.trimmed().toLower()
                  + "?limit=20&hidebroken=true&order=clickcount&reverse=true";

    m_network->get(QNetworkRequest(QUrl(url)));
}

void RadioManager::onStationsReply(QNetworkReply *reply)
{
    m_loading = false;
    emit loadingChanged();

    QByteArray data = reply->readAll();

    if (reply->error() != QNetworkReply::NoError) {
        updateStatus("Could not fetch stations");
        reply->deleteLater();
        return;
    }

    QJsonDocument doc  = QJsonDocument::fromJson(data);
    QJsonArray stations = doc.array();

    m_stations.clear();

    for (const QJsonValue &val : stations) {
        QJsonObject obj = val.toObject();

        QString name    = obj["name"].toString().trimmed();
        QString url     = obj["url_resolved"].toString();
        QString logo    = obj["favicon"].toString();
        QString country = obj["country"].toString();
        QString tags    = obj["tags"].toString();

        if (name.isEmpty() || url.isEmpty())
            continue;

        QVariantMap station;
        station["name"]    = name;
        station["url"]     = url;
        station["logo"]    = logo;
        station["country"] = country;
        station["tags"]    = tags;

        m_stations.append(station);
    }

    emit stationsChanged();

    if (m_stations.isEmpty())
        updateStatus("No stations found for that genre");
    else
        updateStatus("Found " + QString::number(m_stations.size()) + " stations");

    reply->deleteLater();
}

void RadioManager::playStation(const QString &url, const QString &name)
{
    if (url.isEmpty()) {
        updateStatus("Invalid station URL");
        return;
    }

    updateStatus("Connecting to " + name + "...");
    m_currentStation = name;
    m_currentUrl = url;
    emit currentStationChanged();

    m_player->stop();
    m_player->setSource(QUrl(url));
    m_player->play();

    updateStatus("Playing: " + name);
}

void RadioManager::togglePlayPause()
{
    if (m_currentUrl.isEmpty()) {
        updateStatus("No station selected");
        return;
    }

    if (m_playing) {
        stop();
    } else {
        playStation(m_currentUrl, m_currentStation);
    }
}

void RadioManager::stop()
{
    m_player->stop();
    m_playing = false;
    emit playingChanged();
    updateStatus("Stopped");
}

void RadioManager::setVolume(int volume)
{
    m_volume = qBound(0, volume, 100);
    m_audioOutput->setVolume(m_volume / 100.0f);
    emit volumeChanged();
}
