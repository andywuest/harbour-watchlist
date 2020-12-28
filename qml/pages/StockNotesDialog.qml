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
    id: stockNotesDialog
    property var selectedSecurity
    property int watchlistId: 1 // TODO the default watchlistId as long as we only support one watchlist

    Column {
        id: topColumn
        width: parent.width

        DialogHeader {
        }

        SectionHeader {
            text: qsTr("Stock notes")
        }

        TextArea {
            id: stockNotesTextArea
            placeholderText: qsTr("Enter your notes here!")
            width: parent.width
            anchors {
                left: parent.left
                right: parent.right
                margins: Theme.paddingLarge
            }
        }
    }

    Component.onCompleted: {
        var security = Database.loadStockBy(watchlistId, selectedSecurity.extRefId);
        if (security) {
            var notes = Database.loadStockNotes(security.id);
            console.log("Restoring security notes : " + notes);
            if (notes) {
                stockNotesTextArea.text = notes;
            }
        }
    }

    onDone: {
        if (DialogResult.Accepted == result) {
            var security = Database.loadStockBy(watchlistId, selectedSecurity.extRefId);
            if (security) {
                console.log("Saving stock notes : " + stockNotesTextArea.text);
                Database.saveStockNotes(security.id, stockNotesTextArea.text);
            }
        }
    }

}
