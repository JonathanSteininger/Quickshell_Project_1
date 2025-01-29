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
    property bool centerLine: false;
    readonly property int centerIndexReal: centerIndex < 0 || centerIndex >= innerChildren.length ? Math.floor(innerChildren.length/2) : centerIndex;
    property alias innerChildWidth: childContainer.width;
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

        readonly property bool straightenPrev: root.centerLine && usedChildIndex == root.centerIndex;
        readonly property bool straightenNext: root.centerLine && usedChildIndex+1 == root.centerIndex;

        property real topLeft: getTopLeft();
        property real topRight: getTopRight();
        property real bottomLeft: getBottomLeft();
        property real bottomRight: getBottomRight();

        function getTopLeft(){
            if(straightenPrev){
                return shift/2;
            }
            return usedChildIndex <= root.centerIndexReal ? shift1: shift2
        }
        function getTopRight(){
            if(straightenNext){
                return shift/2;
            }
            return usedChildIndex < root.centerIndexReal ? shift2 : shift1
        }
        function getBottomLeft(){
            if(straightenPrev){
                return shift/2;
            }
            return (childIndex == -1) ? topLeft : (usedChildIndex <= root.centerIndexReal ? shift2 : shift1);
        }
        function getBottomRight(){
            if(straightenNext){
                return shift/2;
            }
            return  (childIndex == -1) ? topRight : (usedChildIndex < root.centerIndexReal ? shift1 : shift2);
        }

        SimpleTest on topLeft{ }
        SimpleTest on topRight{ }
        SimpleTest on bottomLeft{ }
        SimpleTest on bottomRight{ }


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
        model: childContainer.children.length;
        Shape{
            required property int index;
            visible: index >= 1 && innerChildren[index].width > 0;
            id: lineSplitter;
            height: parent.height;
            x: root.innerChildren[index].x;
            readonly property real shift: height * root.tiltStrength;
            readonly property real shift2: root.centerIndexReal < index ? (root.tiltRight ? shift : 0) : (root.tiltRight ? 0 : shift);
            readonly property real shift1: root.centerIndexReal < index ? (root.tiltRight ? 0 : shift) : (root.tiltRight ? shift : 0);

            readonly property bool straighten: root.centerLine && index == centerIndex;

            width: shift;
            ShapePath{
                strokeColor: root.borderColor;
                strokeWidth: root.borderSize;
                startY: 0
                startX: lineSplitter.straighten ? lineSplitter.width/2 : lineSplitter.shift1;
                PathLine{
                    y: lineSplitter.height;
                    x: lineSplitter.straighten ? lineSplitter.width/2 : lineSplitter.shift2;
                }
            }
        }
    }

    Row{
        id: childContainer;
        height: childrenRect.height;
        anchors.verticalCenter: parent.verticalCenter;
        width: childrenRect.width;
        spacing: root.spacing;
        x: root.height/2 + root.spacing/2;
    }


        
    MouseArea{
        anchors.fill: parent;
        hoverEnabled: true;
        onReleased: (mouseEvent) => {
            if(mouseEvent.button == Qt.LeftButton){
                parent.clickChild(mouseX, mouseY);
            } else if (mouseEvent.button == Qt.RightButton){
                parent.clickAltChild(mouseX, mouseY);
            }
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

    function clickAltChild(_x, _y){
        var index = checkPosInBounds(_x, _y);
        if (index != -1){
            if(innerChildren[index].onRightClicked== undefined){
                return;
            }
            innerChildren[index].rightClicked();
        }
    }

    function checkPosInBounds(mouseX, _y): int{
        var _x = mouseX;
        mouseX -= shift/2;
        var opposit_x = _x;
        if(tiltRight){
            //+1 feels more accurate.
            opposit_x -= _y * tiltStrength;
            _x -= (height - _y + 1) * tiltStrength;
        }else{
            opposit_x -= (height - _y + 1) * tiltStrength;
            _x -= _y * tiltStrength;
        }
        var offset = spacing/2;
        for(var i = 0; i < innerChildren.length; i++){
            var _left = innerChildren[i].x;
            var _right = innerChildren[i].x + innerChildren[i].width + spacing;
            if(i == centerIndexReal-1 && centerLine){
                if(_x >= _left && mouseX < _right){
                    return i;
                }
                continue;
            }
            if(i == centerIndexReal){
                //hitbox for center box
                if(centerLine){
                    if(mouseX >= _left && opposit_x < _right){
                        return i;
                    }
                    continue;
                }
                if(_x >= _left && opposit_x < _right){
                    return i;
                }
                continue;
            }
            if(i > centerIndexReal){
                //hitbox for right boxes
                if(opposit_x >= _left && opposit_x < _right){
                    return i;
                }
                continue;
            }
            //hitboxes for left boxes
            if(_x >= _left && _x < _right){
                return i;
            }
        }
        return -1;
    }

}
