import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

pragma ComponentBehavior: Bound;

Canvas{
    id: root;
    implicitWidth: 50;
    implicitHeight: 50;

    default property alias data: childContainer.data;

    property alias currentIndex: childContainer.childIndex;

    property var currentObject: () => {
        if(currentIndex < 0 || currentIndex >= childContainer.children.length)
            return null;
        return childContainer.children[currentIndex];
    }
    property bool animate: false;
    property real cornerSize: 10;
    property real _top: cornerSize;
    property real _left: cornerSize;
    property real _bottom: height - cornerSize;
    property real _right: width - cornerSize;
    property var color: "white";
    property var borderColor: "black";
    property real borderSize: 2;

    component SimpleBehavior: Behavior{
        SequentialAnimation{
            ScriptAction{
                script: {
                    animationDelay.restart();
                    animationDelay.running = true;
                    root.animate = true;
                }
            }
            PropertyAnimation{
                duration: 800;
                easing.type: Easing.OutExpo;
            }
        }
    }

    SimpleBehavior on width{}
    SimpleBehavior on height{}
    SimpleBehavior on x{}
    SimpleBehavior on y{}


    Timer{
        id: animationDelay;
        interval: 850;
        onTriggered: root.animate = false;
    }


    FrameAnimation{
        running: root.animate;
        onTriggered: () => root.requestPaint();
    }

    function paintBackground(ctx){
        ctx.beginPath();
        ctx.fillStyle = color
        ctx.strokeStyle = borderColor
        ctx.lineWidth = borderSize;
        ctx.moveTo(_left, 0);
        ctx.lineTo(_right, 0);
        ctx.lineTo(width, _top);
        ctx.lineTo(width, _bottom);
        ctx.lineTo(_right, height);
        ctx.lineTo(_left, height);
        ctx.lineTo(0, _bottom);
        ctx.lineTo(0, _top);
        ctx.lineTo(_left, 0);
        ctx.fill();
        ctx.stroke();
        ctx.closePath();
    }

    onPaint: {
        var ctx = getContext("2d");
        paintBackground(ctx);
    }
    clip: true;

    Item{
        id: childContainer;
        onChildrenChanged: () =>{
            setupChildren();
        }
        x: 5;
        y: 5;
        property int childIndex: -1;
        property int pastIndex: -1;
        function setupChildren(){
                console.log("setup start");
            for(var i = 0; i < children.length; i++){
                console.log("setup");
                children[i].visible = childIndex == i;
                console.log(children[i].visible);
            }
        }
        onChildIndexChanged: () => {
            testAnimation.start();
        }
        clip: true;

        SequentialAnimation{
            id: testAnimation;
            ScriptAction{
                script: childContainer.swapSize();
            }
            NumberAnimation{
                target: childContainer;
                properties: "opacity";
                to: 0;
                duration: 200;
                easing.type: Easing.OutExpo;
            }
            ScriptAction{
                script: childContainer.swap();
            }
            NumberAnimation{
                target: childContainer;
                properties: "opacity";
                to: 1;
                duration: 200;
                easing.type: Easing.InExpo;
            }
        }


        function swapSize():void{
            width = children[childIndex].width;
            height = children[childIndex].height;
            root.width = width + 10;
            root.height = height + 10;
        }

        function swap():void {
            console.log("THIS", childIndex);
            if(pastIndex == childIndex){
                children[childIndex].visible = true;
                return;
            }
            if(childIndex < 0 || childIndex >= children.length){
                return;
            }
            if(pastIndex > 0 && pastIndex < children.length){
                children[pastIndex].visible = false;
            }
            children[childIndex].visible = true;
            for(var i = 0; i < children.length; i++){
                children[i].visible = childIndex == i;
            }
        }
        Component.onCompleted: {
            setupChildren();
        }
    }
}
