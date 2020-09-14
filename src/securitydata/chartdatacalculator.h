#ifndef CHARTDATACALCULATOR_H
#define CHARTDATACALCULATOR_H

class ChartDataCalculator
{
public:
     ChartDataCalculator() = default;

    void checkCloseValue(double value);
    double getMinValue();
    double getMaxValue();
    int getFractionDigits();

private:
    double min = -1.0;
    double max = -1.0;

};

#endif // CHARTDATACALCULATOR_H
