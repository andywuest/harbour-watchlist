"use strict";
var DownloadData = /** @class */ (function () {
    function DownloadData() {
        this.contentType = "application/json;charset=utf-8"; // by default json
        this.timeout = 5000; // 5 seconds timeout
    }
    return DownloadData;
}());
var DownloadService = /** @class */ (function () {
    function DownloadService() {
    }
    DownloadService.prototype.execute = function (data, callback) {
        var httpRequest = new XMLHttpRequest();
        console.log("trying to fetch data from : " + data.url);
        httpRequest.open("GET", data.url);
        if (data.contentType !== null) {
            httpRequest.setRequestHeader("Content-Type", data.contentType);
        }
        if (data.eTag) {
            httpRequest.setRequestHeader("If-None-Match", data.eTag);
        }
        httpRequest.timeout = data.timeout;
        console.log("timeout defined : " + httpRequest.timeout);
        httpRequest.onreadystatechange = function () {
            if (httpRequest.readyState === XMLHttpRequest.DONE) {
                if (httpRequest.status && httpRequest.status === 200 && httpRequest.responseText !== "undefined") {
                    console.log("return status : " + httpRequest.status);
                    console.log("Resposne Headers : " + httpRequest.getAllResponseHeaders());
                    console.log("Resposne ETag : " + httpRequest.getResponseHeader("ETag"));
                    console.log("return responseText : " + httpRequest.responseText.substring(0, 200));
                    console.log("executing success callback !");
                    callback(0, httpRequest);
                    console.log("executing success done !");
                }
                else if (httpRequest.status && httpRequest.status === 304) {
                    callback(1, httpRequest);
                }
                else {
                    console.log("executing failure callback - data : " + httpRequest.response + " " + httpRequest.responseURL + " " + httpRequest.responseText);
                    callback(2, httpRequest);
                }
            }
        };
        httpRequest.onerror = function (ev) {
            console.log("error code : " + httpRequest.status);
            console.log("event : " + ev.currentTarget);
        };
        try {
            httpRequest.send();
        }
        catch (error) {
            callback(3, error);
        }
    };
    return DownloadService;
}());
var EuroinvestorBackend = /** @class */ (function () {
    function EuroinvestorBackend() {
    }
    EuroinvestorBackend.prototype.search = function (key, callback) {
        var downloadService = new DownloadService();
        var downloadData = new DownloadData();
        downloadData.url = this.getSearchUrl(key);
        downloadService.execute(downloadData, callback);
    };
    EuroinvestorBackend.prototype.convertSearchResponse = function (responseText) {
        var response = JSON.parse(responseText);
        return response.map(function (item) { return new SearchResultStockData(item); });
    };
    EuroinvestorBackend.prototype.store = function (stockData) {
        throw new Error("Method not implemented.");
    };
    EuroinvestorBackend.prototype.getSearchUrl = function (searchKey) {
        return "https://search.euroinvestor.dk/instruments?q=" + searchKey;
    };
    EuroinvestorBackend.prototype.getQuoteUrl = function (quoteKey) {
        return "https://api.euroinvestor.dk/instruments?ids=" + quoteKey;
    };
    // TODO wird der return wert ueberhaupt benoetigt?
    EuroinvestorBackend.prototype.updateQuotes = function (stocks, stockFinishedCallback, allStocksFinishedCallback, timeoutInSeconds) {
        var downloadService = new DownloadService();
        var quoteKeys = stocks.map(function (stock) { return stock.extRefId; }).join(",");
        console.log("query keys : " + quoteKeys);
        var quoteFunction = function (returnCode, responseText) {
            if (returnCode === 0) {
                var response = JSON.parse(responseText.responseText);
                var results = response.map(function (item) { return new QuoteResultStockQuote(item); });
                // TODO simplify                
                results.forEach(function (resultQuote) { return stocks.forEach(function (stock) {
                    if ("" + resultQuote.extRefId === stock.extRefId) {
                        stockFinishedCallback(resultQuote, stock);
                    }
                }); });
                var numberOfFailedStocks = stocks.length - response.length;
                allStocksFinishedCallback(stocks.length, numberOfFailedStocks);
            }
            else if (returnCode === 2) {
                allStocksFinishedCallback(stocks.length, stocks.length);
            }
        };
        var downloadData = new DownloadData();
        downloadData.contentType = null;
        downloadData.timeout = timeoutInSeconds * 1000;
        downloadData.url = this.getQuoteUrl(quoteKeys);
        downloadService.execute(downloadData, quoteFunction);
        return null;
    };
    // TIDI wird das ueberhaupt benoetigt?
    EuroinvestorBackend.prototype.convertQuoteResponse = function (responseText, symbol) {
        //        let lines: string[] = responseText.split("\n");
        //        let result: Array<IStockQuote> = lines
        //            .filter(line => line.length > 0)
        //            .filter(line => line.indexOf("|" + symbol + "|") !== -1)
        //            .map(line => new QuoteResultStockQuote(line));
        //        if (result.length > 0) {
        //            // get first symbol may not be unique (e.g Airbus E:AIR)
        //            return result[0];
        //        }
        throw new Error("Unexpected number of results : " /*+ result*/);
    };
    EuroinvestorBackend.prototype.convertSearchResponseToStockData = function (searchResponse) {
        return new StockData(searchResponse);
    };
    // TODO move -> independent of backend
    EuroinvestorBackend.prototype.getMaxChange = function (stocks) {
        // https://stackoverflow.com/questions/4020796/finding-the-max-value-of-an-attribute-in-an-array-of-objects
        // added handling for negative ones
        return Math.max.apply(Math, stocks.map(function (o) { return Math.abs(o.changeRelative); }));
    };
    EuroinvestorBackend.prototype.sortByChangeAsc = function (stocks) {
        return stocks.sort(function (a, b) { return (a.changeRelative > b.changeRelative) ? 1 : ((b.changeRelative > a.changeRelative) ? -1 : 0); });
    };
    EuroinvestorBackend.prototype.sortByChangeDesc = function (stocks) {
        return stocks.sort(function (a, b) { return (a.changeRelative > b.changeRelative) ? -1 : ((b.changeRelative > a.changeRelative) ? 1 : 0); });
    };
    return EuroinvestorBackend;
}());
var QuoteResultStockQuote = /** @class */ (function () {
    function QuoteResultStockQuote(response) {
        this.price = response.last;
        this.changeAbsolute = response.change;
        this.changeRelative = response.changeInPercentage;
        this.quoteTimestamp = new Date(response.updatedAt);
        this.extRefId = "" + response.id;
        this.currency = response.currency;
        this.ask = response.ask;
        this.bid = response.bid;
        this.high = response.high;
        this.low = response.low;
        this.stockMarketName = response.exchange.name;
        this.lastChangeTimestamp = new Date();
    }
    return QuoteResultStockQuote;
}());
var SearchResultStockData = /** @class */ (function () {
    function SearchResultStockData(responseItem) {
        this.name = responseItem._source.name;
        this.isin = responseItem._source.isin;
        this.symbol1 = responseItem._source.symbol;
        this.extRefId = "" + responseItem._source.id;
    }
    return SearchResultStockData;
}());
var StockData = /** @class */ (function () {
    function StockData(searchStockData) {
        this.name = searchStockData.name;
        this.currency = searchStockData.currency;
        this.stockMarketSymbol = searchStockData.stockMarketSymbol;
        this.stockMarketName = searchStockData.stockMarketName;
        this.isin = searchStockData.isin;
        this.symbol1 = searchStockData.symbol1;
        this.symbol2 = searchStockData.symbol2;
        this.extRefId = searchStockData.extRefId;
        this.price = null;
        this.changeAbsolute = null;
        this.changeRelative = null;
        this.quoteTimestamp = null;
        this.lastChangeTimestamp = null;
    }
    return StockData;
}());
function createEuroinvestorBackend() {
    return new EuroinvestorBackend();
}
/// <reference path="../../DownloadData" />
/// <reference path="../../DownloadService" />
/// <reference path="../../WatchlistInterfaces" />
/// <reference path="EuroinvestorInterfaces" />
/// <reference path="EuroinvestorBackend" />
/// <reference path="EuroinvestorFactories" />
// aggregation of all the modules needed for the server!
