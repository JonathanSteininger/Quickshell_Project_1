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
        text: "<<"
        signal clicked()
        onClicked: () => {
            //GlobalState.popupMiddle("player", root.convertPopoutPosition(x, width));
            GlobalState.previousPlayer();
        }
    }
    Text{
        property bool center: true;
        color: Colour.fg
        horizontalAlignment: Text.AlignLeft;
        text: GlobalState.activePlayerActual.trackTitle;
        width: Math.min(implicitWidth, 400);
        clip: true;
        signal clicked()
        onClicked: () => {
            GlobalState.popupMiddle("player", root.convertPopoutPosition(x, width));
        }
        onTextChanged: () => {
            root._update();
        }
    }
    Text{
        color: Colour.fg
        text: ">>"
        signal clicked()
        onClicked: () => {
            //GlobalState.popupMiddle("player", root.convertPopoutPosition(x, width));
            GlobalState.nextPlayer();
        }
    }

    function convertPopoutPosition(_x, _width){
        var output = _x + _width/2 - this.width/2;
        return output;
    }
}
