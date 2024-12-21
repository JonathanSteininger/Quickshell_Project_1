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
    property var childrenParents: [];
    property var childrenParentsOffset: [];
    implicitWidth: children.reduce((output, child) => output + child.width, 0) + (getShift() * 2);
    implicitHeight: parent.height;
    function mytop() {return borderSize;}
    function mybottom() { return height - borderSize; }
    function myleft() {return borderSize;}
    function myright() {return width-borderSize;}
    function getShift() {return height*tiltStrength - borderSize;}

    function drawTrapazoid(ctx, borderSize:real, color, borderColor){
        ctx.fillStyle = color
        ctx.strokeStyle = borderColor
        ctx.lineWidth = borderSize;
        if(tiltRight){
            ctx.moveTo(getShift(),mytop());
            ctx.lineTo(myleft(),mybottom());
            ctx.lineTo(myright()-getShift(),mybottom());
            ctx.lineTo(myright(),mytop());
            ctx.lineTo(getShift(),mytop());
        }else{
            ctx.moveTo(myleft(),mytop());
            ctx.lineTo(getShift(),mybottom());
            ctx.lineTo(myright(),mybottom());
            ctx.lineTo(myright()-getShift(),mytop());
            ctx.lineTo(myleft(),mytop());
        }
        ctx.fill();
        ctx.stroke();
    }

    onPaint: {
        var ctx = getContext("2d");
        drawTrapazoid(ctx, borderSize, color, borderColor);
        if(this.childrenParents.length > 0){
            drawChildrenSeperators(ctx);
        }
    }
    function drawChildrenSeperators(ctx){
        for(var i = 0; i < childrenParents.length; i++){
            drawSeperators(ctx, childrenParentsOffset[i], childrenParents[i].children);
        }
    }
    function drawSeperators(ctx, offset, children){
        for (var i = 1; i < children.length; i++){
            drawLine(ctx, offset + children[i].x, borderSize, borderColor);
        }
    }

    function addSeperatorParent(parent, offset: int){
        childrenParents.push(parent);
        childrenParentsOffset.push(offset);
    }

    function drawLine(ctx, xpos,  borderSize:real, borderColor){
        ctx.strokeStyle = borderColor
        ctx.lineWidth = Math.ceil(borderSize);
        if(tiltRight){
            ctx.moveTo(xpos+(getShift()/2)+borderSize,borderSize);
            ctx.lineTo(xpos-(getShift()/2)-borderSize,height - borderSize);
        }else{
            ctx.moveTo(xpos-(getShift()/2)-borderSize,borderSize);
            ctx.lineTo(xpos+(getShift()/2)+borderSize,height - borderSize);
        }
        ctx.stroke();
    }
    
    function calcOffsetRight(item: var): int {
        if(tiltRight){
            return (item.y + item.height)*tiltStrength  + borderSize;
        }
        return (height - item.y)*tiltStrength + borderSize;
    }
    function calcOffsetLeft(item: var): int {
        if(tiltRight){
            return (height - item.y)*tiltStrength + borderSize;
        }
        return (item.y + item.height)*tiltStrength  + borderSize;
    }
}
