import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Widgets
import QtQml
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
	//can set default icons for specific audio outputs
	property var iconMap: {
		"M Series Headphone + Monitor Out": Components.Icons.headphones,
		"Built-in Audio Analog Stereo": Components.Icons.speaker,
		"Vega 20 HDMI Audio [Radeon VII] Digital Stereo (HDMI)": Components.Icons.display,
	}
	function getIcon(name:string):string{
		//var index = root.iconMap.findIndex((child) => child.key.includes(name))
		var icon = iconMap[name];
		if (icon == undefined){
			return Components.Icons.speaker_unknown;
		}
		return icon;
	}
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
		property var icon: Components.Icons.speaker_unknown;
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
			Components.SquaredIcon{
				id: icon;
				icon: item.icon;
				height: 32;
			}
			Text {
				anchors.top: parent.top;
				width: parent.width - icon.width;
				anchors.left: icon.right;
				anchors.bottom: slider.top;
				//verticalAlignment: Text.AlignVCenter;
				color: item.activeTextColor;
				font.family: item.fontFamily;
				font.pointSize: 12;
				wrapMode: Text.WordWrap;
				text: item.nodeTitle;
			}
			Components.Slider{
				id: slider;
				textColor: item.activeTextColor;
				barColor: item.activeColor;
				width: parent.width;
				anchors.verticalCenter: parent.verticalCenter;
				anchors.horizontalCenter: parent.horizontalCenter;
				backgroundColor: item.activeBackgroundColor;
				emptyColor: item.activeSliderColor;
				overShootColor: item.activeSecondaryColor;
				overShootLocation: 1.0;
				stepSize: 0.05;
				value: item.audioNode.volume;
				from: 0;
				to: 1.5;
				textLeft: `${Math.round(item.audioNode.volume * 1000)/10}%`;
				textRight: "";
				textPressed: `${Math.round(value * 1000)/10}%`;
				font: "Iosevka";
				textSizeBottom: 12;
				textSizePressed: 10;
				onMoved: {
					item.audioNode.volume = value;
				}
			}
			Rectangle{
				height: 28;
				width: 40;
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
				Components.SquaredIcon{
					anchors.centerIn: parent;
					icon: Components.Icons.volume_mute;
					height: 20;
					iconColor: item.audioNode.muted ? item.activeSliderColor : item.activeTextColor;
					Behavior on iconColor{
						ColorAnimation {
							duration: 100;
						}
					}
				}
			}
			ColumnLayout{
				width: parent.width;
				Repeater{
					model: item.audioNode.channels.length;
					delegate: Rectangle{
						color: "transparent";
						width: parent.width;
						height: childrenRect.height;
						required property int index;
						Text{
							text: `${parent.index} ${Math.floor(100*item.audioNode.volumes[parent.index])} ${item.audioNode.channels[parent.index]}`;
							color: "white";
						}
						Components.Slider{
							textColor: item.activeTextColor;
							barColor: item.activeColor;
							width: parent.width;
							anchors.verticalCenter: parent.verticalCenter;
							anchors.horizontalCenter: parent.horizontalCenter;
							backgroundColor: item.activeBackgroundColor;
							emptyColor: item.activeSliderColor;
							overShootColor: item.activeSecondaryColor;
							overShootLocation: 1.0;
							stepSize: 0.05;
							value: item.audioNode.volumes[parent.index];
							from: 0;
							to: 1.5;
							textLeft: `${Math.round(item.audioNode.volume * 1000)/10}%`;
							textRight: "";
							textPressed: `${Math.round(value * 1000)/10}%`;
							font: "Iosevka";
							textSizeBottom: 12;
							textSizePressed: 10;
							onMoved: {
								item.audioNode.volumes[parent.index] = value;
							}
						}
					}
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
                    height: 180;
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
                    height: 180;
                    clip: true;
                    icon: root.getIcon(description);
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
