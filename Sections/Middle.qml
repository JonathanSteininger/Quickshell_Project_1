import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../Components/"

CenterButtonStrip{
    id: root;
    anchors.centerIn: parent
    tiltStrength: 1
    borderColor: Colour.accent;
    borderSize: 0.6;
    color: Colour.bg;
    tiltRight: false
    Text{
        color: Colour.fg
        text: "rectangle"
        signal clicked()
        onClicked: () => {
            GlobalState.popupMiddle("audio", root.convertPopoutPosition(x, width));
        }
    }
    Text{
        property bool center: true;
        color: Colour.fg
        width: 120
        horizontalAlignment: Text.AlignHCenter;
        text: "rectangle"
        signal clicked()
        onClicked: () => {
            GlobalState.popupMiddle("time", root.convertPopoutPosition(x, width));
        }
    }
    Text{
        color: Colour.fg
        text: "rectangle"
        signal clicked()
        onClicked: () => {
            GlobalState.popupMiddle("audio", root.convertPopoutPosition(x, width));
        }
    }

    function convertPopoutPosition(_x, _width){
        var output = _x + _width/2 - this.width/2;
        return output;
    }
}
