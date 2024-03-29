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
import QtQuick 2.2
import QtQuick.LocalStorage 2.0
import Sailfish.Silica 1.0

import "../js/database.js" as Database
import "../js/functions.js" as Functions

Dialog {
    id: referencePriceDialog
    property var selectedSecurity
    property int watchlistId
    property bool referencePriceEnabled: false
    signal updateReferencePriceInModel(int securityId, real referencePrice)
    signal updatePiecesInModel(int securityId, real pieces)

    function updateReferencePrice(security, referencePrice) {
        Functions.log("[ReferencePrice] Saving reference price : " + referencePrice);
        Database.saveReferencePrice(security.id, referencePrice);
        updateReferencePriceInModel(security.id, referencePrice);
    }

    function updatePieces(security, pieces) {
        Functions.log("[ReferencePrice] Saving pieces : " + pieces);
        Database.savePieces(security.id, pieces);
        updatePiecesInModel(security.id, pieces);
    }

    Column {
        id: topColumn
        width: parent.width

        DialogHeader {
        }

        TextSwitch {
            id: referencePriceTextSwitch
            text: qsTr("Configure reference price")
            description: qsTr("Reference price for the security which can be used to display the performance.")
            checked: referencePriceEnabled
            onCheckedChanged: {
                referencePriceEnabled = checked
            }
        }

        SectionHeader {
            text: qsTr("Reference price")
            visible: referencePriceTextSwitch.checked
        }

        TextField {
            id: referencePriceTextField
            //: ReferencePriceDialog textarea to enter notes
            placeholderText: qsTr("Enter the reference price here!")
            width: parent.width
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            visible: referencePriceTextSwitch.checked
            anchors {
                left: parent.left
                right: parent.right
                margins: Theme.paddingLarge
            }
        }

        SectionHeader {
            text: qsTr("Pieces")
            visible: referencePriceTextSwitch.checked
        }

        TextField {
            id: piecesTextField
            //: ReferencePriceDialog textarea to enter notes
            placeholderText: qsTr("Enter the number of pieces here!")
            width: parent.width
            inputMethodHints: Qt.ImhDigitsOnly
            visible: referencePriceTextSwitch.checked
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
            var referencePrice = Database.loadReferencePrice(security.id);
            var pieces = Database.loadPieces(security.id);
            Functions.log("[ReferencePrice] Restoring security referencePrice : " + referencePrice);
            Functions.log("[ReferencePrice] Restoring security pieces : " + pieces);
            var locale = Qt.locale();
            if (referencePrice) {
                referencePriceTextField.text = Number(referencePrice).toLocaleString(locale);
                referencePriceEnabled = true;
            }
            if (pieces) {
                piecesTextField.text = '' + pieces;
            }
        }
    }

    onDone: {
        if (DialogResult.Accepted == result) {
            var security = Database.loadStockBy(watchlistId, selectedSecurity.extRefId);
            if (security) {
                if (referencePriceTextSwitch.checked) {
                    var locale = Qt.locale()
                    var referencePrice = Number.fromLocaleString(locale, referencePriceTextField.text)
                    updateReferencePrice(security, referencePrice);
                    var pieces = Number(piecesTextField.text);
                    updatePieces(security, pieces);
                } else {
                    updateReferencePrice(security, null);
                    updatePieces(security, null);
                }
            }
        }
    }

}
