/*
 * harbour-watchlist - Sailfish OS Version
 * Copyright © 2021 Andreas Wüst (andreas.wuest.freelancer@gmail.com)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
#ifndef ING_DIBA_UTILS_H
#define ING_DIBA_UTILS_H

#include <QObject>
#include <QTimeZone>

class IngDibaUtils {
public:
    IngDibaUtils() = default;

    static QDateTime convertTimestampToLocalTimestamp(const QString &utcDateTimeString, QTimeZone timeZone);
};

#endif // ING_DIBA_UTILS_H
