import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQml

Canvas{
    id: canvas
    property bool tiltRight: true;
    property string borderColor: "black";
    property string color: "white";
    property real borderSize: 2;
    property real tiltStrength: 1;

    property real horizontalPadding: 15;
    property real spacing: horizontalPadding*2;


    implicitWidth: children.reduce((output, child) => output + child.width, 0) + (getShift() * 2);
    implicitHeight: parent.height;


    function mytop() {return borderSize;}
    function mybottom() { return height - borderSize; }
    function myleft() {return borderSize;}
    function myright() {return width-borderSize;}
    function getShift() {return height*tiltStrength - borderSize;}

    property list<var> extraShapes: [];
    property list<var> childrenShapeCache: []; 
    property var hoveredChild: -1;

    function drawShape(ctx, shape, borderSize:real, color, borderColor){
        ctx.beginPath();
        if(shape.length <= 0){
            return;
        }
        ctx.fillStyle = color
        ctx.strokeStyle = borderColor
        ctx.lineWidth = borderSize;
        ctx.moveTo(shape[0].x, shape[0].y);
        for(var i = 0; i < shape.length; i++){
            ctx.lineTo(shape[i].x, shape[i].y);
        }
        ctx.lineTo(shape[0].x, shape[0].y);
        ctx.fill();
        ctx.stroke();
        ctx.closePath();
    }


    MouseArea{
        anchors.fill: parent;
        hoverEnabled: true;
        onReleased: {
            parent.clickButton(mouseX, mouseY);
        }
        onPositionChanged: {
            parent.checkChildrenHover(mouseX, mouseY);
        }
        onExited: {
            parent.clearHover();
            parent.requestPaint();
        }
    }
    function clearHover(){
        hoveredChild = -1;
    }
    function setHoverIndex(index): bool{
        if(index < 0 || index >= children.length){
            return false;
        }
        if (index == hoveredChild){
            return false;
        }
        hoveredChild = index;
        requestPaint();
        return true;
    }

    function clickButton(_x, _y){
        var index = checkPosInBounds(_x, _y);
        if (index == -1){
            return;
        }
        children[index].clicked();
    }

    function checkPosInBounds(_x, _y): int{
        //calculates the current offset from the mouse relative to the tilt.
        //can use this value with simple position info to get hovered element.
        //We only have to compute once then.
        var riseRun = tiltStrength;
        if (!tiltRight){
            riseRun *= -1;
        }
        var hitboxOffset = _y * riseRun;
        var tiltOffset = height*tiltStrength/2;
        _x += hitboxOffset;
        if (tiltRight){
            tiltOffset *= -1;
        }
        for (var i = 1; i < children.length; i++){
            if(children[i].onClicked == undefined){
                continue;
            }
            var shift = spacing/2;
            if(i == 1 || i == children.length -1){
                shift = horizontalPadding;
            }
            var _left = children[i].x - shift - tiltOffset;
            var _right = children[i].x + children[i].width + shift - tiltOffset;
            if (_left < _x && _x < _right ){
                return i;
            }
        }

        return -1;
    }

    function checkChildrenHover(_x, _y): void{
        var index = checkPosInBounds(_x, _y);
        if (index == -1){
            clearHover();
            requestPaint();
            return;
        }

        setHoverIndex(index-1);
    }

    onPaint: {
        var ctx = getContext("2d");
        ctx.reset();
        drawShape(ctx, createShape(), borderSize, color, borderColor);
        if (hoveredChild != -1){
            drawShape(ctx, childrenShapeCache[hoveredChild], borderSize, borderColor, borderColor);
        }
        for (var i = 0; i < extraShapes.length;i++){
            drawShape(ctx, extraShapes[i], borderSize, borderColor, borderColor);
        }
        for (var i = 2; i < children.length;i++){
            drawLine(ctx, children[i].x - spacing/2, borderSize, borderColor);
        }
    }

    function drawLine(ctx, xpos,  borderSize:real, borderColor){
        ctx.beginPath();
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
        ctx.closePath();
    }
    
    function getChildBounds(childIndex: int): list<var>{
        var shift = spacing/2;
        if(childIndex == 1 || childIndex == children.length -1){
            shift = horizontalPadding;
        }
        var _left = children[childIndex].x - shift;
        var _span = children[childIndex].width + shift * 2;

        return createShape(_left, 0, _span);
    }
    function calcTotalWidth(): real {
        var _width = 0;
        _width += height;
        _width += horizontalPadding * 2;
        for (var i = 1; i < children.length;i++){
            _width += children[i].width;
        }
        if( children.length > 0){
            _width += (children.length - 2) * spacing;
        }
        return _width;
    }
    function _update(): void{
        var totalOffset = getShift()/2 + horizontalPadding;
        childrenShapeCache = [];
        for (var i = 1; i < children.length;i++){
            //position child
            children[i].x = totalOffset;

            //calculate next childs offset
            children[i].anchors.verticalCenter = verticalCenter;
            totalOffset+=children[i].width;
            totalOffset+=spacing;

            childrenShapeCache.push(getChildBounds(i));
        }
        width = calcTotalWidth();
        requestPaint();
    }
    function createShape(
        _x = this.height/2,
        _y = 0,
        _width = this.width-this.height,
        _height = this.height,
        _margin = this.borderSize,
        _tiltRight = this.tiltRight,
        _tiltStrength = this.tiltStrength
    ){

        var _shift = height/2 * tiltStrength;
        if (_tiltRight){
            _shift *= -1;
        }

        var points = [
            {x:0,y:0},
            {x:0,y:0},
            {x:0,y:0},
            {x:0,y:0}
            ];

        points[0].x = _x - _shift + _margin;
        points[1].x = _x + _width - _shift - _margin;
        points[2].x = _x + _width + _shift - _margin;
        points[3].x = _x + _shift + _margin;

        points[0].y = _y + _margin;
        points[1].y = _y + _margin;
        points[2].y = _y + _height - _margin;
        points[3].y = _y + _height - _margin;

        return points;
    }
    Component.onCompleted: {
        _update();
    }
    onChildrenRectChanged: {
        _update();
    }
    onChildrenChanged: {
        _update();
    }
}
