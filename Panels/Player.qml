import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQml.Models
import "../Components/" as Components
import Quickshell.Services.Mpris
import Qt5Compat.GraphicalEffects
pragma ComponentBehavior: Bound

Rectangle{
    id: root;
    width: 450;
    height: childrenRect.height;
    MouseArea{
        width: root.width;
        height: root.height;
    }
    component StyledButton: Rectangle{
        width: 70;
        height: 40;
        required property string textColor;
        required property string clickColor;
        required property string boxColor;
        required property bool filled;
        property string activeColor: filled ? boxColor : "#00000000";
        required property string text;
        border.color: mouseBox.containsMouse ? clickColor : boxColor;
        border.width: 2;
        color: mouseBox.containsMouse ? clickColor : activeColor;
        signal clicked();
        radius: 5;
        MouseArea{
            id: mouseBox;
            anchors.fill: parent;
            hoverEnabled: false;
            onClicked:{
                parent.clicked();
            }
        }
        Text{
            anchors.centerIn: parent;
            color: parent.textColor;
            text: parent.text;
        }
    }
    component PlayerTile: Rectangle{
        id: player;
        function formatTime(seconds: real): string{
            var output = "";
            var hours = Math.floor(seconds / (60*60));
            if (hours != 0){
                output = `${hours}:`;
            }
            var minutes = `0${Math.floor(seconds/60)}`.substr(-2);
            var _seconds= `0${Math.floor(seconds%60)}`.substr(-2);
            return `${output}${minutes}:${_seconds}`
        }
        width: root.width;
        required property var model;
        property real padding: 15;
        color: Components.Colour.trans;
        height: container.height + padding*2;
        required property string backgroundColor;
        required property string activeColor;
        required property string textColor;
        required property string boxColor;
        required property string usedBarColor;
        required property string emptyBarColor;
        Rectangle{
            id: container;
            width: player.width - player.padding*2;
            height: childrenRect.height; 
            anchors.centerIn: parent;
            color: Components.Colour.trans;
            ColumnLayout{
                width: parent.width;
                implicitHeight: childrenRect.height;
                Rectangle{
                    id: artWork;
                    implicitWidth: parent.width;
                    implicitHeight: implicitWidth;
                    Layout.fillWidth: true;
                    color: Components.Colour.trans;
                    clip: true;
                    Image{
                        id: artBacking;
                        height: parent.height;
                        width: parent.width;
                        source: player.model.trackArtUrl || "/home/Aureus/Pictures/profile.PNG";
                        fillMode: Image.PreserveAspectCrop;
                        visible: false;
                    }
                    GaussianBlur{
                        anchors.fill: artBacking;
                        source: artBacking;
                        radius: 64;
                        samples: radius*2 + 1;
                        deviation: radius/2;
                        cached: true;
                        layer.enabled: true;
                        layer.effect: OpacityMask{
                            maskSource: clippingMask2;
                        }
                    }
                    Image{
                        height: parent.height;
                        width: parent.width;
                        source: player.model.trackArtUrl || "/home/Aureus/Pictures/profile.PNG";
                        fillMode: Image.PreserveAspectFit;
                        clip: true;
                        layer.enabled: true;
                        layer.effect: OpacityMask{
                            maskSource: clippingMask2;
                        }
                    }
                    Rectangle{
                        id: clippingMask2;
                        anchors.fill: parent;
                        visible: false;
                        radius: 15;
                    }
                }

                Rectangle{
                    id: specialButtons;
                    height: 50;
                    Layout.fillWidth: true;
                    visible: player.model.shuffleSupported || player.model.loopSupported;
                    color: Components.Colour.trans;
                    StyledButton{
                        visible: player.model.shuffleSupported;
                        anchors.verticalCenter: parent.verticalCenter;
                        anchors.right: parent.right;
                        textColor: player.textColor;
                        boxColor: player.boxColor;
                        clickColor: player.activeColor;
                        filled: player.model.shuffle;
                        text: "shuffel";
                        onClicked: () => player.model.shuffle = !player.model.shuffle;
                    }
                    StyledButton{
                        visible: player.model.loopSupported;
                        anchors.left: parent.left;
                        anchors.verticalCenter: parent.verticalCenter;
                        textColor: player.textColor;
                        boxColor: player.boxColor;
                        clickColor: player.activeColor;
                        filled: player.model.loopState != MprisLoopState.None;
                        text: getText();
                        onClicked: () => {
                            cycleLoops();
                        }
                        function cycleLoops(){
                            if(player.model.loopState == MprisLoopState.Playlist){
                                player.model.loopState = MprisLoopState.None;
                                return;
                            }
                            if(player.model.loopState == MprisLoopState.Track){
                                player.model.loopState = MprisLoopState.Playlist;
                                return;
                            }
                            if(player.model.loopState == MprisLoopState.None){
                                player.model.loopState = MprisLoopState.Track;
                                return;
                            }
                        }
                        function getText(){
                            if(player.model.loopState == MprisLoopState.Playlist){
                                return "plist";
                            }
                            if(player.model.loopState == MprisLoopState.Track){
                                return "track";
                            }
                            if(player.model.loopState == MprisLoopState.None){
                                return "None";
                            }
                        }
                    }
                }

                ColumnLayout{
                    id: playerControls;
                    width: parent.width;
                    spacing: 0;
                    Text{
                        color: player.textColor;
                        text: player.model.trackTitle || "Unkown Song Name"
                        Layout.maximumWidth: parent.width;
                        //wrapMode: Text.WordWrap;
                        clip: true;
                    }
                    Text{
                        color: player.textColor;
                        text: player.model.trackArtist || "Unknown Artist"
                        font.pointSize: 10;
                    }
                    Slider{
                        from: 0;
                        value: player.model.position;
                        to: player.model.length;
                        onMoved: {
                            console.log(player.model.length, player.model.position);
                            console.log(from, to);
                            player.model.position = value;
                            //value = player.model.position;
                        }
                    }
                }

                Rectangle{
                    id: volumeControls;
                    height: 50;
                    Layout.fillWidth: true;
                    color: "red";
                }
            }
        }

    }
    color: Components.Colour.trans;
    Rectangle{
        id: playerSelector;
        visible: Components.GlobalState.players.values.length > 1;
        height: 50;
        width: root.width;
        color: "red";
    }
    PlayerTile{
        y: Components.GlobalState.players.values.length > 1 ? playerSelector.height : 0;
        model: Components.GlobalState.activePlayerActual;
        textColor: Components.Colour.fg;
        boxColor: Components.Colour.accent;
        backgroundColor: Components.Colour.trans;
        usedBarColor: Components.Colour.accent;
        emptyBarColor: Components.Colour.accent_dark;
        activeColor: Components.Colour._active;
    }
}
