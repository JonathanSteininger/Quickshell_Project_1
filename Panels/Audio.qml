import Quickshell
import QtQuick
import QtQuick.Layouts
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
                width: 250;
                height: 50;
                color: "white";
                Text {
                    anchors.top: parent.top;
                    color: "black";
                    text: name;
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter;
                    color: "black";
                    text: nickname;
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter;
                    anchors.right: parent.right;
                    color: "black";
                    text: id;
                }
                Text {
                    anchors.bottom: parent.bottom;
                    color: "black"
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
        color: Components.Colour.trans;

        ColumnLayout{
            Repeater{
                model: sinkModel;
            }
        }
    }
}
