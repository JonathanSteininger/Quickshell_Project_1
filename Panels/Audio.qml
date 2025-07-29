import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Widgets
import QtQml
import QtQml.Models
import "../Components/" as Components
import Quickshell.Services.Pipewire

Item{
	id: root;
	width: 300;
	property real manualGap: 8;
	height: frame.height + manualGap * 2;
	property real maxHeight: 800;
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
    readonly property PwObjectTracker outputTracker: PwObjectTracker{
        objects: Components.GlobalState.outputNodes;
    }
    readonly property PwObjectTracker inputTracker: PwObjectTracker{
        objects: Components.GlobalState.inputNodes;
    }
    readonly property PwObjectTracker applicationTracker: PwObjectTracker{
        objects: Components.GlobalState.applicationOutputNodes;
    }
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
		height: childrenRect.height;
		clip: true;
		required property PwNode node;
		property PwNodeAudio audioNode: node.audio;
		property string nodeName: node.name;
		property string nodeTitle: node.description;
		property string nodeId: node.id;
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
					Pipewire.preferredDefaultAudioSink = item.node;
				}
			}
		}
		Rectangle{
			property int padding: 5;
			width: parent.width - padding*2;
			height: childrenRect.height;
			x: padding;
			y: padding;
			color: Components.Colour.trans;
			
			ColumnLayout{
				spacing: 0;
				width: parent.width;
				//text section
				Item{
					Layout.fillWidth: true;
					implicitHeight: childrenRect.height;
					Components.SquaredIcon{
						anchors.left: parent.left;
						id: icon;
						icon: item.icon;
						height: 32;
					}
					Text {
						id: cardName;
						anchors.right: parent.right;
						width: parent.width - icon.width;
						color: item.activeTextColor;
						font.family: item.fontFamily;
						font.pointSize: 12;
						wrapMode: Text.WordWrap;
						text: item.nodeTitle;
					}
				}
				// main slidder section
				Item{
					Layout.fillWidth: true;
					height: childrenRect.height;
					Components.Slider{
						id: slider;
						textColor: item.activeTextColor;
						barColor: item.activeColor;
						width: parent.width;
						anchors.top: parent.top;
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
						anchors.top: slider.bottom;
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
				}
				//balance section
				Repeater{
					model: item.audioNode.channels.length;
					delegate: RowLayout{
						id: channelRoot;
						Layout.preferredHeight: childrenRect.height + 10;
						layoutDirection: Qt.LeftToRight;
						Layout.fillWidth: true;
						required property int index;
						Item{
							Layout.preferredWidth: 40;
							height: childrenRect.height;
							Column{
								Text{
									text: `${PwAudioChannel.toString(item.audioNode.channels[channelRoot.index])}`;
									font.family: "Iosevka";
									color: item.activeTextColor;
								}
								Text{
									text: `${Math.round(item.audioNode.volumes[channelRoot.index] * 1000)/10}%`;
									font.family: "Iosevka";
									color: item.activeTextColor;
								}
							}
						}
						Components.Slider{
							textColor: item.activeTextColor;
							barColor: item.activeColor;
							Layout.fillWidth: true;
							Layout.alignment: Qt.AlignBottom;
							backgroundColor: item.activeBackgroundColor;
							emptyColor: item.activeSliderColor;
							overShootColor: item.activeSecondaryColor;
							overShootLocation: 1.0;
							stepSize: 0.05;
							value: item.audioNode.volumes[channelRoot.index];
							from: 0;
							to: 1.5;
							textLeft: "";
							textRight: "";
							textPressed: `${Math.round(value * 1000)/10}%`;
							font: "Iosevka";
							textSizeBottom: 12;
							textSizePressed: 10;
							onMoved: {
								item.audioNode.volumes[channelRoot.index] = value;
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
        //Devices

        ColumnLayout{
            id: column;
            spacing: 5;
            height: Math.min(implicitHeight, root.maxHeight);
            Repeater{
                model: ScriptModel{ 
                    values: Components.GlobalState.outputNodes;
                }
                delegate: Rectangle{
                    required property var modelData;
                    width: childrenRect.width;
                    height: childrenRect.height;
                    color: Components.Colour.trans;
                    SoundTile{
                        width: frame.width;
                        node: parent.modelData;
                        height: 180;
                        clip: true;
                        isDevice: true;
                        icon: root.getIcon(node.description);
                        activeColor: Components.GlobalState.defaultAudio == node ? Components.Colour._active : Components.Colour.accent;
                        activeSecondaryColor: Components.GlobalState.defaultAudio == node ? Components.Colour._active3 : Components.Colour._active2;
                        activeSliderColor: Components.GlobalState.defaultAudio == node ? Components.Colour.selectedDark : Components.Colour.accent_dark;
                        activeTextColor: Components.Colour.fg;
                        activeBackgroundColor: Components.Colour.bg;
                        fontFamily: "Iosevka";
                        border.color: activeColor;
                        border.width: 2;
                        color: Components.Colour.trans;
                        radius: 2;
                    }
                }
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
                    model: ScriptModel{
                        values: Components.GlobalState.applicationOutputNodes;
                    }
                    delegate: Rectangle{
                        required property var modelData;
                        width: childrenRect.width;
                        height: childrenRect.height;
                        color: Components.Colour.trans;
                        SoundTile{
                            width: frame.width;
                            node: parent.modelData;
                            clip: true;
                            fontFamily: "Iosevka";
                            activeColor: Components.Colour.accent;
                            activeSecondaryColor: Components.Colour._active2;
                            activeSliderColor: Components.Colour.accent_dark;
                            activeTextColor: Components.Colour.fg;
                            activeBackgroundColor: Components.Colour.bg;
                            border.color: activeColor;
                            border.width: 2;
                            color: Components.Colour.trans;
                            radius: 2;
                        }
                    }
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
