#ifndef WEATHERVIEWMODEL_H
#define WEATHERVIEWMODEL_H

#include <QObject>
#include "WeatherData.h"

class NetworkHandler;

class WeatherViewModel : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int     appState      READ appState      NOTIFY stateChanged)
    Q_PROPERTY(bool    isLoading     READ isLoading     NOTIFY stateChanged)
    Q_PROPERTY(bool    splashDone    READ splashDone    NOTIFY splashDoneChanged)
    Q_PROPERTY(QString errorMessage  READ errorMessage  NOTIFY errorMessageChanged)

    Q_PROPERTY(QString cityName      READ cityName      NOTIFY dataChanged)
    Q_PROPERTY(QString country       READ country       NOTIFY dataChanged)
    Q_PROPERTY(int     pressure      READ pressure      NOTIFY dataChanged)
    Q_PROPERTY(double  temperature   READ temperature   NOTIFY dataChanged)
    Q_PROPERTY(double  feelsLike     READ feelsLike     NOTIFY dataChanged)
    Q_PROPERTY(double  tempMin       READ tempMin       NOTIFY dataChanged)
    Q_PROPERTY(double  tempMax       READ tempMax       NOTIFY dataChanged)
    Q_PROPERTY(int     humidity      READ humidity      NOTIFY dataChanged)
    Q_PROPERTY(double  windSpeed     READ windSpeed     NOTIFY dataChanged)
    Q_PROPERTY(QString condition     READ condition     NOTIFY dataChanged)
    Q_PROPERTY(QString description   READ description   NOTIFY dataChanged)


public:
    enum State
    {
        Idle = 0,
        Loading = 1,
        Success = 2,
        Error = 3
    };

    Q_ENUM(State)

    explicit WeatherViewModel(QObject *parent = nullptr);

    int     appState()      const;
    bool    isLoading()     const;
    bool    splashDone()    const;
    QString errorMessage()  const;

    QString cityName()      const;
    QString country()       const;
    double  temperature()   const;
    double  feelsLike()     const;
    double  tempMin()       const;
    double  tempMax()       const;
    int     pressure()      const;
    int     humidity()      const;
    double  windSpeed()     const;
    QString condition()     const;
    QString description()   const;

    Q_INVOKABLE void fetchWeather(const QString &city);
    Q_INVOKABLE void refresh();

signals:
    void stateChanged();
    void dataChanged();
    void errorMessageChanged();
    void splashDoneChanged();

private slots:
    void handleWeatherData(const WeatherData &data);
    void handleError(const QString &msg);

private:
    NetworkHandler *m_network;
    WeatherData     m_data;
    State           m_state        = Idle;
    QString         m_errorMessage;
    QString         m_lastCity     = QStringLiteral("London");
    bool            m_splashDone   = false;

    static QString emojiForCondition(const QString &condition, const QString &icon);
};

#endif // WEATHERVIEWMODEL_H
