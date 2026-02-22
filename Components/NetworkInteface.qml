import QtQuick
import Quickshell.Io

// /sys/class/net/<interface>/operstate: string for opertation state 
//
// /sys/class/net/<interface>/uevent: <key>=value text file with device properties.
// > get the device type from here.

// /sys/class/net/<interface>/statistics/{r,w}x_bytes: int = the amount of bytes transmitted / recived in total.
// > this can apperantly have different meanings depending on driver.
// > but fuck it. it goes up in bytes because this would be ass to figure this shit out.
QtObject{
    id: root;
    enum NetworkIntefraceType{
        Unknown,
        Ethernet,
        Bridge,
        Tunnel,
        Wlan,
        Loopback
    }
    readonly property list<string> networkIngerfaceNameMap: [
        "Unknown",
        "Ethernet",
        "Bridge",
        "Tunnel",
        "Wlan",
        "Loopback"
    ]

    property real updateRate: 2000;
    property real interfaceInfoUpdateRate: 10000;
    property bool updateRunning: true;

    //used for everything else.
    required property string interfacePath; 

    property int type: NetworkInteface.NetworkIntefraceType.Unknown;
    property string name: "NULL name";
    readonly property string typeName: networkIngerfaceNameMap[type];
    property int id: -1;

    readonly property string uevent: ueventFile.text();
    onNameChanged: {
        if(name == "lo"){
            type = NetworkInteface.NetworkIntefraceType.Loopback;
        }
    }

    //take appart the uevent info.
    onUeventChanged: {
        var lines = uevent.split('\n');
        lines.forEach((line) => {
            var splitter = line.indexOf('=');
            var key = line.substring(0,splitter);
            var value = line.substring(splitter+1);
            switch(key){
                case "DEVTYPE":
                    break;
                    switch (value){
                        case "wlan":
                            type = NetworkInteface.NetworkIntefraceType.Wlan;
                            break;
                        case "bridge":
                            type = NetworkInteface.NetworkIntefraceType.Bridge;
                            break;
                        case "ethernet":
                            type = NetworkInteface.NetworkIntefraceType.Ethernet;
                            break;
                        case "tunnel":
                            type = NetworkInteface.NetworkIntefraceType.Tunnel;
                            break;
                        default:
                            type = NetworkInteface.NetworkIntefraceType.Unknown;
                            break;
                    }
                    
                case "INTERFACE":
                    name = value;
                    break;
                case "IFINDEX":
                    id = parseInt(value);
                    break;
                case "":
                    break;
                default:
                    console.error("unknown uevent key:", `(${key})`);
                    break;
            }
        })
    }

    //may be hard to get.
    readonly property string ipv4_address: "NULL 0.0.0.0";
    readonly property string ipv6_address: "NULL ::";

    readonly property string mac_address: addressFile.text();

    readonly property bool isUp: false;
    readonly property string status: operstateFile.text();
    
    //maybe recived and transmitted since last update. then dont have to worry about 32bit limit
    // 32 bit limit is 2.147 billion. which translates to 2,147,000,000 bytes, or 2.147GB
    // this is bad, will prob need to cut it short, eg record kb in stead of b
    // will track both incase the sus one is needed for some reason.

    property string totalPreviousRecived: "0";
    property string totalPreviousTransmitted: "0";
    property string totalRecived: "0";
    property string totalTransmitted: "0";

    property int kiloBytesRecived: 0;
    property int kiloBytesTransmitted: 0;

    readonly property int kiloBitsRecived: kiloBytesRecived*8;
    readonly property int kiloBitsTransmitted: kiloBytesTransmitted*8;

    function updateInterfaceInfo(){
        operstateFile.reload();
        addressFile.reload();
        ueventFile.reload();
    }

    readonly property list<QtObject> processes: [
        Timer{
            interval: root.interfaceInfoUpdateRate;
            repeat: true;
            running: root.updateRunning;
            onTriggered: root.updateInterfaceInfo();
        },
        FileView{
            id: operstateFile;
            path: `${root.interfacePath}/operstate`;
            watchChanges: true;
            onFileChanged: {
                this.reload();
            }
        },
        FileView{
            id: addressFile;
            path: `${root.interfacePath}/address`;
            watchChanges: true;
            onFileChanged: this.reload();
        },
        FileView{
            id: ueventFile;
            path: `${root.interfacePath}/uevent`;
            watchChanges: true;
            onFileChanged: this.reload();
        },
        FileView{
            id: recivedBytesWatcher;
            path: `${root.interfacePath}/statistics/rx_bytes`;
            watchChanges: false;
        },
        FileView{
            id: transmittedBytesWatcher;
            path: `${root.interfacePath}/statistics/tx_bytes`;
            watchChanges: false;
        },
        Process{
            id: proccessBytesRecived;
            running: false;
            onStarted: {
                if(root.totalRecived != "0"){
                    root.totalPreviousRecived = root.totalRecived;
                }
                recivedBytesWatcher.reload();
                root.totalRecived = recivedBytesWatcher.text().trim();
            }
            command: ["bash", "--norc", "-c", `bc <<< "($(cat ${root.interfacePath}/statistics/rx_bytes)-${root.totalPreviousRecived})/1024/${root.updateRate/1000}"`];
            stdout: SplitParser{ 
                onRead: (data) => {
                    root.kiloBytesRecived = parseInt(data);
                }
            }
            stderr: SplitParser{ 
                onRead: (data) => {
                    console.error("network recived tracker error:", data);
                    console.error("network recived tracker command:", ...proccessBytesRecived.command);
                }
            }
        },
        Process{
            id: proccessBytesTransmitted;
            running: false;
            onStarted: {
                if(root.totalTransmitted != "0"){
                    root.totalPreviousTransmitted = root.totalTransmitted;
                }
                transmittedBytesWatcher.reload();
                root.totalTransmitted = transmittedBytesWatcher.text().trim();
            }
            command: ["bash", "--norc", "-c", `bc <<< "($(cat ${root.interfacePath}/statistics/tx_bytes)-${root.totalPreviousTransmitted})/1024/${root.updateRate/1000}"`];
            stdout: SplitParser{ 
                onRead: (data) => {
                    root.kiloBytesTransmitted = parseInt(data);
                }
            }
            stderr: SplitParser{ 
                onRead: (data) => {
                    console.error("network transmitted tracker error:", data);
                    console.error("network transmitted tracker command:", ...proccessBytesTransmitted.command);
                }
            }
        },
        Timer{
            id: updateTimer;
            interval: root.updateRate;
            running: root.updateRunning;
            repeat: true;
            onTriggered: {
                if(root.totalPreviousRecived == "0"){
                    root.totalPreviousRecived = recivedBytesWatcher.text().trim();
                }else{
                    proccessBytesRecived.running = true;
                }

                if(root.totalPreviousTransmitted == "0"){
                    root.totalPreviousTransmitted = transmittedBytesWatcher.text().trim();
                }else{
                    proccessBytesTransmitted.running = true;
                }
            }
        }
    ]
    Component.onCompleted: {
        recivedBytesWatcher.reload();
        transmittedBytesWatcher.reload();
        operstateFile.reload();
        addressFile.reload();
        ueventFile.reload();
    }
}
