#ifndef WEATHERDATA_H
#define WEATHERDATA_H

#include <QString>

struct WeatherData {
    QString cityName;
    QString country;
    double  temperature  = 0.0;
    double  feelsLike    = 0.0;
    double  tempMin      = 0.0;
    double  tempMax      = 0.0;
    int     humidity     = 0;
    double  windSpeed    = 0.0;
    int     pressure     = 0;
    QString condition;
    QString description;
    QString iconCode;
};

#endif // WEATHERDATA_H
