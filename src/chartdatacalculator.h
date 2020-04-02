#ifndef CHARTDATACALCULATOR_H
#define CHARTDATACALCULATOR_H

class ChartDataCalculator
{
public:
    ChartDataCalculator();

    void checkCloseValue(double value);
    double getMinValue();
    double getMaxValue();
    int getFractionDigits();

private:
    double min = -1;
    double max = -1;

};

#endif // CHARTDATACALCULATOR_H
