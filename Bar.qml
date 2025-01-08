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
        screen: Quickshell.screens[0];
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
        Panels.Audio {}
        Panels.Time {}

    }
    /*
    Panels.PopoutPanel{
        anchor.window: test;
        visible: Components.GlobalState.showMiddle;
        anchor.gravity: Edges.Bottom;
        anchor.edges: Edges.Bottom;
        anchor.rect.y: -6;
        Panels.Audio {}
        Panels.Time {}
    }
    Panels.PopoutPanel{
        anchor.window: test;
        visible: Components.GlobalState.showRight;
        anchor.gravity: Edges.Bottom | Edges.Right;
        anchor.edges: Edges.Bottom | Edges.Left;
        anchor.rect.y: -6;
        Panels.Audio {}
        Panels.Time {}
    }
    */
}
