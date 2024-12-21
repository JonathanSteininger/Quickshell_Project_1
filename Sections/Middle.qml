import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../Components/"

Trapazoid{
    anchors.centerIn: parent
    tiltStrength: 1
    borderColor: Colour.accent;
    borderSize: 0.6;
    color: Colour.bg;
    tiltRight: false
    RowLayout{
        anchors.verticalCenter: parent.verticalCenter
        implicitHeight: parent.height - parent.borderSize*2;
        spacing: 35
        Text{
            color: Colour.fg
            text: "rectangle"
        }
        Text{
            color: Colour.fg
            text: "rectangle"
        }
        Text{
            color: Colour.fg
            text: "rectangle"
        }
        Component.onCompleted: {
            x = parent.calcOffsetLeft(this) + 10;
        }
    }
}
