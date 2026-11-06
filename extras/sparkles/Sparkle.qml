import QtQuick

Image {
    id: spark
    property bool isSparkle: true
    property real drift: 0
    property real originX: 0
    property real originY: 0
    property int lifetime: 550
    property real originRotation: Math.random() * 90
    x: originX
    y: originY
    rotation: originRotation
    smooth: true
    ParallelAnimation {
        running: true
        NumberAnimation { target: spark; property: "opacity"; from: 0.95; to: 0; duration: spark.lifetime }
        NumberAnimation { target: spark; property: "scale"; from: 1; to: 0.15; duration: spark.lifetime }
        NumberAnimation { target: spark; property: "y"; from: spark.originY; to: spark.originY + 28; duration: spark.lifetime }
        NumberAnimation { target: spark; property: "x"; from: spark.originX; to: spark.originX + spark.drift; duration: spark.lifetime }
        RotationAnimation { target: spark; property: "rotation"; from: spark.originRotation; to: spark.originRotation + 80; duration: spark.lifetime }
        onFinished: spark.destroy()
    }
}
