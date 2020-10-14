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
const char MOSCOW_EXCHANGE_API_SEARCH[] = "http://iss.moex.com/iss/securities.json?q=%1&group_by_filter=stock_shares&limit=15%2";
const char MOSCOW_EXCHANGE_QUOTE[] = "https://iss.moex.com/iss/engines/stock/markets/shares/boards/TQBR/securities.json?securities=%1%2";
// can fetch max 100 entries at a time - so about a quarter
const char MOSCOW_EXCHANGE_API_CLOSE_PRICES[] = "https://iss.moex.com/iss/history/engines/stock/markets/shares/boards/TQBR/securities/%1.json?from=%2%3";

// Ing-Diba
const char ING_DIBA_API_SEARCH[] = "https://api.wertpapiere.ing.de/suche-autocomplete/autocomplete?query=%1";
const char ING_DIBA_API_QUOTE[] = "https://component-api.wertpapiere.ing.de/api/v1/components/instrumentheader/%1";
// currencyId and exchangeId seem not to be relevant
const char ING_DIBA_API_CHART_PRICES[] = "https://component-api.wertpapiere.ing.de/api/v1/charts/shm/%1?timeRange=%2";
const char ING_DIBA_API_PREQUOTE_DATA[] = "https://component-api.wertpapiere.ing.de/api/v1/components/chart/%1";

// NetworkReply Property constants
const char NETWORK_REPLY_PROPERTY_CHART_TYPE[] = "chartType";
const char NETWORK_REPLY_PROPERTY_EXT_REF_ID[] = "extRefId";

#endif // CONSTANTS_H
