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
#ifndef CONSTANTS_H
#define CONSTANTS_H

const char MIME_TYPE_JSON[] = "application/json";
const char USER_AGENT[] = "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:73.0) Gecko/20100101 Firefox/73.0";

// euroinvestor
const char EUROINVESTOR_API_SEARCH[] = "https://search.euroinvestor.dk/instruments?q=";
const char EUROINVESTOR_API_QUOTE[] = "https://api.euroinvestor.dk/instruments?ids=";
const char EUROINVESTOR_API_CLOSE_PRICES[] = "https://api.euroinvestor.dk/instruments/%1/closeprices?fromDate=%2";
const char EUROINVESTOR_API_INTRADAY_PRICES[] = "https://api.euroinvestor.dk/instruments/%1/intradays";

// moscow exchange
const char MOSCOW_EXCHANGE_LANG_EN[] = "&lang=en";
const char MOSCOW_EXCHANGE_API_SEARCH[]
    = "http://iss.moex.com/iss/securities.json?q=%1&group_by_filter=stock_shares&limit=15%2";
const char MOSCOW_EXCHANGE_QUOTE[] = "https://iss.moex.com/iss/engines/stock/markets/shares/boards/"
                                     "TQBR/securities.json?securities=%1%2";
// can fetch max 100 entries at a time - so about a quarter
const char MOSCOW_EXCHANGE_API_CLOSE_PRICES[]
    = "https://iss.moex.com/iss/history/engines/stock/markets/shares/boards/TQBR/securities/"
      "%1.json?from=%2%3";

// Ing-Diba
const char ING_DIBA_API_SEARCH[] = "https://api.wertpapiere.ing.de/suche-autocomplete/autocomplete?query=%1";
const char ING_DIBA_API_QUOTE[] = "https://component-api.wertpapiere.ing.de/api/v1/components/instrumentheader/%1";
// currencyId and exchangeId seem not to be relevant
const char ING_DIBA_API_CHART_PRICES[] = "https://component-api.wertpapiere.ing.de/api/v1/charts/shm/%1?timeRange=%2";
const char ING_DIBA_API_PREQUOTE_DATA[] = "https://component-api.wertpapiere.ing.de/api/v1/components/chart/%1";

const char ING_DIBA_NEWS[] = "https://component-api.wertpapiere.ing.de/api/v1/components/companyprofilenews/%1?pageNumber=%2&newsCategory=0";

// NetworkReply Property constants
const char NETWORK_REPLY_PROPERTY_CHART_TYPE[] = "chartType";
const char NETWORK_REPLY_PROPERTY_EXT_REF_ID[] = "extRefId";

#endif // CONSTANTS_H
