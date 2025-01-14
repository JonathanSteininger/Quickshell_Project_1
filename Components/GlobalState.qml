pragma Singleton

import Quickshell 
import QtQuick
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris

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
        "player"
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
        "time",
        "brightness"
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
    function removeNode(object, index){
        if(object == null){
            console.log("Removed object was null??");
            return;
        }

        var index = objectTracker.objects.findIndex((node) => {
            if(node == null) return false;
            return node.name == object.name && node.id == object.id;
        })
        objectTracker.objects[index] = null;
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
            return;
        }
        Pipewire.preferredDefaultAudioSink = obj;
    }
    function saveNode(node: PwNode): void{
        if(!objectTracker.objects.some((child) => compareNodes(child, node))){
            objectTracker.objects.push(node);
        }
    }



    property int activePlayer: 0;
    property var players: Mpris.players;
    property var activePlayerActual: players.values[activePlayer];
    readonly property int playerAmount: Mpris.players.values.length;

    Component.onCompleted: {
        Pipewire.nodes.objectInsertedPost.connect(updateTrackers);
        Pipewire.nodes.objectRemovedPre.connect(removeNode);
        updateTrackers();
        Mpris.players.objectRemovedPost.connect(validatePlayerIndex);
        Mpris.players.objectInsertedPost.connect(validatePlayerIndex);
    }
    function validatePlayerIndex(object, index){
        if(activePlayer >= playerAmount){
            activePlayer = playerAmount-1;
            return;
        }
        if(activePlayer < 0){
            activePlayer = 0;
        }
    }
    function nextPlayer(){
        if(activePlayer >= playerAmount -1){
            activePlayer = 0;
            return;
        }
        activePlayer++;
    }
    function previousPlayer(){
        if(activePlayer <= 0){
            activePlayer = players.values.length-1;
            return;
        }
        activePlayer--;
    }
}
