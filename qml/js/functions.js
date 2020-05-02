
Qt.include('constants.js');

function renderChange(price, change, symbol) {
    var prefix = "";
    if (price === 0.0) {
        return "-";
    }
    if (change > 0.0) {
        prefix = "+"
    }
    var locale = Qt.locale();
    return prefix + Number(change).toLocaleString(locale) + " " + symbol
}

function renderPriceOnly(price) {
    var locale = Qt.locale();
    return ((price !== undefined && price !== 0.0) ? Number(price).toLocaleString(locale) : "");
}

function renderPrice(price, currencyString) {
    var locale = Qt.locale();
    return ((price !== undefined && price !== 0.0) ? Number(price).toLocaleString(locale) + " " + resolveCurrencySymbol(currencyString) : "-")
}

function resolveCurrencySymbol(currencyString) {
    var currencySymbol = CURRENCY_MAP[currencyString];
    if (currencySymbol === undefined)  {
        return currencyString;
    }
    return currencySymbol;
}

function determineChangeColor(change) {
    var color = Theme.primaryColor
    if (change < 0.0) {
        color = NEGATIVE_COLOR
    } else if (change > 0.0) {
        color = POSITIVE_COLOR
    }
    return color
}

function renderDateTimeString(dateTimeString) {
    if (dateTimeString !== null && dateTimeString !== "undefined"
            && dateTimeString !== "") {
        var date = Date.fromLocaleString(Qt.locale("de_DE"), dateTimeString, "yyyy-MM-dd hh:mm:ss")
        return date.toLocaleDateString(Qt.locale(), qsTr("dd.MM.yyyy")) + " " + date.toLocaleTimeString(Qt.locale(), qsTr("hh:mm:ss"));
    }
}

function determineQuoteDate(dateTimeString) {
    if (dateTimeString !== null && dateTimeString !== "undefined"
            && dateTimeString !== "") {
        var date = Date.fromLocaleString(Qt.locale("de_DE"), dateTimeString, "yyyy-MM-dd hh:mm:ss")

        var currentDateString = new Date().toLocaleDateString(Qt.locale(), "yyyy-MM-dd")
        var quoteDateString = date.toLocaleDateString(Qt.locale(), "yyyy-MM-dd")

        // if quote is from today - show only time - else show date
        if (currentDateString === quoteDateString) {
            return date.toLocaleTimeString(Qt.locale(), qsTr("hh:mm"))
        } else {
            return date.toLocaleDateString(Qt.locale(), qsTr("dd.MM.yyyy"))
        }
    }
    return "-"
}

function calculateVisibleStringLength(value) {
   return (value !== undefined) ? value.replace(/\s/g, "").length : 0;
}

function calculateMaxChange(stocks) {
    // https://stackoverflow.com/questions/4020796/finding-the-max-value-of-an-attribute-in-an-array-of-objects
    // added handling for negative ones
    if (stocks && stocks.length > 0) {
        return Math.max.apply(Math, stocks.map(function (o) { return Math.abs(o.changeRelative); }));
    }
    return 0.0;
}

function calculateWidth(price, change, maxChange, parentWidth) {
    // no price so far -> hide bar by setting with 0
    if (price === 0.0) {
        return 0;
    }
    if (maxChange === 0.0) {
        return parentWidth
    } else {
        var result = parentWidth * Math.abs(
                    change) / maxChange
        console.log("change length: " + result)
        return result
    }
}

function getDataBackend(backendId) {
    if (BACKEND_EUROINVESTOR === backendId) {
        return euroinvestorBackend;
    } else if (BACKEND_MOSCOW_EXCHANGE === backendId) {
        return moscowExchangeBackend;
    }
}

function getNewsBackend() {
    return onvistaNews
}

function log(message) {
    if (loggingEnabled && message) {
        console.log(message);
    }
}


