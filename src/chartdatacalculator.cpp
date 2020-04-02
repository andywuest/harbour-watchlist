#include "chartdatacalculator.h"
#include "math.h"

ChartDataCalculator::ChartDataCalculator() {
}

void ChartDataCalculator::checkCloseValue(double value) {
    if (min == -1) {
        min = value;
    } else if (value < min) {
        min = value;
    }
    if (max == -1) {
        max = value;
    } else if (value > max) {
        max = value;
    }
}

double ChartDataCalculator::getMinValue() {
    // top / bottom margin for chart - if the difference is too small - rounding makes no sense.
    double roundedMin = (max - min > 1.0) ? floor(min) : min;
    return roundedMin;
}

double ChartDataCalculator::getMaxValue() {
    // top / bottom margin for chart - if the difference is too small - rounding makes no sense.
    double roundedMax = (max - min > 1.0) ? ceil(max) : max;
    return roundedMax;
}

int ChartDataCalculator::getFractionDigits() {
    // determine how many fraction digits the y-axis is supposed to display
    int fractionsDigits = 1;
    if (max - min > 10.0) {
        fractionsDigits = 0;
    } else if (max - min < 2) {
        fractionsDigits = 2;
    }
    return fractionsDigits;
}
