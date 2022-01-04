import QtQuick 2.0
import QtTest 1.2

import "../qml/js/functions.js" as Functions
import "../qml/js/constants.js" as Constants

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
        // 6 fraction digits
        compare(Functions.renderPrice(0.541234, 'EUR'), "0,541234 EUR")
    }

}
