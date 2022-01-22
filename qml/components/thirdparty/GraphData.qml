import QtQuick 2.0
import QtQml 2.1
import Sailfish.Silica 1.0

import "."

Item {
    id: root
    anchors {
        left: (parent)? parent.left : undefined
        right: (parent)? parent.right : undefined
    }
    height: graphHeight + (doubleAxisXLables ? Theme.itemSizeMedium : Theme.itemSizeSmall)

    signal clicked

    property alias clickEnabled: backgroundArea.enabled
    property string graphTitle: ""
    property string graphBodyText: qsTr("No data - Click to fetch data")
    property bool showTrendTriangle: false

    property alias axisX: _axisXobject
    Axis {
        id: _axisXobject
        mask: "hh:mm"
        grid: 4
    }

    property alias axisY: _axisYobject
    Axis {
        id: _axisYobject
        mask: "%1"
        units: " " + axisYUnit
        grid: 4
    }

    property var valueConverter
    property var dateFormatter // formatter for x-axis labels
    property var infoLines: ({})

    property bool valueTotal: false

    property int graphHeight: 250
    property int graphWidth: canvas.width / canvas.stepX
    property bool doubleAxisXLables: false
    property bool intraday: false

    property bool scale: false
    property color lineColor: Theme.highlightColor
    property int lineWidth: 3

    property real minY: 0 //Always 0
    property real maxY: 0

    property int minX: 0
    property int maxX: 0

    property string axisYUnit: ""

    property var points: []
    onPointsChanged: {
        noData = (points.length == 0);
    }
    property bool noData: true

    function setPoints(data) {
        if (!data) return;

        var pointMaxY = 0;
        if (data.length > 0) {
            minX = data[0].x;
            maxX = data[data.length-1].x;
        }
        data.forEach(function(point) {
            if (point.y > pointMaxY) {
                pointMaxY = point.y
            }
        });
        points = data;
        if (scale) {
            maxY = pointMaxY * 1.20;
        }
        // TODO hier wird die achsenzahl gesteuert
        intraday = ((maxX - minX) <= 86400); // 1 day - only show time

        doubleAxisXLables = ((maxX - minX) < 86400); // 1 day

        canvas.requestPaint();
    }

    function createYLabel(value) {
        var v = value;
        if (valueConverter) {
            v = valueConverter(value, false);
        }
        return axisY.mask.arg(v);
    }

    // for the last y-label value we want always to fractions to be displayed
    function createLastYLabel(value) {
        var v = value;
        if (valueConverter) {
            v = valueConverter(value, true);
        }
        return axisY.mask.arg(v);
    }

    function createXLabel(value) {
        var date = new Date(value * 1000);
        if (dateFormatter) {
            return dateFormatter(date);
        }
        return "---"
    }

    Column {
        anchors {
            top: parent.top
            left: parent.left
            leftMargin: 3*Theme.paddingLarge
            right: parent.right
            rightMargin: Theme.paddingLarge
        }

        Label {
            width: parent.width
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeSmall
            text: graphTitle
            wrapMode: Text.Wrap

            Label {
                id: labelLastValue
                anchors {
                    right: parent.right
                }
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap
                visible: !noData
            }
        }

        Rectangle {
            width: parent.width
            height: graphHeight
            border.color: Theme.secondaryHighlightColor
            color: "transparent"

            BackgroundItem {
                id: backgroundArea
                anchors.fill: parent
                onClicked: {
                    root.clicked();
                }
            }

            Repeater {
                model: noData ? 0 : (axisY.grid + 1)
                delegate: Label {
                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeLarge / 2
                    text: createYLabel( (maxY-minY)/axisY.grid * index + minY)
                    anchors {
                        top: (index == axisY.grid) ? parent.top : undefined
                        bottom: (index == axisY.grid) ? undefined : parent.bottom
                        bottomMargin: (index) ? parent.height / axisY.grid * index - height/2 : 0
                        right: parent.left
                        rightMargin: Theme.paddingSmall
                    }
                }
            }

            Repeater {
                model: noData ? 0 : (axisX.grid + 1)
                delegate: Label {
                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeLarge / 2
                    text: createXLabel( (maxX-minX)/axisX.grid * index + minX )
                        // intraday ? createXLabel( (maxX-minX)/axisX.grid * index + minX ) : Qt.formatDate(new Date( ((maxX-minX)/axisX.grid * index + minX) * 1000), "dd.MM");
                    anchors {
                        top: parent.bottom
                        topMargin: Theme.paddingSmall
                        left: (index == axisX.grid) ? undefined : parent.left
                        right: (index == axisX.grid) ? parent.right : undefined
                        leftMargin: (index) ? (parent.width / axisX.grid * index - width/2): 0
                    }
//                    Label {
//                        color: Theme.primaryColor
//                        font.pixelSize: Theme.fontSizeLarge / 2
//                        anchors {
//                            top: parent.bottom
//                            horizontalCenter: parent.horizontalCenter
//                        }
//                        text: Qt.formatDate(new Date( ((maxX-minX)/axisX.grid * index + minX) * 1000), "dd.MM");
//                        visible: !intraday
//                    }
                }
            }

            Label {
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeLarge / 2
                text: axisY.units
                anchors {
                    top: parent.top
                    left: parent.left
                    leftMargin: Theme.paddingSmall
                }
                visible: !noData
            }

            Canvas {
                id: canvas
                anchors {
                    fill: parent
                    //leftMargin: Theme.paddingSmall
                    //rightMargin: Theme.paddingSmall
                }

                //renderTarget: Canvas.FramebufferObject
                //renderStrategy: Canvas.Threaded

                property real stepX: (parent.width / (points.length- 2)) // - lineWidth
                property real stepY: (maxY-minY)/(height-2)

                function drawTrendTriangle(ctx, startValue, endValue) {
                    var yStart = (height - Math.floor((startValue - minY) / stepY) - 1);
                    var yEnd = (height - Math.floor((endValue - minY) / stepY) - 1);

                    console.log("drawTrendTriangle  yStart:" + yStart
                                + ", yEnd : " + yEnd);

                    ctx.save();
                    ctx.lineWidth = 1;
                    ctx.globalAlpha = 0.45;

                    // the triangle
                    ctx.beginPath();
                    ctx.moveTo(0, yStart);
                    ctx.lineTo(width, yStart);
                    ctx.lineTo(width, yEnd);
                    ctx.closePath();

                    // the fill color
                    context.fillStyle = yStart > yEnd ? "#009900" : "#ff3300";
                    context.fill();

                    ctx.restore();
                }

                function drawInfoLine(ctx, infoLine) {
                    if (infoLine.value < minY && infoLine.value > maxY) {
                        console.log("Reference price not within chart data for chart " + chartType
                                    + " - skipping it!");
                        return;
                    }

                    var y = (height - Math.floor((infoLine.value - minY) / stepY) - 1);
                    console.log("drawPriceLine  y:" + y + ", minY : " + minY + ", maxY : " + maxY);

                    ctx.save();
                    ctx.lineWidth = 1;
                    ctx.strokeStyle = infoLine.color;
                    ctx.globalAlpha = 0.6;

                    ctx.beginPath();
                    ctx.moveTo(0, y);
                    ctx.lineTo(width, y);
                    ctx.stroke();

                    ctx.restore();
                }

                function drawGrid(ctx) {
                    ctx.save();

                    ctx.lineWidth = 1;
                    ctx.strokeStyle = lineColor;
                    ctx.globalAlpha = 0.4;
                    //i=0 and i=axisY.grid skipped, top/bottom line
                    for (var i=1;i<axisY.grid;i++) {
                        ctx.beginPath();
                        ctx.moveTo(0, height/axisY.grid * i);
                        ctx.lineTo(width, height/axisY.grid * i);
                        ctx.stroke();
                    }

                    ctx.restore();
                }

                //TODO: allow multiple lines to be drawn
                function drawPoints(ctx, points) {
                }

                onPaint: {
                    var ctx = canvas.getContext("2d");
                    ctx.globalCompositeOperation = "source-over";
                    ctx.clearRect(0,0,width,height);

                    // console.log("width: " + parent.width)
                    // console.log("maxY", maxY, "minY", minY, "height", height, "StepY", stepY);

                    var end = points.length;

                    if (end > 0) {
                        drawGrid(ctx);
                    }

                    console.log("info lines : " + infoLines);
                    drawInfoLine(ctx, infoLines.referencePrice);
                    // for now only draw lines for reference price
                    // drawInfoLine(ctx, infoLines.alarmMinimumPrice);
                    // drawInfoLine(ctx, infoLines.alarmMaximumPrice);

                    if (showTrendTriangle) {
                        drawTrendTriangle(ctx, points[0].y, points[end -1].y);
                    }

                    ctx.save()
                    ctx.strokeStyle = lineColor;
                    //ctx.globalAlpha = 0.8;
                    ctx.lineWidth = lineWidth;
                    ctx.beginPath();
                    var x = -stepX;
                    var valueSum = 0;
                    for (var i = 0; i < end; i++) {
                        valueSum += points[i].y;
                        var y = (height - Math.floor((points[i].y - minY) / stepY) - 1) // + (minY * stepY);
//                        console.log(" x : " + x + ", y : " + y);
                        if (i === 0) {
                            ctx.moveTo(x, y);
                        } else {
                            ctx.lineTo(x, y);
                        }
                        x+=stepX; //point[i].x can be used for grid title
                    }
                    ctx.stroke();
                    ctx.restore();

                    if (end > 0) {
                        var lastValue = valueSum;
                        if (!root.valueTotal) {
                            lastValue = points[end-1].y;
                        }
                        if (lastValue) {
                            labelLastValue.text = root.createLastYLabel(lastValue)+root.axisY.units;
                        }
                    }
                }
            }

            Text {
                id: textNoData
                anchors.centerIn: parent
                color: lineColor
                horizontalAlignment: Text.AlignHCenter
                text: graphBodyText
                visible: noData
            }
        }
    }
}
