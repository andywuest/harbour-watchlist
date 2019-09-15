/*
 * harbour-watchlist - Sailfish OS Version
 * Copyright © 2017 Andreas Wüst (andreas.wuest.freelancer@gmail.com)
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

// QTBUG-34418
//import "."

import "../js/database.js" as Database
import "../js/functions.js" as Functions

Dialog {
    id: stockDetailsDialog
    property var stock
    property bool alarmEnabled: false

    Column {
        width: parent.width

        DialogHeader {
        }

        TextSwitch {
            id: stockAlarmTextSwitch
            text: qsTr("Configure Alarms")
            description: qsTr("Triggers a notification when the price of the stock is over the configured maximum price or under the configured minimum price.")
            checked: alarmEnabled
            onCheckedChanged: {
                alarmEnabled = checked
            }
        }

        // TODO properly align the text with padding
        // TODO dialog is not display when alaram does not yet exist
        Text {
            id: priceHinText
            width: parent.width
            visible: stockAlarmTextSwitch.checked
            color: Theme.primaryColor
            font.bold: true
            text: ""
        }

        // TODO validate and show error message
        TextField {
            id: minimumPriceTextField
            width: parent.width
            placeholderText: qsTr("Minimum price")
            visible: stockAlarmTextSwitch.checked
            // validator:   RegExpValidator { regExp: /^[0-9\+\-\#\*\ ]{6,}$/ }
            // color: errorHighlight? "red" : Theme.primaryColor
            inputMethodHints: Qt.ImhFormattedNumbersOnly
        }

        // TODO validate and show error message
        TextField {
            id: maximumPriceTextField
            width: parent.width
            placeholderText: qsTr("Maximum price")
            visible: stockAlarmTextSwitch.checked
            // validator:   RegExpValidator { regExp: /^[0-9\+\-\#\*\ ]{6,}$/ }
            // color: errorHighlight? "red" : Theme.primaryColor
            inputMethodHints: Qt.ImhDigitsOnly
        }

    }

    Component.onCompleted: {
        var alarm = Database.loadAlarm(stock.id)
        if (alarm !== undefined && alarm !== null && alarm.id !== undefined) {
            var locale = Qt.locale()
            alarmEnabled = true
            if (alarm.minimumPrice !== null && alarm.minimumPrice !== "") {
                minimumPriceTextField.text = Number(alarm.minimumPrice).toLocaleString(locale)
            }
            if (alarm.maximumPrice !== null && alarm.maximumPrice !== "") {
                maximumPriceTextField.text = Number(alarm.maximumPrice).toLocaleString(locale)
            }
            priceHinText.text = qsTr("The latest price for the stock was %0 %1.")
                .arg(Functions.renderPriceOnly(stock.price))
                .arg(Functions.resolveCurrencySymbol(stock.currency));
        }
    }

    onDone: {
        if (DialogResult.Accepted == result) {
            console.log("Save ")
            // TODO validation
            var alarm = {}
            alarm.id = stock.id;
            if (stockAlarmTextSwitch.checked) {
                alarm.minimumPrice = minimumPriceTextField.text
                alarm.maximumPrice = maximumPriceTextField.text
                Database.saveAlarm(alarm)
            } else {
                Database.removeAlarm(alarm)
            }
        }
    }

}
