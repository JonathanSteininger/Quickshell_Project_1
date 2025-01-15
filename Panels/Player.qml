import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Shapes
import QtQml.Models
import "../Components/" as Components
import Quickshell.Services.Mpris
import Qt5Compat.GraphicalEffects
pragma ComponentBehavior: Bound

Rectangle{
    id: root;
    width: 450;
    height: playerSelector.enabled ? playerTile.height + playerSelector.height : playerTile.height;
    MouseArea{
        width: root.width;
        height: root.height;
    }
    component LineBehavior: Behavior{
        PropertyAnimation{
            duration: 200;
            easing.type: Easing.InOutQuad;
        }
    }
    component ButtonBehavior: Behavior{
        PropertyAnimation{
            duration: 100;
            easing.type: Easing.InOutQuad;
        }
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
        property alias hoverEnabled: mouseBox.hoverEnabled;
        property string fontFamily: "Iosevka";
        border.color: mouseBox.containsMouse ? clickColor : boxColor;
        border.width: 2;
        color: activeColor;
        //color: mouseBox.containsMouse ? clickColor : activeColor;
        ButtonBehavior on color{}
        ButtonBehavior on border.color{}
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
                        hoverEnabled: true;
                        text: "";
                        Components.SquaredIcon{
                            anchors.centerIn: parent;
                            icon: Components.Icons.shuffle;
                            Shape{
                                visible: !player.model.shuffle;
                                id: shuffleSlash;
                                anchors.centerIn: parent;
                                width: parent.width - 10;
                                height: parent.height - 10;
                                ShapePath{
                                    strokeWidth: 2;
                                    strokeColor: player.textColor;
                                    startX: 0;
                                    startY: 0;
                                    PathLine{
                                        x: shuffleSlash.width;
                                        y: shuffleSlash.height;
                                    }
                                }
                            }
                        }
                        onClicked: () => player.model.shuffle = !player.model.shuffle;
                    }
                    StyledButton{
                        id: repeatButton;
                        visible: player.model.loopSupported;
                        anchors.left: parent.left;
                        anchors.verticalCenter: parent.verticalCenter;
                        textColor: player.textColor;
                        boxColor: player.boxColor;
                        clickColor: player.activeColor;
                        filled: player.model.loopState != MprisLoopState.None;
                        hoverEnabled: true;
                        text: "";
                        Components.SquaredIcon{
                            id: repeatIcon;
                            icon: parent.getIcon();
                            anchors.centerIn: parent;
                            Shape{
                                visible: player.model.loopState == MprisLoopState.None;
                                id: repeatSlash;
                                anchors.centerIn: parent;
                                width: parent.width - 10;
                                height: parent.height - 10;
                                ShapePath{
                                    strokeWidth: 2;
                                    strokeColor: player.textColor;
                                    startX: 0;
                                    startY: 0;
                                    PathLine{
                                        x: repeatSlash.width;
                                        y: repeatSlash.height;
                                    }
                                }
                            }
                        }
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
                        function getIcon(){
                            if(player.model.loopState == MprisLoopState.Playlist){
                                return Components.Icons.repeat;
                            }
                            if(player.model.loopState == MprisLoopState.Track){
                                return Components.Icons.repeat_track;
                            }
                            if(player.model.loopState == MprisLoopState.None){
                                return Components.Icons.repeat;
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
                    Components.Slider{
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
                        //Components.
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
                    Rectangle{
                        id: controls;
                        color: Components.Colour.trans;
                        property real padding: 0;
                        width: parent.width;
                        height: controlRow.height + padding*2;
                        RowLayout{
                            id: controlRow;
                            anchors.centerIn: controls;
                            Components.SquaredIcon{
                                icon: Components.Icons.prev;
                                iconColor: prevMouseArea.hovered ? player.activeColor : player.boxColor;
                                Behavior on iconColor{
                                    ColorAnimation{
                                        duration: 50;
                                    }
                                }
                                height: 96;
                                Shape{
                                    anchors.centerIn: parent;
                                    width: parent.width - 20;
                                    height: width;
                                    id: prevShapeMask;
                                    visible: true;
                                    containsMode: Shape.FillContains;
                                    ShapePath{
                                        strokeColor: "blue";
                                        fillColor: "#00000000";
                                        strokeWidth: 0;
                                        startX: prevShapeMask.width/2;
                                        startY: 0;
                                        PathArc{
                                            x: prevShapeMask.width/2;
                                            y: prevShapeMask.height;
                                            radiusX: prevShapeMask.width/2;
                                            radiusY: prevShapeMask.height/2;
                                            useLargeArc: true;
                                        }
                                        PathArc{
                                            x: prevShapeMask.width/2;
                                            y: 0;
                                            radiusX: prevShapeMask.width/2;
                                            radiusY: prevShapeMask.height/2;
                                            useLargeArc: true;
                                        }
                                    }
                                    MouseArea{
                                        id: prevMouseArea;
                                        anchors.fill: parent;
                                        property bool hovered: false;
                                        hoverEnabled: true;
                                        onExited:{
                                            hovered = false;
                                        }
                                        onPositionChanged:{
                                            hovered = parent.contains(Qt.point(mouseX, mouseY));
                                        }
                                    }
                                }
                            }
                            Components.SquaredIcon{
                                icon: player.model.isPlaying ? Components.Icons.pause : Components.Icons.play;
                                iconColor: playMouseArea.hovered ? player.activeColor : player.boxColor;
                                Behavior on iconColor{
                                    ColorAnimation{
                                        duration: 50;
                                    }
                                }
                                height: 128;
                                Shape{
                                    anchors.centerIn: parent;
                                    width: parent.width - 26;
                                    height: width;
                                    id: playShapeMask;
                                    visible: true;
                                    containsMode: Shape.FillContains;
                                    ShapePath{
                                        strokeColor: "blue";
                                        fillColor: "#00000000";
                                        strokeWidth: 0;
                                        startX: playShapeMask.width/2;
                                        startY: 0;
                                        PathArc{
                                            x: playShapeMask.width/2;
                                            y: playShapeMask.height;
                                            radiusX: playShapeMask.width/2;
                                            radiusY: playShapeMask.height/2;
                                            useLargeArc: true;
                                        }
                                        PathArc{
                                            x: playShapeMask.width/2;
                                            y: 0;
                                            radiusX: playShapeMask.width/2;
                                            radiusY: playShapeMask.height/2;
                                            useLargeArc: true;
                                        }
                                    }
                                    MouseArea{
                                        id: playMouseArea;
                                        anchors.fill: parent;
                                        property bool hovered: false;
                                        hoverEnabled: true;
                                        onExited:{
                                            hovered = false;
                                        }
                                        onPositionChanged:{
                                            hovered = parent.contains(Qt.point(mouseX, mouseY));
                                        }
                                        onClicked: {
                                            console.log("hi");
                                            if(parent.contains(Qt.point(mouseX, mouseY))){
                                                if(player.model.isPlaying){
                                                    player.model.pause();
                                                }else{
                                                    player.model.play();
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            Components.SquaredIcon{
                                icon: Components.Icons.next;
                                iconColor: nextMouseHover.hovered ? player.activeColor : player.boxColor;
                                Behavior on iconColor{
                                    ColorAnimation{
                                        duration: 50;
                                    }
                                }
                                height: 96;
                                Shape{
                                    anchors.centerIn: parent;
                                    width: parent.width - 20;
                                    height: width;
                                    id: nextShapeMask;
                                    visible: true;
                                    containsMode: Shape.FillContains;
                                    ShapePath{
                                        strokeColor: "blue";
                                        fillColor: "#00000000";
                                        strokeWidth: 0;
                                        startX: nextShapeMask.width/2;
                                        startY: 0;
                                        PathArc{
                                            x: nextShapeMask.width/2;
                                            y: nextShapeMask.height;
                                            radiusX: nextShapeMask.width/2;
                                            radiusY: nextShapeMask.height/2;
                                            useLargeArc: true;
                                        }
                                        PathArc{
                                            x: nextShapeMask.width/2;
                                            y: 0;
                                            radiusX: nextShapeMask.width/2;
                                            radiusY: nextShapeMask.height/2;
                                            useLargeArc: true;
                                        }
                                    }
                                    MouseArea{
                                        id: nextMouseHover;
                                        anchors.fill: parent;
                                        property bool hovered: false;
                                        hoverEnabled: true;
                                        onExited:{
                                            hovered = false;
                                        }
                                        onPositionChanged:{
                                            hovered = parent.contains(Qt.point(mouseX, mouseY));
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                Components.Slider{
                    width: parent.width * 0.8;
                    Layout.alignment: Qt.AlignCenter;
                    height: 50;
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
                    textLeft: player.model.volume;
                    textRight: "";
                    textPressed: value;
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
            }
            Timer{
                running: player.visible;
                repeat: true;
                onTriggered: player.model.positionChanged();
                interval: 1000;
            }
        }

    }
    color: Components.Colour.trans;
    Rectangle{
        id: playerSelector;
        //visible: Components.GlobalState.players.values.length > 1;
        height: Components.GlobalState.players.values.length > 1 ? 50 : 0;
        clip: true;
        LineBehavior on height{}
        width: root.width * 0.8;
        anchors.horizontalCenter: parent.horizontalCenter;
        color: Components.Colour.trans;
        StyledButton{
            id: prevPlayerButton;
            filled: false;
            hoverEnabled: true;
            anchors.verticalCenter: parent.verticalCenter;
            textColor: Components.Colour.fg;
            boxColor: Components.Colour.accent;
            clickColor: Components.Colour._active;
            width: 80;
            height: 40;
            text: "Prev"
            onClicked:{
                Components.GlobalState.previousPlayer();
            }
        }
        Rectangle{
            id: repeaterThing;
            property int amount: Components.GlobalState.players.values.length;
            anchors.left: prevPlayerButton.right;
            anchors.right: nextPlayerButton.left;
            height: parent.height;
            color: Components.Colour.trans;
            Repeater{
                model: repeaterThing.amount;
                Rectangle{
                    required property int index;
                    Layout.alignment: Qt.AlignCenter;
                    anchors.verticalCenter: repeaterThing.verticalCenter;
                    property real tempWidth:index == Components.GlobalState.activePlayer ? 5 : 15; 
                    x: repeaterThing.width / repeaterThing.amount * index + (repeaterThing.width / repeaterThing.amount)/2 - tempWidth/2;
                    height: index == Components.GlobalState.activePlayer ? 40 : 15;
                    width: tempWidth;
                    radius: 100;
                    color: index != Components.GlobalState.activePlayer ? Components.Colour.accent : Components.Colour._active;
                    LineBehavior on height{}
                    LineBehavior on width{}
                    LineBehavior on x{}
                    LineBehavior on color{}
                }
            }
        }
        StyledButton{
            id: nextPlayerButton;
            filled: false;
            hoverEnabled: true;
            anchors.right: parent.right;
            anchors.verticalCenter: parent.verticalCenter;
            textColor: Components.Colour.fg;
            boxColor: Components.Colour.accent;
            clickColor: Components.Colour._active;
            width: 80;
            height: 40;
            text: "Next"
            onClicked:{
                Components.GlobalState.nextPlayer();
            }
        }
    }
    PlayerTile{
        id: playerTile;
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
