pragma Singleton

import Quickshell 
import QtQuick
import Quickshell.Services.Pipewire

Singleton {
    property int popupOffset: 8;



    function popupLeft(id: string, x: int): void{
        var lower = id.toLowerCase();
        left = leftMap.findIndex((child) => child == lower);
        leftPos.x = x;
        leftPos.y = popupOffset;
        middle = -1;
        right = -1;
    }
    property bool showLeft: false;
    property int left: -1;
    property point leftPos: Qt.point(0, -80);

    property list<string> leftMap:[
        "audio",
        "time"
    ]





    function popupMiddle(id: string, x: int): void{
        var lower = id.toLowerCase();
        middle = middleMap.findIndex((child) => child == lower);
        middlePos.x = x;
        middlePos.y = popupOffset;
        left= -1;
        right = -1;
    }
    property int middle: -1;
    property bool showMiddle: false;
    property point middlePos: Qt.point(0, -80);

    property list<string> middleMap:[
        "audio",
        "time"
    ]




    function popupRight(id: string, x:int): void{
        var lower = id.toLowerCase();
        right = rightMap.findIndex((child) => child == lower);
        rightPos.x = x;
        rightPos.y = popupOffset;
        left= -1;
        middle= -1;
    }
    property int right: -1;
    property bool showRight: false;
    property point rightPos: Qt.point(0, -80);

    property list<string> rightMap:[
        "audio",
        "time"
    ]



    //tracks default audio.
    readonly property PwNode defaultAudio: Pipewire.defaultAudioSink;

    onDefaultAudioChanged: {
        objectTracker.objects.pop();
        objectTracker.objects.push(defaultAudio);
    }
    property PwObjectTracker tracker: PwObjectTracker{
        id: objectTracker;
        Component.onCompleted: {
        return;
            objects.push(...Pipewire.nodes.values)
        }
    }
    Component.onCompleted: {
        Pipewire.nodes.objectInsertedPost.connect(updateTrackers);
        updateTrackers();
    }
    function compareNodes(a: PwNode, b:PwNode):bool {
        if(a == null) return false;
        if(b == null) return false;
        return a.id == b.id && a.name == b.name;
    }
    //put checks for things you want to track here. will automatically grab those nodes
    function updateTrackers(){
        Pipewire.nodes.values.forEach((node) => {
            if(node.isSink && !node.isStream && node.audio){
                saveNode(node);
            } else if(!node.isSink && node.isStream && node.audio){
                saveNode(node);
            }
        })
    }
    function setNodeDefault(name: string, id: int){
        var obj = objectTracker.objects.find((node) => {
            if(node == null) return false;
            return node.name == name && node.id == id;
        }
        );
        if (obj == null || obj == undefined){
            console.log("failed to set default audio node. not found", name, id);
            updateTrackers();
            return;
        }
        Pipewire.preferredDefaultAudioSink = obj;
        updateTrackers();
    }
    function saveNode(node: PwNode): void{
        if(!objectTracker.objects.some((child) => compareNodes(child, node))){
            objectTracker.objects.push(node);
        }
    }
}
