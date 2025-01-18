import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Shapes
import QtQml.Models
import Quickshell.Services.Mpris
import "../Components/" as Components
import Qt5Compat.GraphicalEffects
pragma ComponentBehavior: Bound

Rectangle{
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
    width: parent.width;
    required property var model;
    property real padding: 0;
    color: Components.Colour.trans;
    height: container.height + padding*2;
    required property string backgroundColor;
    required property string activeColor;
    required property string textColor;
    required property string boxColor;
    required property string usedBarColor;
    required property string emptyBarColor;
    property string backupPicture: `root:Images/no_art.jpg`;
    Rectangle{
        id: container;
        width: player.width - player.padding*2;
        height: childrenRect.height; 
        anchors.centerIn: parent;
        color: Components.Colour.trans;
        Column{
            width: parent.width;
            height: childrenRect.height;
            Rectangle{
                id: artWork;
                height: parent.width;
                width: height;
                Layout.fillWidth: true;
                color: Components.Colour.trans;
                clip: true;
                Image{
                    id: artBacking;
                    height: parent.height;
                    width: parent.width;
                    source: player.model.trackArtUrl || player.backupPicture;
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
                    source: player.model.trackArtUrl || player.backupPicture;
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
                    radius: 3;
                }
            }


            /*
            Rectangle{
                clip: true;
                width: parent.width;
                height: childrenRect.height;
                color: player.backgroundColor;
                Rectangle{
                    height: childrenRect.height;
                    anchors.verticalCenter: volumeBar.verticalCenter;
                    anchors.right: volumeBar.left;
                    color: player.backgroundColor;
                    width: children[0].width + 10;
                    Text{
                        color: player.textColor;
                        font.family: "Iosevka";
                        anchors.centerIn: parent;
                        text: `${Math.floor(player.model.volume*100)}%`;
                    }
                }
                Components.Slider{
                    width: parent.width * 0.80;
                    anchors.horizontalCenter: parent.horizontalCenter;
                    height: 25;
                    visible: player.model.volumeSupported;
                    id: volumeBar;
                    textColor: player.textColor;
                    barColor: player.boxColor;
                    backgroundColor: player.backgroundColor;
                    emptyColor: player.emptyBarColor;
                    overShootColor: Components.Colour._active2;
                    overShootLocation: 1.0;
                    stepSize: 0.05;
                    from: 0.0;
                    value: player.model.volume;
                    to: 1.5;
                    textLeft: "";
                    textRight: "";
                    textPressed: `${Math.floor(value*100)}%`;
                    font: "Iosevka";
                    textSizeBottom: 12;
                    textSizePressed: 10;
                    onMoved: {
                        if(!player.model.volumeSupported){
                            value = player.model.volume;
                            return;
                        }
                        player.model.volume = value;
                    }
                }
                Rectangle{
                    height: childrenRect.height;
                    anchors.verticalCenter: volumeBar.verticalCenter;
                    anchors.left: volumeBar.right;
                    color: player.backgroundColor;
                    width: children[0].width + 10;
                    Text{
                        color: player.textColor;
                        font.family: "Iosevka";
                        anchors.centerIn: parent;
                        text: "150%";
                    }
                }
            }
            */
            ColumnLayout{
                id: playerControls;
                width: parent.width;
                spacing: 0;
                Text{
                    color: player.textColor;
                    text: player.model.trackTitle || "Unkown Song Name"
                    Layout.maximumWidth: parent.width;
                    font.pointSize: 14;
                    font.bold: true;
                    //wrapMode: Text.WordWrap;
                    clip: true;
                }
                Text{
                    color: player.textColor;
                    text: player.model.trackArtist || "Unknown Artist"
                    font.pointSize: 10;
                }
                Rectangle{
                    width: parent.width;
                    color: player.backgroundColor;
                    height: 40;
                    Components.Slider{
                        anchors.bottom: parent.bottom;
                        id: progressBar;
                        textColor: player.textColor;
                        barColor: player.boxColor;
                        width: parent.width;
                        backgroundColor: player.backgroundColor;
                        emptyColor: player.emptyBarColor;
                        overShootColor: player.emptyBarColor;
                        overShootLocation: 1.0;
                        stepSize: 1;
                        from: 0;
                        height: 58;
                        disableBars: true;
                        value: player.model.position;
                        to: player.model.length;
                        textLeft: player.formatTime(player.model.position);
                        textRight: player.formatTime(player.model.length);
                        textPressed: player.formatTime(value);
                        font: "Iosevka";
                        textSizeBottom: 12;
                        textSizePressed: 10;
                        onMoved: {
                            if(!player.model.canSeek){
                                console.log("CANT SEEK");
                                value = player.model.position;
                                return;
                            }
                            player.model.position = value;
                        }
                        //
                        Process{
                            id: mpdSeekProc;
                            property string seekPos: "00:00:00";
                            property string playerLocation: "";
                            running: false;
                            command: ["mpc", "-h", playerLocation, "seek", seekPos];
                            stderr: SplitParser{
                                onRead: (value) => console.log(value);
                            }
                            stdout: SplitParser{
                                onRead: (value) => console.log(value);
                            }
                        }
                    }
                }
            }
            Components.CenterButtonStripLayout{
                height: 50;
                color: Components.Colour.accent;
                borderColor: Components.Colour.bg_solid;
                fillColor: Components.Colour._active;
                borderSize: 2;
                tiltRight: false;
                tiltStrength: 1;
                centerIndex: 2;
                innerChildWidth: parent.width - spacing - height;
                innerChildren: [
                    Components.SquaredIcon{
                        icon: getIcon();
                        function getIcon(){
                            if(player.model.loopState == MprisLoopState.Track){
                                return Components.Icons.repeat_track;
                            }
                            return Components.Icons.repeat;
                        }
                        function nextRepeat(){
                            if(player.model.loopState == MprisLoopState.None){
                                player.model.loopState = MprisLoopState.Track;
                                return;
                            }
                            if(player.model.loopState == MprisLoopState.Track){
                                player.model.loopState = MprisLoopState.Playlist;
                                return;
                            }
                            player.model.loopState = MprisLoopState.None;
                        }
                        Shape{
                            visible: player.model.loopState == MprisLoopState.None;
                            anchors.centerIn: parent;
                            width: parent.width - 10;
                            height: parent.height - 10;
                            id: strikeRepeat;
                            ShapePath{
                                strokeColor: player.textColor;
                                strokeWidth: 2;
                                startX: 0;
                                startY: 0;
                                PathLine{
                                    x: strikeRepeat.width;
                                    y: strikeRepeat.height;
                                }
                            }
                        }
                        onClicked: {
                            nextRepeat();
                        }
                    },
                    Rectangle{
                        Layout.fillWidth: true;
                        Layout.horizontalStretchFactor: 2;
                        height: playButton.height;
                        color: Components.Colour.trans;
                        Components.SquaredIcon{
                            anchors.centerIn: parent;
                            id: prevButton;
                            icon: Components.Icons.prev;
                        }
                        signal clicked();
                        onClicked: {
                            player.model.previous();
                        }
                    },
                    Rectangle{
                        Layout.fillWidth: true;
                        Layout.horizontalStretchFactor: 3;
                        height: playButton.height;
                        color: Components.Colour.trans;
                        Components.SquaredIcon{
                            anchors.centerIn: parent;
                            id: playButton;
                            icon: player.model.isPlaying ? Components.Icons.pause : Components.Icons.play;
                        }
                        signal clicked();
                        onClicked: {
                            player.model.togglePlaying();
                        }
                    },
                    Rectangle{
                        Layout.fillWidth: true;
                        Layout.horizontalStretchFactor: 2;
                        height: playButton.height;
                        color: Components.Colour.trans;
                        Components.SquaredIcon{
                            anchors.centerIn: parent;
                            id: nextButton;
                            icon: Components.Icons.next;
                        }
                        signal clicked();
                        onClicked: {
                            player.model.next();
                        }
                    },
                    Components.SquaredIcon{
                        icon: Components.Icons.shuffle;
                        Shape{
                            visible: !player.model.shuffle;
                            anchors.centerIn: parent;
                            width: parent.width - 10;
                            height: parent.height - 10;
                            id: strikeShuffle;
                            ShapePath{
                                strokeColor: player.textColor;
                                strokeWidth: 2;
                                startX: 0;
                                startY: 0;
                                PathLine{
                                    x: strikeRepeat.width;
                                    y: strikeRepeat.height;
                                }
                            }
                        }
                        onClicked:{
                            player.model.shuffle = !player.model.shuffle;
                        }
                    }
                ]

            }
        }
    }

    Timer{
        running: player.visible;
        repeat: true;
        onTriggered: player.model.positionChanged();
        interval: 1000;
    }
}
