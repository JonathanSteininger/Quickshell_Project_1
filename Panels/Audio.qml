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
    component LineBehavior: Behavior{
        PropertyAnimation{
            duration: 200;
            easing.type: Easing.InOutQuad;
        }
    }
    component SoundTile: Rectangle{
        id: item
        width: frame.width;
        required property PwNodeAudio audioNode;
        height: 100;
        clip: true;
        required property string nodeName;
        required property string nodeTitle;
        required property string nodeId;
        required property var activeColor;
        required property var activeSecondaryColor;
        required property var activeSliderColor;
        required property var activeTextColor;
        required property var activeBackgroundColor;
        required property var fontFamily;
        property bool isDevice: false;
        border.width: 2;
        radius: 2;
        MouseArea{
            anchors.fill: item;
            onClicked:{
                if(item.isDevice){
                    Components.GlobalState.setNodeDefault(item.nodeName, item.nodeId);
                }
            }
        }
        Rectangle{
            property int padding: 5;
            width: parent.width - padding*2;
            height: parent.height - padding*2;
            x: padding;
            y: padding;
            color: Components.Colour.trans;
            Text {
                width: parent.width;
                anchors.top: parent.top;
                anchors.left: parent.left;
                anchors.bottom: slider.top;
                //verticalAlignment: Text.AlignVCenter;
                color: item.activeTextColor;
                font.family: item.fontFamily;
                font.pointSize: 12;
                wrapMode: Text.WordWrap;
                text: item.nodeTitle;
            }
            Rectangle{
                implicitWidth: 30;
                implicitHeight: 20;
                radius: 5;
                y: slider.y - height;
                x: slider.handle.x - slider.handle.width/2;
                color: item.activeBackgroundColor;
                visible: slider.pressed;
                Text {
                    anchors.centerIn: parent;
                    font.pointSize: 10;
                    color: item.activeTextColor;
                    font.family: item.fontFamily;
                    text: `${Math.round(audioNode.volume * 1000)/10}%`;
                }
            }
            Slider{
                id: slider;
                width: parent.width;
                from: 0;
                value: audioNode.volume;
                anchors.verticalCenter: parent.verticalCenter;
                anchors.horizontalCenter: parent.horizontalCenter;
                to: 1.5;
                snapMode: Slider.SnapAlways;
                stepSize: 0.05;
                onMoved: {
                    audioNode.volume = value;
                }
                background: Rectangle{
                    x: slider.leftPaddingChanged;
                    y: slider.topPadding + slider.availableHeight /2 - height /2;
                    implicitHeight: 5;
                    implicitWidth: 200;
                    width: slider.availableWidth;
                    height: slider.availableHeight;
                    radius: 5;
                    color: Components.Colour.trans;
                    Rectangle{
                        height: parent.height;
                        width: parent.width /3 * 2;
                        x: 0;
                        color: item.activeSliderColor;
                        bottomLeftRadius: parent.radius;
                        topLeftRadius: parent.radius;
                    }
                    Rectangle{
                        height: parent.height;
                        property real shift: 0.2;
                        width: parent.width /3 * (1 + shift) - slider.handle.width/2;
                        x: parent.width /3 * (2 - shift) + slider.handle.width/2;
                        gradient: Gradient{
                            orientation: Gradient.Horizontal;
                            GradientStop{ position: 0.0; color: item.activeSliderColor}
                            GradientStop{ position: 0.4; color: item.activeSecondaryColor}
                            GradientStop{ position: 1.0; color: item.activeSecondaryColor}
                        }
                        bottomRightRadius: parent.radius;
                        topRightRadius: parent.radius;
                    }
                    Rectangle{
                        height: parent.height;
                        width: slider.handle.x + slider.handle.width/2;
                        x: 0;
                        color: item.activeColor;
                        bottomLeftRadius: parent.radius;
                        topLeftRadius: parent.radius;
                    }
                    Rectangle{
                        height: parent.height;
                        width: parent.width;
                        x: 0;
                        border.width: 1;
                        border.color: item.activeColor;
                        color: Components.Colour.trans;
                        radius: parent.radius;
                    }
                    Repeater{
                        id: lines;
                        property int steps: (slider.to - slider.from) / slider.stepSize;
                        model: steps + 1;
                        Rectangle{
                            required property int index;
                            property int extra: index % Math.round(lines.steps/3*2) == 0? 3 : 0;
                            property int selectedExtra: 5;
                            width: 2;
                            implicitHeight: index % 5 == 0 ? 8: 5;
                            height: (Math.round(lines.steps*slider.position) == index ? implicitHeight + selectedExtra : implicitHeight) + extra;
                            color: Math.round(lines.steps*slider.position) >= index ? item.activeColor : item.activeSecondaryColor;
                            LineBehavior on color{}
                            LineBehavior on height{}
                            x: (parent.width - slider.handle.width) / lines.steps * index + slider.handle.width/2;
                            y: parent.y + parent.height + 3;
                        }
                    }

                }
                handle: Rectangle{
                    implicitWidth: 10;
                    implicitHeight: 10;
                    color: item.activeColor;
                    border.width: 1;
                    border.color: item.activeSliderColor;
                    height: implicitHeight + 4;
                    width: implicitWidth + 4;
                    anchors.verticalCenter: slider.verticalCenter;
                    radius: 10;
                    x: (slider.width - width) * slider.position + 0.5;

                }
            }

            Text {
                anchors.bottom: parent.bottom;
                color: item.activeTextColor;
                font.family: item.fontFamily;
                text: `${Math.round(audioNode.volume * 1000)/10}%`;
            }
            Rectangle{
                width: 50;
                height: 24;
                color: item.audioNode != null ? (item.audioNode.muted ? item.activeColor : item.activeBackgroundColor) : item.activeBackgroundColor;
                border.width: 1;
                border.color: item.activeColor;
                radius: 3;
                anchors.bottom: parent.bottom;
                anchors.right: parent.right;
                Behavior on color{
                    ColorAnimation {
                        duration: 100;
                    }
                }
                MouseArea{
                    anchors.fill: parent;
                    hoverEnabled: true;
                    onClicked: {
                        item.audioNode.muted = !item.audioNode.muted;
                    }
                }
                Text{
                    anchors.centerIn: parent;
                    color: item.activeTextColor;
                    font.family: item.fontFamily;
                    text: "Mute";
                }
            }
        }
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
        //Applications
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
                width: childrenRect.width;
                height: childrenRect.height;
                color: Components.Colour.trans;

                SoundTile{
                    width: frame.width;
                    audioNode: audio;
                    nodeName: name;
                    nodeId: id;
                    nodeTitle: nodeName;
                    height: 100;
                    clip: true;
                    activeColor: Components.Colour.accent;
                    activeSecondaryColor: Components.Colour._active2;
                    activeSliderColor: Components.Colour.accent_dark;
                    activeTextColor: Components.Colour.fg;
                    activeBackgroundColor: Components.Colour.bg;
                    fontFamily: "Iosevka";
                    border.color: activeColor;
                    border.width: 2;
                    color: Components.Colour.trans;
                    radius: 2;
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
                    if(!entry.model.isSink && entry.model.audio && entry.model.isStream && entry.model.audio != null) {  
                        entry.inOutputDevice = true;
                    }  
                }
            }
        }
        //Devices
        DelegateModel{
            id: sinkModel;
            model: Pipewire.nodes.values;
            groups: [
                DelegateModelGroup {
                    id: outputItems;
                    includeByDefault: false;
                    name: "outputDevice" ;
                }
            ]

            filterOnGroup: "outputDevice";
            delegate: Rectangle{
                width: childrenRect.width;
                height: childrenRect.height;
                color: Components.Colour.trans;

                SoundTile{
                    width: frame.width;
                    audioNode: audio;
                    nodeName: name;
                    nodeId: id;
                    nodeTitle: description;
                    isDevice: true;
                    height: 100;
                    clip: true;
                    activeColor: Components.GlobalState.defaultAudio != null ? (Components.GlobalState.defaultAudio.id == nodeId ? Components.Colour._active : Components.Colour.accent) : "white";
                    activeSecondaryColor: Components.GlobalState.defaultAudio != null ? (Components.GlobalState.defaultAudio.id == nodeId ? Components.Colour._active3 : Components.Colour._active2) : "white";
                    activeSliderColor: Components.GlobalState.defaultAudio != null ? (Components.GlobalState.defaultAudio.id == nodeId ? Components.Colour.selectedDark : Components.Colour.accent_dark) : "white";
                    activeTextColor: Components.Colour.fg;
                    activeBackgroundColor: Components.Colour.bg;
                    fontFamily: "Iosevka";
                    border.color: activeColor;
                    border.width: 2;
                    color: Components.Colour.trans;
                    radius: 2;
                }
            }
            items.onChanged: {
                filter();
            }
            Component.onCompleted:{
                filter();
            }
            property var lessThan: function(left, right) { return left < right; }
            function filter(){
                /*
                if(items.count > 0){
                    items.setGroups(0, items.count, "items");
                }
                */
                var list = [];
                for( var i = 0; i < items.count;i++ ) {  
                    var entry = items.get(i);  
                    if(entry.model.isSink && !entry.model.isStream) {  
                        list.push(entry);
                    }  
                }
                // Step 2: Sort the list of visible items
                list.sort(function(a, b) {
                    return lessThan(a.model.description, b.model.description) ? -1 : 1;
                });

                for(var i = 0; i < list.length; ++i) {
                    entry = list[i];
                    entry.inOutputDevice = true;
                    if (entry.outputDeviceIndex !== i) {
                        outputItems.move(entry.outputDeviceIndex, i, 1);
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
