interface ISearchResult {
    _index: string;
    _type: string;
    _id: string;
    _score?: any;
    _source: ISearchResultSource;
    sort: number[];
}

interface ISearchResultSource {
    id: number;
    name: string;
    symbol: string;
    isin: string;
    volume: number;
}

interface IExchange {
    id: number;
    name: string;
    description: string;
    opensAt: string;
    closesAt: string;
    timezoneName: string;
    timezoneType: string;
    isRealtime: boolean;
}

interface IStockEuroinvestor {
    id: number;
    name: string;
    longName: string;
    symbol: string;
    currency: string;
    ask: number;
    bid: number;
    high: number;
    low: number;
    volume: number;
    open: number;
    previousClose: number;
    isin: string;
    numberOfStocks: number;
    instrumentType: number;
    marketCap: number;
    change: number;
    changeInPercentage: number;
    last: number;
    updatedAt: Date;
    crypto?: any;
    exchange: IExchange;
}


