#include "ingdibautils.h"

#include <QDebug>

QDateTime IngDibaUtils::convertTimestampToLocalTimestamp(const QString &utcDateTimeString, const QTimeZone &timeZone) {
    QDateTime dt = QDateTime::fromString(utcDateTimeString, Qt::ISODate);
    dt.setTimeZone(timeZone);
    qDebug() << "dt : " << dt << "using timezone : " << timeZone;
    QDateTime localDateTime = dt.toLocalTime();
    return localDateTime;
}
