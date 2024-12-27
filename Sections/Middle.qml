import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../Components/"

CenterButtonStrip{
    anchors.centerIn: parent
    tiltStrength: 1
    borderColor: Colour.accent;
    borderSize: 0.6;
    color: Colour.bg;
    tiltRight: false
    Text{
        color: Colour.fg
        text: "rectangle"
    }
    Text{
        property bool center: true;
        color: Colour.fg
        width: 120
        horizontalAlignment: Text.AlignHCenter;
        text: "rectangle"
    }
    Text{
        color: Colour.fg
        text: "rectangle"
    }
}
