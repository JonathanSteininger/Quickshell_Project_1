import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "Sections/" as Sections

Scope {
    PanelWindow {
        color: "#00000000"
        screen: Quickshell.screens[0]
        height: 60
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
}
