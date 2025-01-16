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




    Components.CenterButtonStrip{
        id: playerSelector;
        width: parent.width;
        height: 40;
        innerChildren: [
            Text{
                text: "<<";
            },
            Repeater{
                model: Components.GlobalState.players.values.length;
                Text{
                    required property int index;
                    text: index;
                }
            },
            Text{
                text: ">>";
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
