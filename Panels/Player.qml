import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Shapes
import QtQml.Models
import "../Components/" as Components
import "../Tiles/" as Tiles
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

    Components.CenterButtonStripLayout{
        id: playerSelector;
        width: parent.width;
        centerIndex: (innerChildren.length-1)/2;
        height: 40;
        color: Components.Colour.accent;
        borderColor: Components.Colour.fg;
        borderSize: 1;
        centerLine: true;
        innerChildWidth: parent.width - spacing - height;
        innerChildren: [
            Text{
                Layout.fillWidth: false;
                text: "<<";
                signal clicked();
                onClicked:{
                    Components.GlobalState.previousPlayer();
                }
            },
            Repeater{
                model: Components.GlobalState.players.values.length;
                Rectangle{
                    required property int index;
                    Layout.fillWidth: true;
                    height: childrenRect.height;
                    color: Components.Colour.trans;
                    Text{
                        anchors.centerIn: parent;
                        horizontalAlignment: Qt.AlignCenter;
                        text:  Components.GlobalState.players.values[parent.index].identity.split(' ')[0];
                    }
                    signal clicked();
                    onClicked:{
                        Components.GlobalState.activePlayer = index;
                    }
                    Component.onCompleted:{
                        console.log(Components.GlobalState.players.values[index].identity);
                    }
                }
            },
            Text{
                Layout.fillWidth: false;
                text: ">>";
                signal clicked();
                onClicked:{
                    Components.GlobalState.nextPlayer();
                }
            }
        ]
    }
    color: Components.Colour.trans;
    Tiles.PlayerTile{
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
