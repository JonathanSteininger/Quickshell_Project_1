import Quickshell
import Quickshell.Io
import Quickshell.Widgets;
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import "../Components/"

ButtonStrip{
    id: rightPanel;
    anchors.right: parent.right;
    borderColor: Colour.accent;
    borderSize: 1;
    color: Colour.bg;
    tiltRight: true;
    tiltStrength: 1
    implicitHeight: 50;

    function convertPopoutPosition(_x, _width){
        //+15 because thats the corner size of the popout.
        return width - (_x + _width + spacing + 15);
    }
    innerChildren: [
        SquaredIcon{
            icon: Icons.brightness;
            onClicked: GlobalState.popupRight("brightness", rightPanel.convertPopoutPosition(x, width));
            iconColor: Colour.fg;
        },
        SquaredIcon{
            icon: Icons.network_up;
            onClicked: console.log("brightness");
            iconColor: Colour.fg;
        },
        SquaredIcon{
            icon: Icons.network_down;
            onClicked: console.log("brightness");
            iconColor: Colour.fg;
        },
        SquaredIcon{
            icon: Icons.temp;
            onClicked: console.log("brightness");
            iconColor: Colour.fg;
        },
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
                    sourceSize: Qt.size(width*8,height*8)
                    width: 30;
                    height: 30;
                    visible: false;
                }
                color: Colour.trans;
                signal clicked();
                onClicked: () => modelData.activate();
                signal rightClicked();
                onRightClicked: {
                    if(modelData.menu == null){
                        return;
                    }
                    console.log(modelData.menu);
                    GlobalState.activeSysTrayMenu = modelData.menu;
                    GlobalState.popupRight("tray_menu", rightPanel.convertPopoutPosition(x,width));
                }
                MultiEffect{
                    anchors.fill: image;
                    source: image;
                    colorizationColor: Colour.fg;
                    colorization: 1.0;
                }
            }
        },
        RowLayout{
            width: childrenRect.width;
            height: childrenRect.height;
            signal clicked();
            onClicked: () => {
                GlobalState.popupRight("audio", rightPanel.convertPopoutPosition(x,width));
            }
            signal wheel(wheelEvent: WheelEvent);
            onWheel:(event) => {
                GlobalState.defaultAudio.audio.volume += Math.round(event.angleDelta.y/360 * 0.1 * 1000)/1000;
            }
            Text{
                id: volume
                horizontalAlignment: Text.AlignRight;
                property real volume: GlobalState.defaultAudio.audio.volume;
                Layout.preferredWidth: 40;
                text: `${Math.floor(this.volume*100)}%`;
                color: Colour.fg;
                font.family: "Iosevka";
                font.pointSize: 14;
            }
            SquaredIcon{
                icon: getIcon();
                height: 24;
                iconColor: Colour.fg;
                function getIcon(){
                    if(GlobalState.defaultAudio == null){
                        return Icons.volume_mute
                    }
                    var audio = GlobalState.defaultAudio.audio;
                    if(audio.muted){
                        return Icons.volume_mute;
                    }
                    if(audio.volume >= 0.7){
                        return Icons.volume_high;
                    }
                    if(audio.volume < 0.7 && audio.volume >= 0.1){
                        return Icons.volume_low;
                    }
                    return Icons.volume_x;
                }

            }
        },
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
        },
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
        }
    ]
}
