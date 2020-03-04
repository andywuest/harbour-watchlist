/*
 * harbour-watchlist - Sailfish OS Version
 * Copyright © 2019 Andreas Wüst (andreas.wuest.freelancer@gmail.com)
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
import QtQuick 2.2
import QtQuick.LocalStorage 2.0
import Sailfish.Silica 1.0
import Nemo.Notifications 1.0

// TODO pfad anpassen
import "../js/functions.js" as Functions
import "../js/database.js" as Database

Item {
    id: notificationItem

    property string applicationName: "Watchlist"
    property string applicationIcon: "/usr/share/icons/hicolor/172x172/apps/harbour-watchlist.png"

    function createMinimumAlarm(alarmNotification) {
        var minimumPrice = Functions.renderPrice(alarmNotification.minimumPrice, alarmNotification.currency);
        //: AlarmNotification placeholder for stock name
        var summary = qsTr("%1").arg(alarmNotification.name);
        //: AlarmNotification stock dropped below
        var body = qsTr("The share has just dropped below %1.").arg(minimumPrice);
        publishNotification(alarmNotification.id, summary, body);
    }

    function createMaximumAlarm(alarmNotification) {
        var maximumPrice = Functions.renderPrice(alarmNotification.maximumPrice, alarmNotification.currency);
        //: AlarmNotification placeholder for stock name
        var summary = qsTr("%1").arg(alarmNotification.name);
        //: AlarmNotification stock has risen above
        var body = qsTr("The share has just risen above %1.").arg(maximumPrice);
        publishNotification(alarmNotification.id, summary, body);
    }

    function publishNotification(id, summary, body) {
        stockAlarmNotification.summary = summary;
        stockAlarmNotification.body = body;
        stockAlarmNotification.previewSummary = summary;
        stockAlarmNotification.previewBody = body;
        stockAlarmNotification.replacesId = id;
        stockAlarmNotification.publish();
        Database.disableAlarm(id);
        // TODO timestamp also?
        // TODO replacesid seems not to work properly -> shows up multiple times -> replacedId 0 ??
    }

    Notification {
        id: stockAlarmNotification
        appName: applicationName
        appIcon: applicationIcon
    }

}


