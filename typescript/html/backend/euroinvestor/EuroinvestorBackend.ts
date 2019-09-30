
class EuroinvestorBackend implements IStockDataBackend {

    search(key: string, callback: (returnCode: number, httpRequest: XMLHttpRequest) => void): void {
        let downloadService = new DownloadService();
        let downloadData = new DownloadData();
        downloadData.url = this.getSearchUrl(key);
        downloadService.execute(downloadData, callback);
    }

    convertSearchResponse(responseText: string): Array<IStockData> {
        const response: (Array<ISearchResult>) = JSON.parse(responseText);
        return response.map(item => new SearchResultStockData(item));
    }

    store(stockData: IStockData): void {
        throw new Error("Method not implemented.");
    }

    private getSearchUrl(searchKey: string): string {
        return `https://search.euroinvestor.dk/instruments?q=${searchKey}`;
    }

    private getQuoteUrl(quoteKey: string): string {
        return `https://api.euroinvestor.dk/instruments?ids=${quoteKey}`;
    }

    // TODO wird der return wert ueberhaupt benoetigt?
    updateQuotes(stocks: Array<IStock>, stockFinishedCallback: (param1: IStockQuote, param2: IStock) => void,
        allStocksFinishedCallback: (count: number, failed: number) => void, timeoutInSeconds: number): Array<IStock> {

        const downloadService = new DownloadService();
        const quoteKeys: string = stocks.map(stock => stock.extRefId).join(",");

        console.log("query keys : " + quoteKeys);

        var quoteFunction = function (returnCode: number, responseText: XMLHttpRequest) {
            if (returnCode === 0) {
                const response: (Array<IStockEuroinvestor>) = JSON.parse(responseText.responseText);

                const results: Array<QuoteResultStockQuote> = response.map(item => new QuoteResultStockQuote(item));

                // TODO simplify                
                results.forEach(resultQuote => stocks.forEach(stock => {
                    if ("" + resultQuote.extRefId === stock.extRefId) {
                        stockFinishedCallback(resultQuote, stock);
                    }
                }));

                const numberOfFailedStocks: number = stocks.length - response.length;
                allStocksFinishedCallback(stocks.length, numberOfFailedStocks);
            } else if (returnCode === 2) {
                allStocksFinishedCallback(stocks.length, stocks.length);
            }
        }

        const downloadData = new DownloadData();
        downloadData.contentType = null;
        downloadData.timeout = timeoutInSeconds * 1000;
        downloadData.url = this.getQuoteUrl(quoteKeys);
        downloadService.execute(downloadData, quoteFunction);
        return null;
    }

    // TIDI wird das ueberhaupt benoetigt?
    convertQuoteResponse(responseText: string, symbol: string): IStockQuote {
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
    }

    convertSearchResponseToStockData(searchResponse: SearchResultStockData): StockData {
        return new StockData(searchResponse);
    }

    // TODO move -> independent of backend
    getMaxChange(stocks: Array<IStock>): number {
        // https://stackoverflow.com/questions/4020796/finding-the-max-value-of-an-attribute-in-an-array-of-objects
        // added handling for negative ones
        return Math.max.apply(Math, stocks.map(function (o) {return Math.abs(o.changeRelative)}));
    }

    sortByChangeAsc(stocks: Array<IStock>): Array<IStock> {
        return stocks.sort((a, b) => (a.changeRelative > b.changeRelative) ? 1 : ((b.changeRelative > a.changeRelative) ? -1 : 0));
    }

    sortByChangeDesc(stocks: Array<IStock>): Array<IStock> {
        return stocks.sort((a, b) => (a.changeRelative > b.changeRelative) ? -1 : ((b.changeRelative > a.changeRelative) ? 1 : 0));
    }

}

class QuoteResultStockQuote implements IStockQuote {

    constructor(response: IStockEuroinvestor) {
        this.price = response.last;
        this.changeAbsolute = response.change;
        this.changeRelative = response.changeInPercentage;
        this.quoteTimestamp = response.updatedAt;
        this.extRefId = "" + response.id;
        this.lastChangeTimestamp = new Date();
    }

    id: number;
    extRefId: string;
    price: number;
    changeAbsolute: number;
    changeRelative: number;
    quoteTimestamp: Date;
    lastChangeTimestamp: Date;
}

class SearchResultStockData implements IStockData {

    constructor(responseItem: ISearchResult) {
        this.name = responseItem._source.name;
        this.isin = responseItem._source.isin;
        this.symbol1 = responseItem._source.symbol;
        this.extRefId = "" + responseItem._source.id
    }

    id: number;
    name: string;
    currency: string;
    stockMarketSymbol: string;
    stockMarketName: string;
    isin: string;
    symbol1: string;
    symbol2: string;
    extRefId: string

}

class StockData implements IStockData {

    constructor(searchStockData: SearchResultStockData) {
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

    id: number;
    name: string;
    currency: string;
    stockMarketSymbol: string;
    stockMarketName: string;
    isin: string;
    symbol1: string
    symbol2: string
    extRefId: string
    price: number;
    changeAbsolute: number;
    changeRelative: number;
    quoteTimestamp: Date;
    lastChangeTimestamp: Date;

}


