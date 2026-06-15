#include "weatherviewmodel.h"
#include "networkhandler.h"
#include <QTimer>

WeatherViewModel::WeatherViewModel(QObject *parent)
    : QObject(parent),
    m_network(new NetworkHandler(this))
{
    m_network->setApiKey(QStringLiteral("f03e7206e811454b8eddc11a157afec0"));

    connect(m_network, &NetworkHandler::weatherDataReceived,
            this, &WeatherViewModel::handleWeatherData);/*sender signal reciver slot*/
    connect(m_network, &NetworkHandler::errorOccurred,
            this, &WeatherViewModel::handleError);/*sender signal reciver slot*/

    // Set a default city so refresh() works immediately
    m_lastCity = QStringLiteral("Cairo");

    // Auto-fetch on startup using a singleshot timer
    // so the event loop is ready before the network call
    QTimer::singleShot(500, this, &WeatherViewModel::refresh);
}

int     WeatherViewModel::appState()     const { return static_cast<int>(m_state); }
bool    WeatherViewModel::isLoading()    const { return m_state == Loading; }
bool    WeatherViewModel::splashDone()   const { return m_splashDone; }
QString WeatherViewModel::errorMessage() const { return m_errorMessage; }

QString WeatherViewModel::cityName()    const { return m_data.cityName; }
QString WeatherViewModel::country()     const { return m_data.country; }
double  WeatherViewModel::temperature() const { return m_data.temperature; }
double  WeatherViewModel::feelsLike()   const { return m_data.feelsLike; }
double  WeatherViewModel::tempMin()     const { return m_data.tempMin; }
double  WeatherViewModel::tempMax()     const { return m_data.tempMax; }
int     WeatherViewModel::humidity()    const { return m_data.humidity; }
int     WeatherViewModel::pressure()    const {return m_data.pressure;  }
double  WeatherViewModel::windSpeed()   const { return m_data.windSpeed; }
QString WeatherViewModel::condition()   const { return m_data.condition; }
QString WeatherViewModel::description() const { return m_data.description; }


void WeatherViewModel::fetchWeather(const QString &city)
{
    const QString trimmed = city.trimmed();
    if (trimmed.isEmpty()) return;

    m_lastCity = trimmed;
    m_state = Loading;
    m_errorMessage.clear();
    emit stateChanged();
    emit errorMessageChanged();

    m_network->fetchWeather(trimmed);
}

void WeatherViewModel::refresh()
{
    if (!m_lastCity.isEmpty())
        fetchWeather(m_lastCity);
}

void WeatherViewModel::handleWeatherData(const WeatherData &data)
{
    m_data  = data;/*when network emit signal reply finished slot is what happen and it emit weatherDataReceived signal and this fiunction get called */
    m_state = Success;
    emit stateChanged();
    emit dataChanged();

    if (!m_splashDone) {
        m_splashDone = true;
        emit splashDoneChanged();
    }
}

void WeatherViewModel::handleError(const QString &msg)
{
    m_errorMessage = msg;
    m_state = Error;
    emit stateChanged();
    emit errorMessageChanged();

    if (!m_splashDone) {
        m_splashDone = true;
        emit splashDoneChanged();
    }
}

