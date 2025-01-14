import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQml
import QtQuick.Shapes;

pragma ComponentBehavior: Bound;

Shape{
    id: root;
    property alias innerChildren: childContainer.children;
    property bool tiltRight: true;
    property string borderColor: "black";
    property string color: "white";
    property real borderSize: 2;
    property real tiltStrength: 1;

    property real horizontalPadding: 15;
    property real spacing: horizontalPadding*2;

    width: childContainer.width + horizontalPadding*2 + height;
    height: parent.height;

    clip: false;

    readonly property real shift: height * tiltStrength;
    readonly property real shift1: tiltRight ? shift : 0;
    readonly property real shift2: tiltRight ? 0 : shift;


    ShapePath{
        strokeWidth: root.borderSize;
        strokeColor: root.borderColor;
        fillColor: root.color;
        startY: 0;
        startX: root.shift1;
        PathLine{
            y: 0;
            x: root.width - root.shift2;
        }
        PathLine{
            y: root.height;
            x: root.width - root.shift1;
        }
        PathLine{
            y: root.height;
            x: root.shift2;
        }
        PathLine{
            y: 0;
            x: root.shift1;
        }
    }
    Shape{
        id: hoverShape
        property int childIndex: 0;
        property real childWidth: root.innerChildren[childIndex].width;
        property real childOffset: root.innerChildren[childIndex].x;
        //width: childWidth + root.spacing;
        readonly property real shift: height * root.tiltStrength;
        readonly property real shift1: root.tiltRight ? shift : 0;
        readonly property real shift2: root.tiltRight ? 0 : shift;
        width: childWidth + height + root.spacing;
        Behavior on x{
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutExpo;
            }
        }
        Behavior on width{
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutExpo;
            }
        }
        onWidthChanged:{
            console.log(width);

        }
        x: childOffset;
        y: 0;
        implicitHeight: root.height;

        ShapePath{
            strokeWidth: 0;
            fillColor: root.borderColor;
            startY: 0;
            startX: root.shift1;
            PathLine{
                y: 0;
                x: hoverShape.width - hoverShape.shift2;
            }
            PathLine{
                y: hoverShape.height;
                x: hoverShape.width - hoverShape.shift1;
            }
            PathLine{
                y: hoverShape.height;
                x: hoverShape.shift2;
            }
            PathLine{
                y: 0;
                x: hoverShape.shift1;
            }
        }
    }

    RowLayout{
        id: childContainer;
        height: parent.height;
        spacing: root.spacing;
        x: root.height/2 + root.horizontalPadding;
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
        }
    }
    function setHoverdChild(){
    }
    function clearHover(){
        x3=x2;
        y3=y2;
        x4=x1;
        y4=y1;
    }
    function setHoverIndex(index): bool{
        if(index < 0 || index >= children.length){
            return false;
        }
        return false;
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
        setHoverIndex(index);
    }
}
