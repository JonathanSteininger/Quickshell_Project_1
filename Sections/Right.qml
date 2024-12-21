import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../Components/"

Parallel{
    anchors.right: parent.right
    borderColor: Colour.accent;
    borderSize: 0.6;
    color: Colour.bg;
    tiltRight: true
    tiltStrength: 1
    implicitHeight: 50;
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
            x = parent.width - width - parent.calcOffsetRight(this) - 10;
            parent.addSeperatorParent(this, x - spacing/2);
        }
    }
}
