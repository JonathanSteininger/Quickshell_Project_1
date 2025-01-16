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

    property real spacing: 30;
    property int centerIndex: 0;
    Behavior on width{
        NumberAnimation {
            duration: 200;
            easing.type: Easing.OutExpo;
        }
    }

    width: childContainer.width + spacing + height;
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
            x: root.width - root.shift1;
        }
        PathLine{
            y: root.height;
            x: root.width - root.shift2;
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
        property int childIndexBuffer: -1;
        property int previousChildIndex: 0;
        property int childIndex: -1;
        onChildIndexChanged: {
            previousChildIndex = childIndexBuffer;
            childIndexBuffer = childIndex;
        }
        property int usedChildIndex: childIndex != -1 ? childIndex : previousChildIndex;
        property real childWidth: root.innerChildren[usedChildIndex].width;
        property real targetHeight: childIndex == -1 ? 0 : root.height;
        property real shapeHeight: targetHeight;
        //width: childWidth + root.spacing;
        x: root.innerChildren[usedChildIndex].x;
        width: childWidth + height + root.spacing;
        height: root.height;

        component SimpleTest: Behavior{
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutExpo;
            }
        }
        SimpleTest on width{ }
        SimpleTest on shapeHeight{ }
        SimpleTest on x{ }

        readonly property real shift: height * root.tiltStrength;
        readonly property real shift1: root.tiltRight ? shift : 0;
        readonly property real shift2: root.tiltRight ? 0 : shift;

        property real topLeft: usedChildIndex <= root.centerIndex ? shift1: shift2;
        property real topRight: usedChildIndex < root.centerIndex ? shift2 : shift1;
        property real bottomLeft: (childIndex == -1) ? topLeft : (usedChildIndex <= root.centerIndex ? shift2 : shift1);
        property real bottomRight: (childIndex == -1) ? topRight : (usedChildIndex < root.centerIndex ? shift1 : shift2);
        SimpleTest on topLeft{ }
        SimpleTest on topRight{ }
        SimpleTest on bottomLeft{ }
        SimpleTest on bottomRight{ }

        readonly property real ratio: 1 - (shapeHeight / height);
        readonly property real shiftMid: (root.tiltRight ? -1 : 1) * shift * ratio;
         

        ShapePath{
            strokeWidth: 0;
            fillColor: root.borderColor;
            startY: 0;
            startX: hoverShape.topLeft;
            PathLine{
                y: 0;
                x: hoverShape.width - hoverShape.topRight;
            }
            PathLine{
                y: hoverShape.shapeHeight;
                x: hoverShape.width - hoverShape.bottomRight;
            }
            PathLine{
                y: hoverShape.shapeHeight;
                x: hoverShape.bottomLeft;
            }
            PathLine{
                y: 0;
                x: hoverShape.topLeft;
            }
        }
    }
    Repeater{
        model: root.innerChildren.length;
        Shape{
            required property int index;
            visible: index != 0;
            id: lineSplitter;
            height: parent.height;
            x: root.innerChildren[index].x;
            readonly property real shift: height * root.tiltStrength;
            readonly property real shift2: root.centerIndex < index ? (root.tiltRight ? shift : 0) : (root.tiltRight ? 0 : shift);
            readonly property real shift1: root.centerIndex < index ? (root.tiltRight ? 0 : shift) : (root.tiltRight ? shift : 0);
            width: shift;
            ShapePath{
                strokeColor: root.borderColor;
                strokeWidth: root.borderSize;
                startY: 0
                startX: lineSplitter.shift1;
                PathLine{
                    y: lineSplitter.height;
                    x: lineSplitter.shift2;
                }
            }
        }
    }

    RowLayout{
        id: childContainer;
        height: parent.height;
        spacing: root.spacing;
        x: root.height/2 + root.spacing/2;
    }


        
    MouseArea{
        anchors.fill: parent;
        hoverEnabled: true;
        onReleased: {
            parent.clickChild(mouseX, mouseY);
        }
        onPositionChanged: {
            parent.checkChildrenHover(mouseX, mouseY);
        }
        onExited: {
            hoverShape.childIndex = -1;
        }
        onWheel: (wheelEvent) => {
            root.scrollChild(wheelEvent);
        }
    }

    function scrollChild(wheelEvent){
        if(hoverShape.childIndex == -1){
            return;
        }

        if(innerChildren[hoverShape.childIndex].onWheel == undefined){
            return;
        }
        innerChildren[hoverShape.childIndex].wheel(wheelEvent);
    }

    function checkChildrenHover(_x, _y){
        var index = checkPosInBounds(_x, _y);
        if(index == -1){
            hoverShape.childIndex = index;
            return;
        }
        if(innerChildren[index].onClicked == undefined){
            hoverShape.childIndex = -1;
            return;
        }
        hoverShape.childIndex = index;
    }

    function clickChild(_x, _y){
        var index = checkPosInBounds(_x, _y);
        if (index != -1){
            if(innerChildren[index].onClicked == undefined){
                return;
            }
            innerChildren[index].clicked();
        }
    }


    function checkPosInBounds(_x, _y): int{
        if(tiltRight){
            //+1 feels more accurate.
            _x -= (height - _y + 1) * tiltStrength;
        }else{
            _x -= _y * tiltStrength;
        }
        var offset = spacing/2;
        for(var i = 0; i < innerChildren.length; i++){
            var _left = innerChildren[i].x;
            var _right = innerChildren[i].x + innerChildren[i].width + spacing;
            if(_x >= _left && _x < _right){
                return i;
            }
        }
        return -1;
    }

}
