import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../Components/"

ButtonStrip{
    id: rightPanel;
    anchors.right: parent.right;
    borderColor: Colour.accent;
    borderSize: 0.6;
    color: Colour.bg;
    tiltRight: true;
    tiltStrength: 1
    implicitHeight: 50;
    Text{
        text: "hello";
        color: Colour.fg;
        font.family: "Iosevka";
        font.pointSize: 14;
    }
    Text{
        text: "hello";
        color: Colour.fg;
        font.family: "Iosevka";
        font.pointSize: 14;
    }
    Text{
        text: "hello";
        color: Colour.fg;
        font.family: "Iosevka";
        font.pointSize: 14;
    }
    Text{
        text: "hello";
        color: Colour.fg;
        font.family: "Iosevka";
        font.pointSize: 14;
    }
    Text{
        text: "hello";
        color: Colour.fg;
        font.family: "Iosevka";
        font.pointSize: 14;
    }
}
