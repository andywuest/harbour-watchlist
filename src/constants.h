#ifndef CONSTANTS_H
#define CONSTANTS_H

const char MIME_TYPE_JSON[] = "application/json";
const char USER_AGENT[] = "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:73.0) Gecko/20100101 Firefox/73.0";

// euroinvestor
const char EUROINVESTOR_API_SEARCH[] = "https://search.euroinvestor.dk/instruments?q=";
const char EUROINVESTOR_API_QUOTE[] = "https://api.euroinvestor.dk/instruments?ids=";
const char EUROINVESTOR_API_CLOSE_PRICES[] = "https://api.euroinvestor.dk/instruments/%1/closeprices?fromDate=%2";
const char EUROINVESTOR_API_INTRADAY_PRICES[] = "https://api.euroinvestor.dk/instruments/%1/intradays";


#endif // CONSTANTS_H
