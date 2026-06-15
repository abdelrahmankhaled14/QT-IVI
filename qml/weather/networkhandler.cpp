#include "networkhandler.h"

#include <QUrl>
#include <QUrlQuery>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QNetworkRequest>

static const QString API_BASE =
    QStringLiteral("https://api.openweathermap.org/data/2.5/weather");

NetworkHandler::NetworkHandler(QObject *parent)
    : QObject(parent),
    m_networkManager(new QNetworkAccessManager(this))
{
    connect(m_networkManager, &QNetworkAccessManager::finished,
            this, &NetworkHandler::onReplyFinished);/*sender signal reciver slot*/
}

void NetworkHandler::setApiKey(const QString &key)
{
    m_apiKey = key;
}

void NetworkHandler::fetchWeather(const QString &city)
{
    if (m_apiKey.isEmpty()) {
        emit errorOccurred("API key not configured.");
        return;
    }
    if (city.trimmed().isEmpty()) {
        emit errorOccurred("City name cannot be empty.");
        return;
    }

    QUrl url(API_BASE);/*object of QUrl which can work with any website */
    QUrlQuery params;
    params.addQueryItem("q",     city.trimmed());/*the way i want data from website q,appid,units are varibles from weather app itself*/
    params.addQueryItem("appid", m_apiKey);
    params.addQueryItem("units", "metric");
    url.setQuery(params);/* object url have to know how exactly you want data */

    QNetworkRequest request(url); /*object that will make request from website */
    request.setAttribute(
        QNetworkRequest::RedirectPolicyAttribute,
        QNetworkRequest::NoLessSafeRedirectPolicy
        );
    m_networkManager->get(request); /*getting data finally*/
}

void NetworkHandler::onReplyFinished(QNetworkReply *reply)
{
    reply->deleteLater();
    const QByteArray body = reply->readAll();

    if (reply->error() != QNetworkReply::NoError) {
        if (reply->error() == QNetworkReply::HostNotFoundError ||
            reply->error() == QNetworkReply::NetworkSessionFailedError ||
            reply->error() == QNetworkReply::UnknownNetworkError)
        {
            emit errorOccurred("No internet connection. Check your network.");
            return;
        }
        /*check on error of network*/
        emit errorOccurred(reply->errorString());
        return;
    }
    QJsonParseError jsonErr;
    QJsonDocument doc = QJsonDocument::fromJson(body, &jsonErr);
    QJsonObject root = doc.object();
    QJsonValue codVal = root.value("cod");

    int cod = codVal.toInt();
    if (cod != 200) {
        QString msg = root.value("message").toString("Unknown server error.");
        emit errorOccurred(msg);
        return;
    }

    emit weatherDataReceived(parseWeatherJson(root));/*send signal to weathermodel*/
}

WeatherData NetworkHandler::parseWeatherJson(const QJsonObject &root) const
{
    WeatherData d; /*just putting everything inside json file comming from website in the struct weatherData*/
    /*i know the way to access data inside json from website documention they say where to find every */
    d.cityName = root.value("name").toString();

    QJsonObject sys = root.value("sys").toObject();
    d.country = sys.value("country").toString();

    QJsonObject main = root.value("main").toObject();
    d.temperature = main.value("temp").toDouble();
    d.feelsLike   = main.value("feels_like").toDouble();
    d.tempMin     = main.value("temp_min").toDouble();
    d.tempMax     = main.value("temp_max").toDouble();
    d.humidity    = main.value("humidity").toInt();
    d.pressure    = main.value("pressure").toInt();
    QJsonObject wind = root.value("wind").toObject();
    d.windSpeed = wind.value("speed").toDouble();

    QJsonArray weatherArr = root.value("weather").toArray();
    if (!weatherArr.isEmpty()) {
        QJsonObject w = weatherArr[0].toObject();
        d.condition   = w.value("main").toString();
        d.description = w.value("description").toString();
        d.iconCode    = w.value("icon").toString();
    }

    return d;
}
