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
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0

import "pages"
import "cover"

import "js/constants.js" as Constants
import "js/functions.js" as Functions

ApplicationWindow {

    // Global Settings Storage
    ConfigurationGroup {
        id: watchlistSettings
        path: "/apps/harbour-watchlist/settings"

        property int chartDataDownloadStrategy: Constants.CHART_DATA_DOWNLOAD_STRATEGY_ONLY_ON_WIFI
        property int sortingOrder: Constants.SORTING_ORDER_BY_CHANGE
        property int dataBackend: Constants.BACKEND_EUROINVESTOR
        property int newsDataDownloadStrategy: Constants.NEWS_DATA_DOWNLOAD_STRATEGY_ONLY_ON_WIFI
        property bool showPerformanceRow: false
        property date dividendsDataLastUpdate
    }

    function getSecurityDataBackend(backendId) {
        if (Constants.BACKEND_EUROINVESTOR === backendId) {
            return euroinvestorBackend;
        } else if (Constants.BACKEND_MOSCOW_EXCHANGE === backendId) {
            return moscowExchangeBackend;
        } else if (Constants.BACKEND_ING_DIBA === backendId) {
            return ingDibaBackend;
        }
    }

    function getNewsBackend() {
        return ingDibaNews;
    }

    function getMarketDataBackend() {
        return euroinvestorMarketDataBackend;
    }

    function getDividendBackend() {
        return divvyDiaryBackend;
    }

    function determineChangeColor(change) {
        // we cannot use the Function directory - because library has no access to Theme
        return Functions.determineChangeColor(change, Theme.primaryColor);
    }

    Component {
        id: overviewPage
        OverviewPage {
        }
    }

    Component {
        id: coverPage
        CoverPage {
        }
    }

    initialPage: overviewPage
    cover: coverPage
    allowedOrientations: defaultAllowedOrientations
}
