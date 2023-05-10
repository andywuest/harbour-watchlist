import QtQuick 2.0
import QtTest 1.2
import QtQuick.LocalStorage 2.0

import "../../qml/js/functions.js" as Functions
import "../../qml/js/constants.js" as Constants
import "../../qml/js/database.js" as Database

TestCase {
    name: "Database Tests"

    function init() {
        Database.resetApplication();
        Database.initApplicationTables();
    }

    function test_loadPersistStockData() {
        // given
        var watchlistId = Constants.WATCHLIST_1;
        var data = createRandomSecurity();

        // when
        Database.persistStockData(data, watchlistId);

        // then
        var securityList = Database.loadAllStockData(watchlistId, Database.SORT_BY_NAME_ASC);
        compare(securityList.length, 1);
        var security = securityList[0];
        compare(security.watchlistId, data.watchlistId);
        compare(security.symbol1, data.symbol1);
        compare(security.isin, data.isin);
        compare(security.extRefId, data.extRefId);
        compare(security.currency, data.currency);
        compare(security.price, data.price);
    }

    function test_loadSaveStockNotes() {
        // given
        var securityId = 15;
        Database.persistStockData(createRandomSecurity(securityId), Constants.WATCHLIST_1);

        // when
        Database.saveStockNotes(securityId, 'some info');
        var stockNotes = Database.loadStockNotes(securityId);

        // then
        compare(stockNotes, 'some info');
    }

    function test_loadSavePieces() {
        // given
        var securityId = 26;
        Database.persistStockData(createRandomSecurity(securityId), Constants.WATCHLIST_1);

        // when
        Database.savePieces(securityId, 10);
        var pieces = Database.loadPieces(securityId);

        // then
        compare(pieces, 10);
    }

    function test_loadSaveReferencePrice() {
        // given
        var securityId = 10;
        Database.persistStockData(createRandomSecurity(securityId), Constants.WATCHLIST_1);

        // when
        Database.saveReferencePrice(securityId, 23.3);
        var referencePrice = Database.loadReferencePrice(securityId);

        // then
        compare(referencePrice, 23.3);
    }

    function test_loadPersistMarketData() {
        // given
        var marketData = createRandomMarketData();

        // when
        Database.persistMarketdata(marketData);

        // then
        var resultList = Database.loadAllMarketData(marketData.extRefId);
        compare(resultList.length, 1);
        var result = resultList[0];
        compare(result.name, marketData.name);
        compare(result.id, marketData.id);
        compare(result.symbol, marketData.symbol);
        compare(result.last, marketData.last);
        compare(result.changeAbsolute, marketData.changeAbsolute);
        compare(result.changeRelative, 0.0); // undefined
        compare(result.quoteTimestamp, ""); // undefined
        compare(result.currency, "-"); // undefined
    }

    function createRandomSecurity(id) {
        var data = {};
        if (id) {
            data.id = id;
        }
        data.symbol = 'BASF';
        data.name = 'BASF AG';
        data.watchlistId = 1;
        data.extRefId = 'BA01';
        data.currency = 'EUR';
        data.stockMarketSymbol = 'XTRA';
        data.stockMarketSymbol = 'Xetra';
        data.isin = 'DE234234234';
        data.symbol1 = 'BA1';
        data.symbol2 = 'BA2';
        data.price = 62.30;
        return data;
    }

    function createRandomMarketData() {
        var now = new Date();
        var marketData = {};
        marketData.id = '3';
        marketData.typeId = 3;
        marketData.name = 'DAX 40';
        marketData.longName = 'DAX 40';
        marketData.extRefId = 'XTRDAX';
        marketData.symbol = 'DAX';
        marketData.stockMarketSymbol = 'FRA';
        marketData.stockMarketName = 'Frankfurt';
        marketData.last = 12523.12;
        marketData.changeAbsolute = 120.00;
        marketData.lastChangeTimestamp = now;
        return marketData;
    }

}
