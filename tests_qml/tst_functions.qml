import QtQuick 2.0
import QtTest 1.2

import "../qml/js/functions.js" as Functions
import "../qml/js/constants.js" as Constants

TestCase {
    name: "Function Tests"

    function test_functions_renderChange() {
        compare("-", Functions.renderChange(0.0, -2.1, '%'))
        compare("-2,10 %", Functions.renderChange(23.23, -2.1, '%'))
        compare("+1,10 %", Functions.renderChange(23.23, 1.1, '%'))
    }

    function test_functions_determineChangeColor() {
        compare(Constants.NEGATIVE_COLOR, Functions.determineChangeColor(-2.1))
        compare(Constants.POSITIVE_COLOR, Functions.determineChangeColor(1.1))
    }

}
