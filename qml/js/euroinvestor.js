"use strict";
/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
var DownloadData = /** @class */ (function () {
    function DownloadData() {
        this.contentType = "application/json;charset=utf-8"; // by default json
        this.timeout = 5000; // 5 seconds timeout
    }
    return DownloadData;
}());
/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
var DownloadService = /** @class */ (function () {
    function DownloadService() {
    }
    DownloadService.prototype.execute = function (data, callback) {
        var httpRequest = new XMLHttpRequest();
        console.log("trying to fetch data from : " + data.url);
        httpRequest.open('GET', data.url);
        if (data.contentType !== null) {
            httpRequest.setRequestHeader('Content-Type', data.contentType);
        }
        if (data.eTag) {
            httpRequest.setRequestHeader('If-None-Match', data.eTag);
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
    //  var url = currentPhotoId;
    //        var xhr = new XMLHttpRequest();
    //        xhr.open('GET', url, true);
    //        xhr.responseType = 'arraybuffer';
    //        xhr.onreadystatechange = function() {
    //            if (xhr.readyState === XMLHttpRequest.DONE) {
    //                if (xhr.status === 200) {
    //                    var response = new Uint8Array(xhr.response);
    //                    var raw = "";
    //                    for (var i = 0; i < response.byteLength; i++) {
    //                        raw += String.fromCharCode(response[i]);
    //                    }
    //
    //                    console.log("image fetched !");
    //
    //                    var image = 'data:image/png;base64,' +Constants.base64Encode(raw);
    //                            //
    //                    img.source = image;
    //                    fetchImages(photoIdUrls);
    //                }
    //            }
    //        }
    //        xhr.send();
    DownloadService.prototype.executeBinary = function (data, callback) {
        var httpRequest = new XMLHttpRequest();
        console.log("trying to fetch data from : " + data.url);
        httpRequest.open('GET', data.url);
        httpRequest.responseType = 'arraybuffer';
        // httpRequest.setRequestHeader('Content-Type', data.contentType);
        if (data.eTag) {
            httpRequest.setRequestHeader('If-None-Match', data.eTag);
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
                    var response = new Uint8Array(httpRequest.response);
                    var raw = "";
                    for (var i = 0; i < response.byteLength; i++) {
                        raw += String.fromCharCode(response[i]);
                    }
                    callback(0, httpRequest, raw);
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
        downloadData.contentType = null;
        downloadData.url = 'https://www.euroinvestor.com/completion/instrumentvertical2.aspx?q=' + key;
        downloadService.execute(downloadData, callback);
    };
    EuroinvestorBackend.prototype.convertSearchResponse = function (responseText) {
        var lines = responseText.split('\n');
        var result = lines.filter(function (line) { return line.length > 0; }).map(function (line) { return new SearchResultStockData(line); });
        return result;
    };
    EuroinvestorBackend.prototype.store = function (stockData) {
        throw new Error("Method not implemented.");
    };
    EuroinvestorBackend.prototype.updateQuotes = function (stocks, stockFinisheCallback, allStocksFinishedCallback, timeoutInSeconds) {
        if (stocks !== null && stocks.length > 0) {
            var downloadService = new DownloadService();
            // copy array and use it to track the finished stocks (sync object)
            var finishedStocks = stocks.slice(0);
            // create array with the stocks for which the update failed
            var failedStocks = new Array();
            var _loop_1 = function () {
                var stock = stocks[i];
                console.log("Looking up quote for " + stock.name);
                quoteFunction = function (returnCode, responseText) {
                    if (returnCode === 0) {
                        var result = new EuroinvestorBackend().convertQuoteResponse(responseText.responseText, stock.symbol1);
                        stockFinisheCallback(result, stock);
                    }
                    var currentStock = finishedStocks.pop();
                    if (returnCode === 2) {
                        failedStocks.push(currentStock);
                    }
                    console.log("still running : " + finishedStocks.length);
                    if (finishedStocks.length === 0) {
                        allStocksFinishedCallback(stocks.length, failedStocks.length);
                    }
                };
                var downloadData = new DownloadData();
                downloadData.contentType = null;
                downloadData.timeout = timeoutInSeconds * 1000;
                downloadData.url = 'https://www.euroinvestor.com/completion/instrumentvertical2.aspx?q=' + stock.name;
                downloadService.execute(downloadData, quoteFunction);
            };
            var quoteFunction;
            for (var i = 0; i < stocks.length; i++) {
                _loop_1();
            }
        }
        return null;
    };
    EuroinvestorBackend.prototype.convertQuoteResponse = function (responseText, symbol) {
        var lines = responseText.split('\n');
        var result = lines
            .filter(function (line) { return line.length > 0; })
            .filter(function (line) { return line.indexOf('|' + symbol + '|') !== -1; })
            .map(function (line) { return new QuoteResultStockQuote(line); });
        if (result.length > 0) {
            // get first symbol may not be unique (e.g Airbus E:AIR)
            return result[0];
        }
        throw new Error("Unexpected number of results : " + result);
    };
    EuroinvestorBackend.prototype.convertSearchResponseToStockData = function (searchResponse) {
        return new StockData(searchResponse);
    };
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
    function QuoteResultStockQuote(responseLine) {
        var tokens = responseLine.split('|');
        this.price = parseFloat(tokens[6]);
        this.changeAbsolute = parseFloat(tokens[7]);
        this.changeRelative = parseFloat(tokens[8]);
    }
    return QuoteResultStockQuote;
}());
var SearchResultStockData = /** @class */ (function () {
    function SearchResultStockData(responseLine) {
        var stockExchangeMap = {};
        stockExchangeMap["FSE"] = "Frankfurt Stock Exchange";
        stockExchangeMap["LSE"] = "London Stock Exchange";
        stockExchangeMap["LSI"] = "London Stock Exchange";
        stockExchangeMap["MIL"] = "Milano Stock Exchange";
        stockExchangeMap["NAQ"] = "Nasdaq";
        stockExchangeMap["NYS"] = "New York Stock Exchange";
        stockExchangeMap["PAR"] = "Euronext Paris";
        stockExchangeMap["SPS"] = "Madrid Stock Exchange";
        stockExchangeMap["STK"] = "Nasdaq OMX Copenhagen";
        stockExchangeMap["SWI"] = "Swiss Electronic Bourse (EBS)";
        stockExchangeMap["TOR"] = "Toronto Stock Exchange";
        stockExchangeMap["XET"] = "Xetra";
        var tokens = responseLine.split('|');
        this.stockMarketSymbol = tokens[0];
        this.stockMarketName = stockExchangeMap[tokens[0]];
        this.symbol1 = tokens[4];
        this.name = tokens[5];
        this.currency = tokens[10];
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
/// <reference path="EuroinvestorBackend" />
/// <reference path="EuroinvestorFactories" />
// aggregation of all the modules needed for the server!
