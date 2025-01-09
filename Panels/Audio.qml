import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQml.Models
import "../Components/" as Components
import Quickshell.Services.Pipewire

Rectangle{
    id: root;
    color: Components.Colour.trans;
    width: 300;
    property real manualGap: 8;
    height: frame.height + manualGap * 2;
    property real maxHeight: 800;
    property PwObjectTracker tracker: Components.GlobalState.tracker;
    clip: false
    MouseArea{
        width: root.width;
        height: root.height;
    }
    Rectangle{
        id: frame;
        x: root.manualGap;
        y: root.manualGap;
        clip: true;
        color: Components.Colour.trans;
        width: root.width - root.manualGap*2;
        //anchors.fill: parent;
        height: Math.min(column.height, root.maxHeight);
        DelegateModel{
            id: streamModel;
            model: Pipewire.nodes.values;
            groups: [
                DelegateModelGroup {
                    includeByDefault: false;
                    name: "outputDevice" }
            ]
            filterOnGroup: "outputDevice";
            delegate: Rectangle{
                id: item
                property PwNodeAudio audioNode: audio;
                width: frame.width;
                height: 50;
                border.color: Components.Colour.accent;
                border.width: 1;
                clip: true;
                color: Components.Colour.trans;
                Text {
                    anchors.top: parent.top;
                    color: Components.Colour.fg;
                    text: name;
                }
                Slider{
                    anchors.verticalCenter: parent.verticalCenter;
                    from: 0;
                    value: audioNode.volume;
                    to: 1.5;
                    snapMode: Slider.SnapAlways;
                    stepSize: 0.025;
                    onMoved: {
                        audioNode.volume = value;
                    }
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter;
                    anchors.right: parent.right;
                    color: Components.Colour.fg;
                    text: id;
                }
                Text {
                    anchors.bottom: parent.bottom;
                    color: Components.Colour.fg;
                    text: `${Math.round(audio.volume * 1000)/10}%`;
                }
            }
            items.onChanged: {
                filter();
            }
            Component.onCompleted:{
                filter();
            }

            function filter(){
                for( var i = 0; i < items.count;i++ ) {  
                    var entry = items.get(i);  
                    if(entry.model.audio && entry.model.isStream) {  
                        entry.inOutputDevice = true;
                    }  
                }
            }
        }
        DelegateModel{
            id: sinkModel;
            model: Pipewire.nodes.values;
            groups: [
                DelegateModelGroup {
                    includeByDefault: false;
                    name: "outputDevice" }
            ]

            filterOnGroup: "outputDevice";
            delegate: Rectangle{
                id: item2
                width: frame.width;
                property PwNodeAudio audioNode: audio;
                height: 50;
                clip: true;
                border.color: Components.Colour.accent;
                border.width: 1;
                color: Components.GlobalState.defaultAudio.id == id ? Components.Colour.accent : Components.Colour.trans;
                Text {
                    anchors.top: parent.top;
                    color: Components.Colour.fg;
                    text: description;
                }
                Slider{
                    from: 0;
                    value: audioNode.volume;
                    anchors.verticalCenter: parent.verticalCenter;
                    to: 1.5;
                    snapMode: Slider.SnapAlways;
                    stepSize: 0.025;
                    onMoved: {
                        audioNode.volume = value;
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter;
                    color: Components.Colour.fg;
                    text: nickname;
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter;
                    anchors.right: parent.right;
                    color: Components.Colour.fg;
                    text: id;
                }
                Text {
                    anchors.bottom: parent.bottom;
                    color: Components.Colour.fg;
                    text: `${Math.round(audio.volume * 1000)/10}%`;
                }
            }
            items.onChanged: {
                filter();
            }
            Component.onCompleted:{
                filter();
            }

            function filter(){
                for( var i = 0; i < items.count;i++ ) {  
                    var entry = items.get(i);  
                    if(entry.model.isSink && !entry.model.isStream) {  
                        entry.inOutputDevice = true;
                    }  
                }
            }
        }

        ColumnLayout{
            id: column;
            spacing: 5;
            height: Math.min(implicitHeight, root.maxHeight);
            Repeater{
                model: sinkModel;
            }
            Rectangle{
                id: splitter;
                color: Components.Colour.trans;
                width: frame.width;
                height: 40;
                Rectangle{
                    anchors.verticalCenter: parent.verticalCenter;
                    width: frame.width;
                    height: 2;
                    color: Components.Colour.accent;
                }
            }
            Flickable{
                id: flickable
                width: frame.width;
                clip: true;
                implicitHeight: Math.min(root.maxHeight-10 - y, list.height);
                contentWidth: frame.width;
                contentHeight: list.height;
                boundsMovement: Flickable.StopAtBounds;
                boundsBehavior: Flickable.FollowBoundsBehavior;
                ListView{
                    id: list
                    height: childrenRect.height; 
                    spacing: 5;
                    model: streamModel;
                }
            }
        }
    }
    Rectangle{
        width: 3;
        y: flickable.visibleArea.yPosition * flickable.height + flickable.y + root.manualGap;
        anchors.right: root.right;
        radius: 5;
        color: Components.Colour.accent;
        visible: height < flickable.height;
        height: flickable.visibleArea.heightRatio * flickable.height;
    }
}
