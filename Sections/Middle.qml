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
    Rectangle{
        width: Math.max(childrenRect.width, 200);
        height: childrenRect.height;
        color: Colour.trans;
        Text{
            property bool center: true;
            color: Colour.fg
            anchors.horizontalCenter: parent.horizontalCenter;
            horizontalAlignment: Text.AlignLeft;
            text: GlobalState.activePlayerActual.trackTitle;
            width: Math.min(implicitWidth, 400);
            clip: true;
            onTextChanged: () => {
                root._update();
            }
        }
        signal clicked()
        onClicked: () => {
            GlobalState.popupMiddle("player", root.convertPopoutPosition(x, width));
        }
    }

    function convertPopoutPosition(_x, _width){
        var output = _x + _width/2 - this.width/2;
        return output;
    }
}
