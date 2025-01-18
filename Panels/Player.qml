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
    height: container.height + 10;
    MouseArea{
        width: root.width;
        height: root.height;
    }

    color: Components.Colour.trans;
    Column{
        id: container;
        y: 5;
        width: parent.width -10;
        anchors.horizontalCenter: parent.horizontalCenter;
        spacing: 10;
        height: childrenRect.height;
        Components.CenterButtonStripLayout{
            id: playerSelector;
            width: parent.width;
            centerIndex: (innerChildren.length-1)/2;
            height: 40;
            color: Components.Colour.accent;
            borderColor: Components.Colour.bg_solid;
            fillColor: Components.Colour._active;
            borderSize: 2;
            centerLine: Components.GlobalState.players.values.length % 2 == 0;
            innerChildWidth: parent.width - spacing - height;
            innerChildren: [
                Text{
                    Layout.fillWidth: false;
                    text: "<<";
                    color: Components.Colour.fg;
                    font.pointSize: 20;
                    font.bold: true;
                    font.family: "Iosevka";
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
                        height: text.height;
                        color: Components.Colour.trans;
                        Text{
                            color: Components.Colour.fg;
                            font.bold: true;
                            font.pointSize: 14;
                            font.family: "Iosevka";
                            id: text;
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
                    color: Components.Colour.fg;
                    font.pointSize: 20;
                    font.bold: true;
                    font.family: "Iosevka";
                    signal clicked();
                    onClicked:{
                        Components.GlobalState.nextPlayer();
                    }
                }
            ]
        }
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
}
