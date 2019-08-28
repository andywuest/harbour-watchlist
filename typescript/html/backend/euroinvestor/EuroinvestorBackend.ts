
class EuroinvestorBackend implements IStockDataBackend {

    search(key: string, callback: (returnCode: number, httpRequest: XMLHttpRequest) => void): void {
        let downloadService = new DownloadService();
        let downloadData = new DownloadData();
        downloadData.contentType = null;
        downloadData.url = 'https://www.euroinvestor.com/completion/instrumentvertical2.aspx?q=' + key;

        downloadService.execute(downloadData, callback);
    }

    convertSearchResponse(responseText: string): Array<IStockData> {
        let lines: string[] = responseText.split('\n');
        let result: Array<IStockData> = lines.filter(line => line.length > 0).map(line => new SearchResultStockData(line));
        return result;
    }

    store(stockData: IStockData): void {
        throw new Error("Method not implemented.");
    }

    updateQuotes(stocks: Array<IStock>, stockFinisheCallback: (param1: IStockQuote, param2: IStock) => void,
        allStocksFinishedCallback: (count:number, failed:number) => void, timeoutInSeconds: number): Array<IStock> {
        if (stocks !== null && stocks.length > 0) {
            let downloadService = new DownloadService();

            // copy array and use it to track the finished stocks (sync object)
            var finishedStocks = stocks.slice(0);
            // create array with the stocks for which the update failed
            var failedStocks = new Array<IStock>();

            for (var i = 0; i < stocks.length; i++) {
                let stock: IStock = stocks[i];
                console.log(`Looking up quote for ${stock.name}`);

                var quoteFunction = function (returnCode: number, responseText: XMLHttpRequest) {
                    if (returnCode === 0) {
                        let result: IStockQuote = new EuroinvestorBackend().convertQuoteResponse(responseText.responseText, stock.symbol1);
                        stockFinisheCallback(result, stock);
                    }
                    let currentStock = finishedStocks.pop();
                    if (returnCode === 2) {
                        failedStocks.push(currentStock);
                    }
                    console.log("still running : " + finishedStocks.length);
                    if (finishedStocks.length === 0) {
                        allStocksFinishedCallback(stocks.length, failedStocks.length);
                    }
                }

                let downloadData = new DownloadData();
                downloadData.contentType = null;
                downloadData.timeout = timeoutInSeconds * 1000;
                downloadData.url = 'https://www.euroinvestor.com/completion/instrumentvertical2.aspx?q=' + stock.name;
                downloadService.execute(downloadData, quoteFunction);
            }
        }
        return null;
    }

    convertQuoteResponse(responseText: string, symbol: string): IStockQuote {
        let lines: string[] = responseText.split('\n');
        let result: Array<IStockQuote> = lines
            .filter(line => line.length > 0)
            .filter(line => line.indexOf('|' + symbol + '|') !== -1)
            .map(line => new QuoteResultStockQuote(line));
        if (result.length > 0) {
            // get first symbol may not be unique (e.g Airbus E:AIR)
            return result[0];
        }
        throw new Error("Unexpected number of results : " + result);
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

    constructor(responseLine: string) {
        let tokens: string[] = responseLine.split('|');
        this.price = parseFloat(tokens[6]);
        this.changeAbsolute = parseFloat(tokens[7]);
        this.changeRelative = parseFloat(tokens[8]);
    }

    id: number;
    price: number;
    changeAbsolute: number;
    changeRelative: number;
    quoteTimestamp: Date;
    lastChangeTimestamp: Date;
}

class SearchResultStockData implements IStockData {

    constructor(responseLine: string) {
        var stockExchangeMap: {[key: string]: string;} = {};

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

        let tokens: string[] = responseLine.split('|');
        this.stockMarketSymbol = tokens[0];
        this.stockMarketName = stockExchangeMap[tokens[0]];
        this.symbol1 = tokens[4];
        this.name = tokens[5];
        this.currency = tokens[10];

    }

    id: number;
    name: string;
    currency: string;
    stockMarketSymbol: string;
    stockMarketName: string;
    isin: string;
    symbol1: string;
    symbol2: string;

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
    price: number;
    changeAbsolute: number;
    changeRelative: number;
    quoteTimestamp: Date;
    lastChangeTimestamp: Date;

}
