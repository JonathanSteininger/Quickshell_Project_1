import Quickshell
import Quickshell.Io
import Quickshell.Widgets;
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import "../Components/"
import Quickshell.Services.UPower

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
        Item{
            height: 40;
            width: 75;
            signal clicked();
            onClicked: GlobalState.popupRight("network", rightPanel.convertPopoutPosition(x, width));
            Item{
                id: uploadBox;
                width: uploadText.width + uploadIcon.width + 5;
                height: childrenRect.height;
                x: parent.width/2 + parent.height/4 - width/2;
                anchors.top: parent.top;
                Text{
                    id: uploadText;
                    anchors.left: parent.left;
                    text: GlobalState.getNetworkingText(GlobalState.kiloBitsTransmittedTotal, true);
                    color: Colour.fg;
                    font.family: "Iosevka";
                    font.pointSize: 12;
                }
                SquaredIcon{
                    id: uploadIcon;
                    anchors.right: parent.right;
                    icon: Icons.network_up;
                    height: 20;
                    iconColor: Colour.fg;
                }
            }
            Item{
                id: downloadBox;
                width: downloadText.width + downloadIcon.width + 5;
                height: childrenRect.height;
                x: parent.width/2 - parent.height/4 - width/2;
                anchors.bottom: parent.bottom;
                Text{
                    id: downloadText;
                    anchors.left: parent.left;
                    text: GlobalState.getNetworkingText(GlobalState.kiloBitsRecivedTotal, true);
                    color: Colour.fg;
                    font.family: "Iosevka";
                    font.pointSize: 12;
                }
                SquaredIcon{
                    id: downloadIcon;
                    icon: Icons.network_down;
                    anchors.right: parent.right;
                    height: 20;
                    onClicked: console.log("brightness");
                    iconColor: Colour.fg;
                }
            }
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
        Item{
            implicitWidth: 65;
            implicitHeight: childrenRect.height;
            signal clicked();
            onClicked: () => {
                GlobalState.popupRight("audio", rightPanel.convertPopoutPosition(x,width));
            }
            signal wheel(wheelEvent: WheelEvent);
            onWheel:(event) => {
                GlobalState.defaultAudio.audio.volume += Math.round(event.angleDelta.y/360 * 0.1 * 1000)/1000;
            }
            RowLayout{
                anchors.centerIn: parent;
                width: childrenRect.width;
                height: childrenRect.height;
                Text{
                    id: volume
                    horizontalAlignment: Text.AlignRight;
                    property real volume: GlobalState.defaultAudio.audio.volume;
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
            }
        },
        Row{
            spacing: 10;
            Text{
                id: battery
                text: GlobalState.battery.percentage;
                color: Colour.fg;
                font.family: "Iosevka";
                font.pointSize: 14;
            }
            SquaredIcon{
                iconRaw: Quickshell.iconPath(GlobalState.battery.mainBattery.iconName);
                height: 24;
                iconColor: Colour.fg;
            }
        }
    ]
}
