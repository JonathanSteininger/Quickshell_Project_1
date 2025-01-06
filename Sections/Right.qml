import Quickshell
import Quickshell.Io
import Quickshell.Services.SystemTray
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "../Components/"

ButtonStrip{
    id: rightPanel;
    anchors.right: parent.right;
    borderColor: Colour.accent;
    borderSize: 0.6;
    color: Colour.bg;
    tiltRight: true;
    tiltStrength: 1
    implicitHeight: 50;
    Text{
        text: " ";
        color: Colour.fg;
        font.family: "Iosevka";
        font.pointSize: 18;
        horizontalAlignment: Text.AlignHCenter;
        width: 30;
        signal clicked();
        onClicked: () => console.log("open brightness");
        onWidthChanged: {
        }
    }
    Text{
        text: "󰁆";
        color: Colour.fg;
        font.family: "Iosevka";
        font.pointSize: 18;
        horizontalAlignment: Text.AlignHCenter;
        width: 30;
        signal clicked();
        onClicked: () => console.log("open brightness");
        onWidthChanged: {
        }
    }
    Text{
        text: "󰁞";
        color: Colour.fg;
        font.family: "Iosevka";
        font.pointSize: 18;
        horizontalAlignment: Text.AlignHCenter;
        width: 30;
        onWidthChanged: {
        }
    }
    Text{
        text: "";
        color: Colour.fg;
        font.family: "Iosevka";
        font.pointSize: 18;
        horizontalAlignment: Text.AlignHCenter;
        width: 30;
        signal clicked();
        onClicked: () => console.log("open brightness");
        onWidthChanged: {
        }
    }
    Text{
        text: " ";
        color: Colour.fg;
        font.family: "Iosevka";
        font.pointSize: 18;
        horizontalAlignment: Text.AlignHCenter;
        width: 30;
        signal clicked();
        onClicked: () => console.log("open brightness");

    }
    Repeater{
        model: SystemTray.items;
        Rectangle{
            id: trayParent
            required property SystemTrayItem modelData;
            width: childrenRect.width;
            height: childrenRect.height;
            Image{
                id: image;
                source:modelData.icon;
                width: 30;
                height: 30;
            }
            color: Colour.trans;
            signal clicked();
            onClicked: () => modelData.activate();
            ColorOverlay{
                anchors.fill: image;
                source: image;
                color: Colour.fg;
            }
            Component.onCompleted: () => rightPanel._update();
            onWidthChanged: () => rightPanel._update();
        }
        //do this to hide the repeater as a child. uwu --very ugly - pretty much setting width = 0;
        width: -parent.spacing;
    }
    Text{
        id: volume
        property var defaultAudioSink: Pipewire.defaultAudioSink;
        property variant _properties: defaultAudioSink.properties;
        text: defaultAudioSink.id;
        color: Colour.fg;
        font.family: "Iosevka";
        font.pointSize: 14;
        signal clicked();
        onClicked: () => console.log("hello");
        //onTextChanged: parent._update();
        onTextChanged: () => {
            parent._update();
        }
        onDefaultAudioSinkChanged: {
            audioTracker.objects.push(defaultAudioSink);
            //text = defaultAudioSink.properties["media.name"];
            getVolumeProc.running = true;
        }
        PwObjectTracker{
            id: audioTracker;
        }

        Process{
            id: getVolumeProc;
            running: false;
            command: ["sh", "-c", `pw-dump ${volume.defaultAudioSink.id} | jq '.[0].info.params.Props.[0].volume | sqrt * 100'`];
            stdout: SplitParser{
                onRead: (data) => volume.text = `${data}% 󰕾`;
            }//U+1F56
            stderr: SplitParser{
                onRead: (data) => {
                    console.log("volume process failed... or some other error.");
                    console.log("volume error:", data);
                    volume.destroy();
                }
            }
            onExited: (exitCode, exitStatus) => {
                if(exitCode != 0){
                    console.log("error code returned from volume process:", exitCode);
                    volume.destroy();
                }
            }
            
        }
    }
    Text{
        id: battery
        text: "hello";
        color: Colour.fg;
        font.family: "Iosevka";
        font.pointSize: 14;
        Timer{
            interval: 5000;
            repeat: true;
            running: true;
            onTriggered: batteryProc.running = true;
        }
        Process{
            id: batteryProc;
            running: true;
            command: ["sh", "-c", `bc <<< "scale=3;$(cat /sys/class/power_supply/BAT0/charge_now )/$(cat /sys/class/power_supply/BAT0/charge_full) * 100" | sed 's/..$//'`];

            stdout: SplitParser{
                onRead: (data) => {
                    battery.text = `${data}%`
                }
            }
            
            stderr: SplitParser{
                onRead: (data) => {
                    console.log("Battery usage process failed. Removing Component because you prob have no battery... or some other error.");
                    console.log("bat usage error:", data);
                    battery.destroy();
                }
            }
            onExited: (exitCode, exitStatus) => {
                if(exitCode != 0){
                    console.log("error code returned from battery usage process:", exitCode);
                    battery.destroy();
                }
            }
        }
        onTextChanged: parent._update();
    }
    Text{
        id: charging
        text: "hello";
        color: Colour.fg;
        font.family: "Iosevka";
        font.pointSize: 14;
        Timer{
            interval: 5000;
            repeat: true;
            running: true;
            onTriggered: chargingProc.running = true;
        }
        Process{
            id: chargingProc;
            running: true;
            command: ["sh", "-c", "acpi"];
            stdout: SplitParser{
                onRead: data => {
                    var _sections = data.split(" ");
                    var output = "no battery?";
                    for (var i = 0; i < _sections.length; i++){
                        if (_sections[i].includes(":")){
                            output = _sections[i];
                        }
                    }
                    var time = output;
                    charging.text = `${time}`;
                }
            }
            stderr: SplitParser{
                onRead: (data) => {
                    console.log("battery remaining failed... or some other error.");
                    console.log("battery remaining  error:", data);
                    charging.destroy();
                }
            }
            onExited: (exitCode, exitStatus) => {
                if(exitCode != 0){
                    console.log("error code returned from battery remaining process:", exitCode);
                    charging.destroy();
                }
            }
        }
        onTextChanged: parent._update();
    }
}
