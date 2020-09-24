#ifndef CONSTANTS_H
#define CONSTANTS_H

const char MIME_TYPE_JSON[] = "application/json";
const char USER_AGENT[] = "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:73.0) Gecko/20100101 Firefox/73.0";

// euroinvestor
const char EUROINVESTOR_API_SEARCH[] = "https://search.euroinvestor.dk/instruments?q=";
const char EUROINVESTOR_API_QUOTE[] = "https://api.euroinvestor.dk/instruments?ids=";
const char EUROINVESTOR_API_CLOSE_PRICES[] = "https://api.euroinvestor.dk/instruments/%1/closeprices?fromDate=%2";
const char EUROINVESTOR_API_INTRADAY_PRICES[] = "https://api.euroinvestor.dk/instruments/%1/intradays";

// Ing-Diba
const char ING_DIBA_API_SEARCH[] = "https://api.wertpapiere.ing.de/suche-autocomplete/autocomplete?query=%1";
const char ING_DIBA_API_QUOTE[] = "https://component-api.wertpapiere.ing.de/api/v1/components/instrumentheader/%1";
// currencyId and exchangeId seem not to be relevant
const char ING_DIBA_API_CHART_PRICES[] = "https://component-api.wertpapiere.ing.de/api/v1/charts/shm/%1?timeRange=%2";
const char ING_DIBA_API_PREQUOTE_DATA[] = "https://component-api.wertpapiere.ing.de/api/v1/components/chart/%1";


#endif // CONSTANTS_H
