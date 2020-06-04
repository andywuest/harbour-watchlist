.pragma library

var loggingEnabled = true;
var POSITIVE_COLOR = '#00FF00';
var NEGATIVE_COLOR = '#FF0000';

var SQL_TRUE = 1;
var SQL_FALSE = 0;

var CHART_TYPE_UNDEFINED = -1;
var CHART_TYPE_INTRDAY = 0;
var CHART_TYPE_MONTH = 1;
var CHART_TYPE_3_MONTHS = 2;
var CHART_TYPE_YEAR = 3;
var CHART_TYPE_3_YEARS = 4;
var CHART_TYPE_5_YEARS = 5;

// TODO move to CPP code
var CURRENCY_MAP = [];
CURRENCY_MAP['EUR'] = '\u20AC';
CURRENCY_MAP['USD'] = '$';

var SORTING_ORDER_BY_CHANGE = 0;
var SORTING_ORDER_BY_NAME = 1;

var BACKEND_EUROINVESTOR = 0;
var BACKEND_MOSCOW_EXCHANGE = 1;

var CHART_DATA_DOWNLOAD_STRATEGY_ALWAYS = 0;
var CHART_DATA_DOWNLOAD_STRATEGY_ONLY_ON_WIFI = 1;
var CHART_DATA_DOWNLOAD_STRATEGY_MANUALLY = 2;

var NEWS_DATA_DOWNLOAD_STRATEGY_ALWAYS = 0;
var NEWS_DATA_DOWNLOAD_STRATEGY_ONLY_ON_WIFI = 1;

var MARKET_DATA_TYPE_COMMODITY = 1;
var MARKET_DATA_TYPE_INDEX = 2;
var MARKET_DATA_TYPE_CURRENCY = 3;
var MARKET_DATA_TYPE_CRYPTO = 4;

var MARKET_DATA_TYPE_LABEL = [];
MARKET_DATA_TYPE_LABEL[MARKET_DATA_TYPE_INDEX] = qsTr("Index");
MARKET_DATA_TYPE_LABEL[MARKET_DATA_TYPE_COMMODITY] = qsTr("Commodity");
MARKET_DATA_TYPE_LABEL[MARKET_DATA_TYPE_CURRENCY] = qsTr("Currency");
MARKET_DATA_TYPE_LABEL[MARKET_DATA_TYPE_CRYPTO] = qsTr("Crypto");

function addMarketDataItem(id, name, marketDataType) {
    var entry = {};
    entry.id = id;
    entry.name = name;
    entry.typeId = marketDataType;
    entry.stockMarketName = ""; // TODO remove
    entry.typeName = MARKET_DATA_TYPE_LABEL[marketDataType];
    return entry;
}

function buildMarketDataList() {
    var marketDataList = [];
    // Index
    // DE
    marketDataList.push(addMarketDataItem("INDEX_DAX", "DAX 30", MARKET_DATA_TYPE_INDEX));
    marketDataList.push(addMarketDataItem("INDEX_MDAX", "MDAX", MARKET_DATA_TYPE_INDEX));
    marketDataList.push(addMarketDataItem("INDEX_SDAX", "SDAX", MARKET_DATA_TYPE_INDEX));
    marketDataList.push(addMarketDataItem("INDEX_TECDAX", "TecDAX", MARKET_DATA_TYPE_INDEX));
    // US
    marketDataList.push(addMarketDataItem("INDEX_S&P500", "S&P 500", MARKET_DATA_TYPE_INDEX));
    marketDataList.push(addMarketDataItem("INDEX_NASDAQ", "NASDAQ Composite", MARKET_DATA_TYPE_INDEX));
    marketDataList.push(addMarketDataItem("INDEX_DOWJONES", "Dow Jones", MARKET_DATA_TYPE_INDEX));
    // France
    marketDataList.push(addMarketDataItem("INDEX_CAC40", "CAC 40", MARKET_DATA_TYPE_INDEX));
    marketDataList.push(addMarketDataItem("INDEX_SBF120", "SBF 120", MARKET_DATA_TYPE_INDEX));
    marketDataList.push(addMarketDataItem("INDEX_CN20", "CAC Next20", MARKET_DATA_TYPE_INDEX));

    marketDataList.push(addMarketDataItem("INDEX_OMC_C25", "OMX C25", MARKET_DATA_TYPE_INDEX));
    marketDataList.push(addMarketDataItem("INDEX_OMXS30", "OMX Stockholm 30", MARKET_DATA_TYPE_INDEX));
    marketDataList.push(addMarketDataItem("INDEX_OSEBX", "OSEBX", MARKET_DATA_TYPE_INDEX));

    // Commodity
    marketDataList.push(addMarketDataItem("COM_GOLD", "Gold", MARKET_DATA_TYPE_COMMODITY));
    marketDataList.push(addMarketDataItem("COM_SILVER", "Silver", MARKET_DATA_TYPE_COMMODITY));
    marketDataList.push(addMarketDataItem("COM_PLATINUM", "Platinum", MARKET_DATA_TYPE_COMMODITY));
    marketDataList.push(addMarketDataItem("COM_PALLADIUM", "Palladium", MARKET_DATA_TYPE_COMMODITY));

    // Currency
    marketDataList.push(addMarketDataItem("CUR_EUR_USD", "EUR/USD", MARKET_DATA_TYPE_CURRENCY));
    marketDataList.push(addMarketDataItem("CUR_SEK_DKK", "SEK/DKK", MARKET_DATA_TYPE_CURRENCY));
    marketDataList.push(addMarketDataItem("CUR_GBP_DKK", "GBP/DKK", MARKET_DATA_TYPE_CURRENCY));
    marketDataList.push(addMarketDataItem("CUR_GBP_USD", "GBP/USD", MARKET_DATA_TYPE_CURRENCY));
    marketDataList.push(addMarketDataItem("CUR_JPY_USD", "JPY/USD", MARKET_DATA_TYPE_CURRENCY));
    marketDataList.push(addMarketDataItem("CUR_CHF_EUR", "CHF/EUR", MARKET_DATA_TYPE_CURRENCY));
    marketDataList.push(addMarketDataItem("CUR_GBP_EUR", "GBP/EUR", MARKET_DATA_TYPE_CURRENCY));
    marketDataList.push(addMarketDataItem("CUR_USD_EUR", "USD/EUR", MARKET_DATA_TYPE_CURRENCY));

    // Crypto
    marketDataList.push(addMarketDataItem("CRYPTO_BITCOIN", "Bitcoin", MARKET_DATA_TYPE_CRYPTO));
    marketDataList.push(addMarketDataItem("CRYPTO_BITCOIN_CASH", "Bitcoin Cash", MARKET_DATA_TYPE_CRYPTO));
    marketDataList.push(addMarketDataItem("CRYPTO_BITCOIN_GOLD", "Bitcoin Gold", MARKET_DATA_TYPE_CRYPTO));
    marketDataList.push(addMarketDataItem("CRYPTO_LITECOIN", "Litecoin", MARKET_DATA_TYPE_CRYPTO));
    marketDataList.push(addMarketDataItem("CRYPTO_DASH", "Dash", MARKET_DATA_TYPE_CRYPTO));
    marketDataList.push(addMarketDataItem("CRYPTO_ETHEREUM", "Ethereum", MARKET_DATA_TYPE_CRYPTO));
    marketDataList.push(addMarketDataItem("CRYPTO_TETHER", "Tether", MARKET_DATA_TYPE_CRYPTO));
    marketDataList.push(addMarketDataItem("CRYPTO_IOTA", "IOTA", MARKET_DATA_TYPE_CRYPTO));
    marketDataList.push(addMarketDataItem("CRYPTO_MONERO", "Monero", MARKET_DATA_TYPE_CRYPTO));
    marketDataList.push(addMarketDataItem("CRYPTO_BINANCE_COIN", "Binance Coin", MARKET_DATA_TYPE_CRYPTO));
    marketDataList.push(addMarketDataItem("CRYPTO_XRP", "XRP", MARKET_DATA_TYPE_CRYPTO));
    marketDataList.push(addMarketDataItem("CRYPTO_TEZOS", "Tezos", MARKET_DATA_TYPE_CRYPTO));
    marketDataList.push(addMarketDataItem("CRYPTO_CARDANO", "Cardano", MARKET_DATA_TYPE_CRYPTO));
    marketDataList.push(addMarketDataItem("CRYPTO_CHAINLINK", "Chainlink", MARKET_DATA_TYPE_CRYPTO));

    return marketDataList;
}

var MARKET_DATA_LIST = buildMarketDataList();
