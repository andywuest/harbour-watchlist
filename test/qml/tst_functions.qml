import QtQuick 2.0
import QtTest 1.2

import "../../qml/js/functions.js" as Functions
import "../../qml/js/constants.js" as Constants

TestCase {
    name: "Function Tests"

    function test_functions_renderChange() {
        compare(Functions.renderChange(0.0, -2.1, '%'), "-")
        compare(Functions.renderChange(23.23, -2.1, '%'), "-2,10 %")
        compare(Functions.renderChange(23.23, 1.1, '%'), "+1,10 %")
    }

    function test_functions_determineChangeColor() {
        compare(Functions.determineChangeColor(-2.1), Constants.NEGATIVE_COLOR)
        compare(Functions.determineChangeColor(1.1), Constants.POSITIVE_COLOR)
    }

    function test_functions_renderPrice() {
        compare(Functions.renderPrice(0.0, 'EUR'), "")
        // 2 fraction digits
        compare(Functions.renderPrice(65.34123, 'EUR'), "65,34 EUR")
        compare(Functions.renderPrice(1.545234, 'EUR'), "1,55 EUR")
        compare(Functions.renderPrice(12.12, '$'), "12,12 $")
        // 4 fraction digits
        compare(Functions.renderPrice(0.7412, 'EUR'), "0,7412 EUR")
        // 6 fraction digits
        compare(Functions.renderPrice(0.241234, 'EUR'), "0,241234 EUR")
    }

    function test_functions_renderPrice_withMarketData() {
        compare(Functions.renderPrice(0.341234, 'EUR', Constants.MARKET_DATA_TYPE_COMMODITY), "0,341234 EUR")
        compare(Functions.renderPrice(0.441234, 'EUR', Constants.MARKET_DATA_TYPE_CURRENCY), "0,4412 EUR")
        compare(Functions.renderPrice(12.1213, 'EUR', Constants.MARKET_DATA_TYPE_CRYPTO), "12,12 EUR")
        compare(Functions.renderPrice(12.1213, 'EUR', Constants.MARKET_DATA_TYPE_NONE), "12,12 EUR")
        compare(Functions.renderPrice(0.541234, 'EUR', Constants.MARKET_DATA_TYPE_NONE), "0,54 EUR")
    }

    function test_functions_calculateAttributeSumValue() {
        // given
        var stock1 = {};
        stock1.positionValuePurchase = 1234.32;
        stock1.positionValueCurrent = 200.00;
        var stock2 = {};
        stock2.positionValuePurchase = 2453.10;
        stock2.positionValueCurrent = 300.10;
        var stock3 = {};
        stock3.positionValuePurchase = 4000.00;
        stock3.positionValueCurrent = 400.20;
        var stocks = [];
        stocks.push(stock1);
        stocks.push(stock2);
        stocks.push(stock3);

        // when / then
        compare(Functions.calculateAttributeSumValue(stocks, Functions.cbPositionValuePurchase), 7687.42);
        compare(Functions.calculateAttributeSumValue(stocks, Functions.cbPositionValueCurrent), 900.30);
    }

    function test_functions_isNonNullValue() {
        // given / when / then
        compare(Functions.isNonNullValue(null), false);
        compare(Functions.isNonNullValue(0.0), false);
        compare(Functions.isNonNullValue(0.001), true);
        compare(Functions.isNonNullValue(1.001), true);
        compare(Functions.isNonNullValue(1), true);
    }

    function test_functions_calculatePortfolioPerformanceString_withValues() {
        // given
        var stocks = createStockList();

        // when
        var result = Functions.calculatePortfolioPerformanceString(stocks, "EUR");

        // then
        compare(result, "+500,00 EUR  /  +12,50 %");
    }

    function test_functions_calculatePortfolioPerformanceString_empty() {
        // given
        var stocks = [];

        // when
        var result = Functions.calculatePortfolioPerformanceString(stocks, "EUR");

        // then
        compare(result, "");
    }

    function createStockList() {
        var stock1 = {};
        stock1.positionValuePurchase = 1000.00;
        stock1.positionValueCurrent = 1200.00;  // 200 Euro, 20% plus
        var stock2 = {};
        stock2.positionValuePurchase = 2000.00;
        stock2.positionValueCurrent = 3000.00;  // 1000 Euro, 50% plus
        var stock3 = {};
        stock3.positionValuePurchase = 1000.00; // -700 Euro, 70% minus
        stock3.positionValueCurrent = 300.00;
        var stocks = [];
        stocks.push(stock1);
        stocks.push(stock2);
        stocks.push(stock3);
        return stocks;
    }

}
