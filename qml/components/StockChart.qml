import QtQuick 2.0
import "."

import "thirdparty"

GraphData {
    //property QtObject dataSource: sysmon
    //property var dataType: []
    //property int dataDepth: settings.deepView
//    property bool dataAvg: false

//    onDataDepthChanged: {
//        if (dataSource) {
//            updateGraph();
//        }
//    }

    //TODO: really such a thing?
//    onDataAvgChanged: {
//        valueTotal = !dataAvg;
//    }

    function updateGraph() {
        var dataPoints = dataSource.getSystemGraph(dataType, dataDepth, graphWidth, dataAvg);
        setPoints(dataPoints);
    }
}
