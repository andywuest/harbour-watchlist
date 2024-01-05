.pragma library

Qt.include('constants.js');

function renderChange(price, change, symbol) {
    var prefix = "";
    if (price === 0.0) {
        return "-";
    }
    if (change > 0.0) {
        prefix = "+"
    }
    return prefix + Number(change).toLocaleString(Qt.locale()) + " " + symbol;
}

function renderPercentage(value) {
    return Number(value).toLocaleString(Qt.locale()) + " %";
}

function renderPriceOnly(price) {
    var locale = Qt.locale();
    return ((price !== undefined && price !== 0.0) ? formatPrice(price, locale) : "");
}

function renderPrice(price, currencyString, marketDataType) {
    var locale = Qt.locale();
    if (marketDataType && marketDataType === MARKET_DATA_TYPE_NONE) {
        return ((price && price !== 0.0) ? formatPrice(price, locale, DEFAULT_FRACTION_DIGITS) + " " + currencyString : "")
    }
    if (marketDataType && marketDataType === MARKET_DATA_TYPE_CURRENCY) {
        return ((price && price !== 0.0) ? formatPrice(price, locale, CURRENCY_FRACTION_DIGITS) + " " + currencyString : "")
    }
    return ((price && price !== 0.0) ? formatPrice(price, locale) + " " + currencyString : "")
}

function formatPrice(price, locale, precision) {
    var localPrecision = DEFAULT_FRACTION_DIGITS; // 0-0.5 -> 6 digits, 0.5 -> 1.5 -> 4 digits, else 2 digits
    if (price >= 0.5 && price < 1.50) {
        localPrecision = MEDIUM_FRACTION_DIGITS;
    } else if (price < 0.5) {
        localPrecision = EXTENDED_FRACTION_DIGITS;
    }
    if (precision) {
        localPrecision = precision;
    }
    console.log("precision is : " + localPrecision)
    return Number(price).toLocaleString(locale, 'f', localPrecision);
}

function determineChangeColor(change, defaultColor) {
    if (change < 0.0) {
        return NEGATIVE_COLOR
    } else if (change > 0.0) {
        return POSITIVE_COLOR
    }
    return defaultColor;
}

function determineSecuritySortOrder(sortingOrder) {
    if (sortingOrder === SORTING_ORDER_BY_CHANGE) {
        return SORT_BY_CHANGE_DESC;
    } else if (sortingOrder === SORTING_ORDER_BY_PERFORMANCE) {
        return SORT_BY_PERFORMANCE_DESC;
    }
    return SORT_BY_NAME_ASC;
}

function renderDateTimeString(dateTimeString) {
    // TODO undefined check here
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

function calculateAttributeSumValue(stocks, callback) {
  var sum = 0.0;
  if (stocks && stocks.length > 0) {
    for (var index = 0; index < stocks.length; index++) {
      sum += callback(stocks[index]);
    }
  }
  return sum;
}

function cbPositionCostValue(stock) {
    return stock.positionCostValue;
}

function cbPositionCurrentValue(stock) {
    return stock.positionCurrentValue;
}

function calculatePercentage(positionValue, overallValue) {
    if (isNonNullValue(positionValue) && isNonNullValue(overallValue)) {
        return (positionValue * 100.0 / overallValue);
    }
    return 0.0;
}

function calculatePortfolioPerformanceString(stocks, currencySymbol) {
    if (!stocks || stocks.length === 0) {
        return "";
    }

    var depotCostValue = calculateAttributeSumValue(stocks, cbPositionCostValue);
    var depotCurrentValue = calculateAttributeSumValue(stocks, cbPositionCurrentValue);

    if (isNonNullValue(depotCostValue) && isNonNullValue(depotCurrentValue)) {
        var depotValueChangeAbsolute = depotCurrentValue - depotCostValue;
        var depotValueChangeRelative = (depotCurrentValue * 100.0 / depotCostValue) - 100.0;

        return renderChange(depotValueChangeAbsolute, depotValueChangeAbsolute, currencySymbol)
                + "  /  " + renderChange(depotValueChangeRelative, depotValueChangeRelative, "%");
    }

    return "";
}

function isNonNullValue(value) {
    if (value && value !== 0.0) {
        return true;
    }
    return false;
}

function log(message) {
    if (loggingEnabled && message) {
        console.log(message);
    }
}

function lookupMarketDataName(marketDataId) {
    for (var i = 0; i < MARKET_DATA_LIST.length; i++) {
        if (MARKET_DATA_LIST[i].id === marketDataId) {
            return MARKET_DATA_LIST[i].name;
        }
    }
    return "-";
}

function isValidDate(date) {
  return date && Object.prototype.toString.call(date) === "[object Date]" && !isNaN(date);
}
