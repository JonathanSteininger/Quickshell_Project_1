import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "Sections/" as Sections
import "Components/" as Components 
import "Panels/" as Panels 

Scope {
    PanelWindow {
        id: test;
        color: "#00000000";
        //looks for DP-1 otherwise uses first monitor in list. 
        screen: Quickshell.screens.filter((monitor) => monitor.name == "DP-1") != [] ? Quickshell.screens.filter((monitor) => monitor.name == "DP-1") : Quickshell.screens[0];
        height: 60;
        anchors {
            top: true
            left: true
            right: true
        }
        Rectangle{
            color: "transparent";
            width: parent.width;
            height: 50;
            anchors.verticalCenter: parent.verticalCenter;

            
            Sections.Left{
            }
            Sections.Middle{
            }
            Sections.Right{
            }
        }
    }
    
    Panels.PopoutPanel{
        anchor.window: test;
        visible: Components.GlobalState.showLeft;
        currentPopout: Components.GlobalState.left;
        popoutX: Components.GlobalState.leftPos.x;
        popoutY: Components.GlobalState.leftPos.y;
        windowGravity: "right";
        onChangeCurrentPopout: (value) => {
            Components.GlobalState.left = value;
        }
        onChangeVisibility: (value) => {
            Components.GlobalState.showLeft = value;
        }
        onChangePos: (x, y) => {
            Components.GlobalState.leftPos.x = x;
            Components.GlobalState.leftPos.y = y;
        }
        anchor.rect.y: -6;
        Panels.Time {}
    }

    Panels.PopoutPanel{
        anchor.window: test;
        anchor.edges: Edges.Bottom;
        anchor.gravity: Edges.Bottom;
        visible: Components.GlobalState.showMiddle;
        currentPopout: Components.GlobalState.middle;
        popoutX: Components.GlobalState.middlePos.x;
        popoutY: Components.GlobalState.middlePos.y;
        cornerSize: 50;
        windowGravity: "bottom";
        onChangeCurrentPopout: (value) => {
            Components.GlobalState.middle = value;
        }
        onChangeVisibility: (value) => {
            Components.GlobalState.showMiddle = value;
        }
        onChangePos: (x, y) => {
            Components.GlobalState.middlePos.x = x;
            Components.GlobalState.middlePos.y = y;
        }
        anchor.rect.y: -6;
        Panels.Player{}
    }

    //rightPanel
    Panels.PopoutPanel{
        anchor.window: test;
        anchor.edges: Edges.Bottom | Edges.Right;
        anchor.gravity: Edges.Bottom | Edges.Left;
        visible: Components.GlobalState.showRight;
        currentPopout: Components.GlobalState.right;
        popoutX: Components.GlobalState.rightPos.x;
        popoutY: Components.GlobalState.rightPos.y;
        windowGravity: "left";
        onChangeCurrentPopout: (value) => {
            Components.GlobalState.right = value;
        }
        onChangeVisibility: (value) => {
            Components.GlobalState.showRight = value;
        }
        onChangePos: (x, y) => {
            Components.GlobalState.rightPos.x = x;
            Components.GlobalState.rightPos.y = y;
        }
        anchor.rect.y: -6;
        Panels.Audio {}
        Panels.SystemTrayMenu {
            menuData: Components.GlobalState.activeSysTrayMenu == null ? Components.GlobalState.blankTrayMenu : Components.GlobalState.activeSysTrayMenu;
        }
        Panels.Brightness{}
        Panels.Network{}
    }
}
