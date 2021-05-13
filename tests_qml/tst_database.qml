import QtQuick 2.0
import QtTest 1.2
import QtQuick.LocalStorage 2.0

import "../qml/js/database.js" as Database
import "../qml/js/functions.js" as Functions
import "../qml/js/constants.js" as Constants

TestCase {
    name: "Database Tests"

    function test_someDBTest() {
        Database.resetApplication();
        Database.initApplicationTables();

        var watchlistId = 1;
        var data = {};
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

        Database.persistStockData(data, watchlistId)

        var securityList = Database.loadAllStockData(watchlistId, Database.SORT_BY_NAME_ASC);
        var security = securityList[0];
        console.log("Security : " + security.id);
        console.log("Security : " + security.symbol1);
        console.log("Security : " + security.watchlistId);
        console.log("Security : " + security.isin);
        console.log("Security : " + security.extRefId);
        console.log("Security : " + security.currency);
        console.log("Security : " + security.price);
    }

}
