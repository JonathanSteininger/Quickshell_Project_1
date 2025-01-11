import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Shapes

pragma ComponentBehavior: Bound;

Shape{
    id: root;
    implicitWidth: 50;
    implicitHeight: 50;

    default property alias data: childContainer.data;
    property alias internalClip: childContainer.clip;

    property alias currentIndex: childContainer.childIndex;
    property alias innerHeight: childContainer.height;
    property alias innerWidth: childContainer.width;

    property var currentObject: () => {
        if(currentIndex < 0 || currentIndex >= childContainer.children.length)
            return null;
        return childContainer.children[currentIndex];
    }
    property real cornerSize: 10;
    property real _top: cornerSize;
    property real _left: cornerSize;
    property real _bottom: height - cornerSize;
    property real _right: width - cornerSize;
    property var color: "white";
    property var borderColor: "black";
    property real borderSize: 2;
    property real padding: 5;

    property int duration: 400;
    
    signal deselect();
    signal select();

    component SimpleBehavior: Behavior{
        SequentialAnimation{
            PropertyAnimation{
                duration: root.duration;
                easing.type: Easing.OutExpo;
            }
        }
    }

    SimpleBehavior on width {}
    SimpleBehavior on height {}
    SimpleBehavior on x {}
    SimpleBehavior on y {}


    ShapePath{
        joinStyle: ShapePath.MiterJoin;
        fillColor: root.color;
        strokeColor: root.borderColor;
        strokeStyle: ShapePath.SolidLine;
        strokeWidth: root.borderSize;
        startX: root.cornerSize;
        startY: 0;
        pathHints: ShapePath.PathLinear + ShapePath.PathSolid + ShapePath.PathFillOnRight + ShapePath.PathConvex + ShapePath.PathNonIntersecting;
        PathLine { x: root.width - root.cornerSize; y: 0 }
        PathLine { x: root.width; y: root.cornerSize; }
        PathLine { x: root.width; y: root.height - root.cornerSize; }
        PathLine { x: root.width - root.cornerSize; y: root.height; }
        PathLine { x: root.cornerSize; y: root.height; }
        PathLine { x: 0; y: root.height - root.cornerSize; }
        PathLine { x: 0; y: root.cornerSize; }
        PathLine { x: root.cornerSize; y: 0; }
    }

    clip: false;

    signal setWidth(value: real)
    signal setHeight(value: real)
    width: childContainer.width + padding*2;
    height: childContainer.height + padding*2;

    Item{
        id: childContainer;
        onChildrenChanged: () =>{
            setupChildren();
        }
        x: root.padding;
        y: root.padding;
        property int childIndex: -1;
        property int pastIndex: -1;
        function setupChildren(){
            for(var i = 0; i < children.length; i++){
                children[i].visible = childIndex == i;
            }
        }
        onChildIndexChanged: () => {
            //testAnimation.start();
            if(childIndex >= 0 && childIndex < children.length){
                root.select();
            }
            ticker++;
        }
        function animationCompleted(){
            if(childIndex == -1){
                root.deselect();
            }
        }
        property int ticker: 0;
        clip: true;

        
        Behavior on ticker{
            SequentialAnimation {
                id: testAnimation;
                ScriptAction{
                    script: childContainer.swapSize();
                }
                NumberAnimation{
                    target: childContainer;
                    properties: "opacity";
                    to: 0;
                    duration: root.duration / 2;
                    easing.type: Easing.OutQuad;
                }
                ScriptAction{
                    script: childContainer.swap();
                }
                NumberAnimation{
                    target: childContainer;
                    properties: "opacity";
                    to: 1;
                    duration: root.duration / 2;
                    easing.type: Easing.InQuad;
                }
                ScriptAction{
                    script: childContainer.animationCompleted();
                }
            }
        }


        signal setWidth(value: real)
        signal setHeight(value: real)
        onSetWidth: (value) => {
            width = value;
            root.setWidth(value + root.padding*2);
        }
        onSetHeight: (value) => {
            height = value;
            root.setHeight(value + root.padding*2);
        }

        function swapSize():void{
            swapSizefr();
        }
        function swapSizefr(){
            if(childIndex < 0 || childIndex >= children.length){
                return;
            }
            updateHeight();
            updateWidth();
        }
        function updateHeight(){
            if(childIndex < 0 || childIndex >= children.length){
                return;
            }
            setHeight(children[childIndex].height);
        }
        function updateWidth(){
            if(childIndex < 0 || childIndex >= children.length){
                return;
            }
            setWidth(children[childIndex].width);
        }

        function swap():void {
            for(var i = 0; i < children.length; i++){
                children[i].visible = childIndex == i;
                if(childIndex == i){
                    children[childIndex].onHeightChanged.connect(updateHeight);
                    children[childIndex].onWidthChanged.connect(updateWidth);
                }else{
                    children[childIndex].onHeightChanged.disconnect(updateHeight);
                    children[childIndex].onWidthChanged.disconnect(updateWidth);
                }
            }
        }
        Component.onCompleted: {
            setupChildren();
        }
    }
}
