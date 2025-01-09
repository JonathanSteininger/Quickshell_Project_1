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
    height: 800;
    property PwObjectTracker tracker: Components.GlobalState.tracker;
    Rectangle{
        color: Components.Colour.trans;
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
                id: item
                width: root.width;
                height: 50;
                border.color: Components.Colour.accent;
                border.width: 1;
                color: Components.GlobalState.defaultAudio.id == id ? Components.Colour.accent : Components.Colour.trans;
                Text {
                    anchors.top: parent.top;
                    color: Components.Colour.fg;
                    text: description;
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
                    text: audio.volume;
                }
                Component.onCompleted: {
                    item.DelegateModel.inOutputDevice = true;
                }
            }
            items.onChanged: {
                filter();
            }
            Component.onCompleted:{
                filter();
            }

            function filter(){
                console.log("filter");
                for( var i = 0; i < items.count;i++ ) {  
                    var entry = items.get(i);  
                    if(entry.model.isSink && !entry.model.isStream) {  
                        entry.inOutputDevice = true;
                    }  
                }
            }
        }

        ColumnLayout{
            Repeater{
                model: sinkModel;
            }
            Rectangle{
                color: Components.Colour.trans;
                width: root.width;
                height: 40;
                Rectangle{
                    anchors.verticalCenter: parent.verticalCenter;
                    width: root.width;
                    height: 2;
                    color: "white";
                }
            }
            Repeater{
                model: 10;
            Rectangle{
                width: root.width;
                height: 40;
                color: "blue";
            }
            }
        }
    }
}
