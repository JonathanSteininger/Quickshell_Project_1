import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Canvas{
    id: canvas
    property bool tiltRight: true;
    property string color: "black";
    property int borderSize: 2;
    property real tiltStrength: 1;
    width: height;


    function drawLine(ctx, borderSize:int, borderColor){
        ctx.strokeStyle = borderColor
        ctx.lineWidth = borderSize;
        if(tiltRight){
            ctx.moveTo(width-borderSize,0);
            ctx.lineTo(borderSize,height);
        }else{
            ctx.moveTo(borderSize,0);
            ctx.lineTo(width-borderSize,height);
        }
        ctx.stroke();
    }

    onPaint: {
        var ctx = getContext("2d");
        drawLine(ctx, borderSize, color);
    }
}
