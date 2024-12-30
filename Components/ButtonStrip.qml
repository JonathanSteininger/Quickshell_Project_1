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


    //ugly shit for transitions
    property real x1: 0;
    property real y1: 0;

    property real x2: 0;
    property real y2: 0;

    property real x3: 0;
    property real y3: 0;

    property real x4: 0;
    property real y4: 0;

    function drawHover(ctx, color){
        ctx.beginPath();
        ctx.fillStyle = color
        ctx.moveTo(x1,y1);
        ctx.lineTo(x2,y2);
        ctx.lineTo(x3,y3);
        ctx.lineTo(x4,y4);
        ctx.lineTo(x1,y1);
        ctx.fill();
        ctx.closePath();
    }
    component MyBehavior: Behavior {
        property alias prop: anime.property;
        SequentialAnimation{
            PropertyAnimation{
                target: canvas;
                properties: "animationing";
                to: true;
                duration: 0;
            }
            NumberAnimation {
                id: anime;
                target: canvas;
                duration: 200;
                easing.type: Easing.OutExpo;
            }
            PropertyAnimation{
                target: canvas;
                properties: "animationing";
                to: false;
                duration: 200;
            }
    }
    }
    property bool animationing: false;
    FrameAnimation{
        id: thing;
        running: canvas.animationing;
        onTriggered: () => {canvas.requestPaint();
    }
    }
    MyBehavior on x1 { prop: "x1" }
    MyBehavior on y1 { prop: "y1" }
    MyBehavior on x2 { prop: "x2" }
    MyBehavior on y2 { prop: "y2" }
    MyBehavior on x3 { prop: "x3" }
    MyBehavior on y3 { prop: "y3" }
    MyBehavior on x4 { prop: "x4" }
    MyBehavior on y4 { prop: "y4" }

        
        
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
        x3=childrenShapeCache[hoveredChild][1].x;
        y3=childrenShapeCache[hoveredChild][1].y;
        x4=childrenShapeCache[hoveredChild][0].x;
        y4=childrenShapeCache[hoveredChild][0].y;
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
        //hoverShape= childrenShapeCache[index];
        x1=childrenShapeCache[index][0].x;
        y1=childrenShapeCache[index][0].y;
        x2=childrenShapeCache[index][1].x;
        y2=childrenShapeCache[index][1].y;
        x3=childrenShapeCache[index][2].x;
        y3=childrenShapeCache[index][2].y;
        x4=childrenShapeCache[index][3].x;
        y4=childrenShapeCache[index][3].y;
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
        drawHover(ctx, borderColor);
            //drawShape(ctx, hoverShape, borderSize, borderColor, borderColor);
        if (hoveredChild != -1){
            //drawShape(ctx, 
            //drawShape(ctx, childrenShapeCache[hoveredChild], borderSize, borderColor, borderColor);
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

            var box = getChildBounds(i);
            childrenShapeCache.push(box);
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
    ): list<point>{
        var _shift = height/2 * tiltStrength;
        if (_tiltRight){
            _shift *= -1;
        }

        var points = [
            Qt.point(0,0),
            Qt.point(0,0),
            Qt.point(0,0),
            Qt.point(0,0)
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
