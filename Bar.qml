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
        height: 50
        anchors {
            top: true
            left: true
            right: true
        }
        Sections.Left{
        }
        Sections.Middle{
        }
        Sections.Right{
        }
    }
}
