#ifndef NETWORKHANDLER_H
#define NETWORKHANDLER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonObject>
#include "WeatherData.h"

class NetworkHandler : public QObject
{
    Q_OBJECT

public:
    explicit NetworkHandler(QObject *parent = nullptr);
    void setApiKey(const QString &key);
    void fetchWeather(const QString &city);

signals:
    void weatherDataReceived(const WeatherData &data);
    void errorOccurred(const QString &errorMessage);

private slots:
    void onReplyFinished(QNetworkReply *reply);

private:
    QNetworkAccessManager *m_networkManager;
    QString m_apiKey;
    WeatherData parseWeatherJson(const QJsonObject &root) const;
};

#endif // NETWORKHANDLER_H
