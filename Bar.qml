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
        //do different. big window. move rectangle.
        Panels.PopoutPanel{
            anchor.window: test;
        }
    }
    
}
