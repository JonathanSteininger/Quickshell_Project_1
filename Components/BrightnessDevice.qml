import QtQuick
import Quickshell.Io

/// helper object to get and set backlight devices.
QtObject{
    id: root;
    /// the path to the backlight. eg: /sys/classl/backlight/<backlightname>
    required property string backlightPath;

    readonly property string deviceInfoPath: `${backlightPath}/device/uevent`;
    readonly property string brightnessPath: `${backlightPath}/brightness`;
    readonly property string max_brightnessPath: `${backlightPath}/max_brightness`;
    readonly property string min_brightnessPath: `${backlightPath}/max_brightness`;
    readonly property string current_brightnessPath: `${backlightPath}/actual_brightness`;

    property string deviceName: "placeholder";
    property int brightness: 50;
    property int max_brightness: 100;
    property int min_brightness: 0;

    // clamp min value which can be changed
    onMin_brightnessChanged: {
        if (min_brightness < 0) {
            min_brightness = 0;
            return;
        }
        if (min_brightness > max_brightness) {
            min_brightness = max_brightness;
        }
    }

    function updateDeviceInfo() {
        var lines = uevent.split('\n');
        lines.forEach((line) => {
            var splitter = line.indexOf('=');
            var key = line.substring(0,splitter);
            var value = line.substring(splitter+1);
            switch(key){
                case "OF_NAME":
                    deviceName = value;
                    break;
                default:
                    break;
            }
        })
    }

    readonly property bool canWrite: true;


    //take appart the uevent info.
    onDeviceInfoPathChanged: {
        updateDeviceInfo();
    }

    function setBrightness(brightness) {
        if (brightness == root.brightness) {
            return;
        }

        if (brightness > max_brightness) { 
            brightness = max_brightness;
        }

        if (brightness < min_brightness) {
            brightness = min_brightness;
        }
        setBrightnessProc.targetValue = brightness.toString();
        setBrightnessProc.startDetached();

        /*
        try{
            console.log("setting brightness", brightness);
            brightnessFile.setText(brightness.toString())
        } catch (err) {
            console.error("Failed to set brightness");
        }
        */
    }

    signal updated();

    function update(){
        brightnessFile.reload();
        max_brightnessFile.reload();
        ueventFile.reload();
        actual_brightnessFile.reload();
        updated();
    }


    readonly property list<QtObject> processes: [
        FileView{
            id: brightnessFile;
            path: root.brightnessPath;
            watchChanges: true;
            onFileChanged: this.reload();
            onLoaded: {
                console.log("Getting brightness: ", root.brightnessPath);
                root.brightness = parseInt(this.text().trim())
            }
        },
        FileView{
            id: max_brightnessFile;
            path: root.max_brightnessPath;
            watchChanges: true;
            onFileChanged: this.reload();
            onLoaded: {
                console.log("Getting max brightness: ", root.max_brightnessPath);
                root.max_brightness = parseInt(this.text().trim());
            }
        },
        FileView{
            id: ueventFile;
            path: root.deviceInfoPath;
            watchChanges: true;
            onFileChanged: this.reload();
            onLoaded: {
                console.log("Getting device info: ", root.deviceInfoPath);
                root.updateDeviceInfo();
            }
        },
        FileView{
            id: actual_brightnessFile;
            path: current_brightnessPath;
            watchChanges: false;
            onLoaded: {
                console.log("Getting max brightness: ", root.max_brightnessPath);
                root.max_brightness = parseInt(this.text().trim());
            }
        },
        Timer{
            interval: 100;
            repeat: false;
            running: !root.canWrite;
            onTriggered: () => {
                actual_brightnessFile.reload();
                root.canWrite = true;
                updateSafeDelay.restart();
            }
        },
        Timer{
            id: updateSafeDelay;
            interval: 1000;
            repeat: false;
            onTriggered: {
                console.log("updated after delay");
                root.update();
            }
        },
        Process{
            id: setBrightnessProc;
            running: false;
            property string targetValue: "1000";
            command: ["bash", "-c", `echo ${targetValue} > ${root.brightnessPath}`] 
        }
    ]
    Component.onCompleted: {
        update();
    }
}
