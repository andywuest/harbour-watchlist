
// chrome starten mit zum testen
// chromium-browser --disable-web-security --user-data-dir=junk/chromedata

let backend: IStockDataBackend = new EuroinvestorBackend();

let key: string = "amadeus fire";


var quoteFunction = function (stockQuote : IStockQuote, stock : IStock) {

    console.log(` =====> quote is : ${stockQuote.price} - ${stockQuote.changeAbsolute} - ${stockQuote.changeRelative} `);

}

var allStocksFinished = function (count: number, failed:number) {
    console.log(` ==== >all finished ${count} - ${failed}`);
}

var searchData = function (returnCode: number, responseText: XMLHttpRequest) {

    console.log("[search] return code was : " + returnCode);
    console.log("[search] full response : " + responseText.responseText);
    if (returnCode === 0) {
        let result: Array<IStockData> = backend.convertSearchResponse(responseText.responseText);

        result.forEach(result => console.log(`name : ${result.name} - ${result.currency} - ${result.symbol1} - ${result.stockMarketSymbol} - ${result.stockMarketName} `));


//         let sampleWatchlist = result.filter(stockData => stockData.symbol1 === 'E:FSFT');

        let sampleWatchlist: Array<IStock> = [backend.convertSearchResponseToStockData(result[0])];

        backend.updateQuotes(sampleWatchlist, quoteFunction, allStocksFinished, 10)


    }

}

console.log("starting async");

backend.search(key, searchData);

console.log("done");



