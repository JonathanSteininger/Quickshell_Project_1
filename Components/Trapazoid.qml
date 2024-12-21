import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Canvas{
    id: canvas
    property bool tiltRight: true;
    property string borderColor: "black";
    property string color: "white";
    property real borderSize: 2;
    property real tiltStrength: 1;
    implicitWidth: children.reduce((output, child) => output + child.width, 0) + (getShift() * 2);
    implicitHeight: parent.height;
    function mytop() {return borderSize;}
    function mybottom() { return height - borderSize; }
    function myleft() {return borderSize;}
    function myright() {return width-borderSize;}
    function getShift() {return height*tiltStrength - borderSize;}
    property var ctx;

    function drawShape(ctx, borderSize:real, color, borderColor){
        ctx.fillStyle = color
        ctx.strokeStyle = borderColor
        ctx.lineWidth = borderSize;
        if(tiltRight){
            ctx.moveTo(getShift(),mytop());
            ctx.lineTo(myleft(),mybottom());
            ctx.lineTo(myright(),mybottom());
            ctx.lineTo(myright()-getShift(),mytop());
            ctx.lineTo(getShift(),mytop());
        }else{
            ctx.moveTo(myleft(),mytop());
            ctx.lineTo(getShift(),mybottom());
            ctx.lineTo(myright()-getShift(),mybottom());
            ctx.lineTo(myright(),mytop());
            ctx.lineTo(myleft(),mytop());
        }
        ctx.fill();
        ctx.stroke();
    }

    onPaint: {
        ctx = getContext("2d");
        drawShape(ctx, borderSize, color, borderColor);
    }

    function calcOffsetRight(item: var): int {
        if(tiltRight){
            return -((height - item.y)*tiltStrength + borderSize);
        }
        return -((height - item.y)*tiltStrength + borderSize);
    }
    function calcOffsetLeft(item: var): int {
        if(tiltRight){
            return (height - item.y)*tiltStrength + borderSize;
        }
        return (item.y + item.height)*tiltStrength  + borderSize;
    }
}
