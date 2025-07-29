pragma Singleton

import Quickshell 
import QtQuick
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris
import Quickshell.Services.SystemTray

Singleton {
    id: root;
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
        console.log(right);
    }
    property int right: -1;
    property bool showRight: false;
    property point rightPos: Qt.point(0, -80);

    property list<string> rightMap:[
        "audio",
        "tray_menu",
        "brightness"
    ]

    property var blankTrayMenu: null;
    property var activeSysTrayMenu: null;

    //tracks default audio.
    readonly property PwNode defaultAudio: Pipewire.defaultAudioSink;
    readonly property PwNode defaultAudioSource: Pipewire.defaultAudioSource;
    readonly property list<PwNode> outputNodes: Pipewire.nodes.values.filter((node) => !isStream(node.type) && isAudio(node.type) && isSink(node.type));
    readonly property list<PwNode> inputNodes: Pipewire.nodes.values.filter((node) => !isStream(node.type) && isAudio(node.type) && isSource(node.type));
    readonly property list<PwNode> applicationOutputNodes: Pipewire.nodes.values.filter((node) => isStream(node.type) && isAudio(node.type) && isSink(node.type));
    readonly property list<PwNode> applicationInputNodes: Pipewire.nodes.values.filter((node) => isStream(node.type) && isAudio(node.type) && isSource(node.type));
    readonly property list<PwNode> videoNodes: Pipewire.nodes.values.filter((node) => !isStream(node.type) && isVideo(node.type) && isSource(node.type));

    readonly property PwObjectTracker defaultAudioTracker: PwObjectTracker{
        objects: [root.defaultAudio, root.defaultAudioSource];
    }


    //just yoinked the bitwise operation. cant find anywhere mentioning which bits are which.
    //from https://git.drinkmymilk.org/PapaMilky/Quickshell/src/branch/newRice/Global/Sound.qml
    function isAudio(type) {
        return (type & 0b00000001) !== 0
    }

    function isVideo(type) {
        return (type & 0b00000010) !== 0
    }

    function isStream(type) {
        return (type & 0b00000100) !== 0
    }

    function isSource(type) {
        return (type & 0b00001000) !== 0
    }

    function isSink(type) {
        return (type & 0b00010000) !== 0
    }

    property int activePlayer: 0;
    property var players: Mpris.players;
    property var activePlayerActual: players.values[activePlayer];
    readonly property int playerAmount: Mpris.players.values.length;


    Component.onCompleted: {
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




    property SystemClock clock: SystemClock{ 
        precision: SystemClock.Seconds;
    }




    //workaround for brightness controls. 
    //apple cinnema displays use usb bus.
    //a tool like acdcontrol is used to control it. 
    //but it needs the path to the device. Maybe in the future I will find this dynamically.
    //By writing a dbus service that is in this repo.
    property var appleCinamaDisplays: [
        "/dev/usb/hiddev1"
    ]
}
