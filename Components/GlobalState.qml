pragma Singleton

import Quickshell 
import QtQuick
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Services.Mpris
import Quickshell.Services.SystemTray
import qs.Components as Components
import Quickshell.Io

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
        console.log("popoutRight:", id, right);
    }
    property int right: -1;
    property bool showRight: false;
    property point rightPos: Qt.point(0, -80);

    property list<string> rightMap:[
        "audio",
        "tray_menu",
        "brightness",
        "network"
    ]


    readonly property list<QtObject> networkInterfaces: [];
    readonly property int kiloBytesRecivedTotal: networkInterfaces.reduce((acc, current) => acc += current.kiloBytesRecived, 0);
    readonly property int kiloBytesTransmittedTotal: networkInterfaces.reduce((acc, current) => acc += current.kiloBytesTransmitted, 0);
    readonly property int kiloBitsRecivedTotal: kiloBytesRecivedTotal * 8;
    readonly property int kiloBitsTransmittedTotal: kiloBytesTransmittedTotal * 8;

    function getNetworkingText(value, isbits){
        var endBit = "Bps";
        if (isbits) {
            endBit = "bps";
        }
        //Kbit
        if (value < 1000){
            return `${value}K${endBit}`;
        }
        //Mbit
        if (value < 1000000){
            return `${Math.round(value/1024)}M${endBit}`;
        }
        //Gbit
        if (value < 1000000000){
            return `${Math.round(value/(1024*1024))}G${endBit}`;
        }
        //Tbit
        //this can overflow. scawy, but that would be crazy
        return `${Math.round(value/(1024*1024*1024))}T${endBit}`;
    }

    Timer{
        running: true;
        repeat: true;
        interval: 5000;
        onTriggered: proccessNetworkInterfaces.running = true;
    }

    property real networkUpdateRate: 1000;
    onNetworkUpdateRateChanged: {
        networkInterfaces.forEach((netInt) => netInt.updateRate = networkUpdateRate);
    }

    property list<string> updatedPaths;

    function clearNetworkPaths(){
        updatedPaths = updatedPaths.filter(() => false);
    }

    readonly property var netIntComponent: Qt.createComponent("NetworkInteface.qml");

    function updateNetworkInterfaces(){
        if(netIntComponent.status != Component.Ready){
            console.error("NetworkInterface is not ready:", netIntComponent.status);
            console.error("Null:", Component.Null, "Ready:", Component.Ready, "Loading:", Component.Loading, "Error:", Component.Error);
            return
        }
        var removableInterfaces = networkInterfaces.filter((face) => !updatedPaths.some((path) => path == face.interfacePath));
        if(removableInterfaces.length != 0){
            //removes gonna be null values.
            networkInterfaces = networkInterfaces.filter((face) => updatedPaths.some((path) => path == face.interfacePath));;
            removableInterfaces.forEach((removableThing) => {
                console.log("destroying:", removableThing.interfacePath);
                removableThing.destroy()
            });
        }
        var missingPaths = updatedPaths.filter((path) => !networkInterfaces.some((face) => face.interfacePath == path));
        missingPaths.forEach((path) => {
            console.log("creating: ", path);
            networkInterfaces.push(netIntComponent.createObject(null, {interfacePath: path, updateRate: networkUpdateRate}))
        });
    }

    Process{
        id: proccessNetworkInterfaces;
        command: ["find", "/sys/class/net", "-maxdepth", "1", "-mindepth", "1"];
        running: true;
        onStarted: root.clearNetworkPaths();
        onExited: root.updateNetworkInterfaces();
        stdout: SplitParser{
            onRead: (data) => {
                root.updatedPaths.push(data);
            }
        }
    }


    property var blankTrayMenu: null;
    property var activeSysTrayMenu: null;


    //tracks default audio.
    readonly property PwNode defaultAudio: Pipewire.defaultAudioSink;
    readonly property PwNode defaultAudioSource: Pipewire.defaultAudioSource;
    readonly property var outputNodes: Pipewire.nodes.values.filter((node) => !isStream(node.type) && isAudio(node.type) && isSink(node.type));
    readonly property var inputNodes: Pipewire.nodes.values.filter((node) => !isStream(node.type) && isAudio(node.type) && isSource(node.type));
    readonly property var applicationOutputNodes: Pipewire.nodes.values.filter((node) => isStream(node.type) && isAudio(node.type) && isSink(node.type));
    readonly property var applicationInputNodes: Pipewire.nodes.values.filter((node) => isStream(node.type) && isAudio(node.type) && isSource(node.type));
    readonly property var videoNodes: Pipewire.nodes.values.filter((node) => !isStream(node.type) && isVideo(node.type) && isSource(node.type));

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

    property QtObject battery: QtObject {
        property UPowerDevice mainBattery: UPower.devices.values.find((device) => device.isLaptopBattery);
        property string percentage: `${Math.round(mainBattery.percentage*1000)/10}%`;
        onMainBatteryChanged: {
            console.log(mainBattery.iconName, Quickshell.iconPath(mainBattery.iconName));
        }
    }


    //workaround for brightness controls. 
    //apple cinnema displays use usb bus.
    //a tool like acdcontrol is used to control it. 
    //but it needs the path to the device. Maybe in the future I will find this dynamically.
    //By writing a dbus service that is in this repo.
    property var appleCinamaDisplays: [
        "/dev/usb/hiddev1"
    ]

    Component.onCompleted: {
        Mpris.players.objectRemovedPost.connect(validatePlayerIndex);
        Mpris.players.objectInsertedPost.connect(validatePlayerIndex);
    }
}
