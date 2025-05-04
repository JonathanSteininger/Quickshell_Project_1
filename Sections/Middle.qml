import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../Components/"

CenterButtonStrip{
    id: root;
    tiltStrength: 1
    borderColor: Colour.accent;
    borderSize: 1;
    color: Colour.bg;
    tiltRight: false
    centerIndex: 0;
    x: parent.width/2 - getCenter();
    function getCenter(){
        if(centerIndex < 0 || centerIndex >= innerChildren.length){
            return 0;
        }
        var centerObject = innerChildren[centerIndex];
        var centerPosition = centerObject.x + centerObject.width/2 + spacing/2 + height/2;
        return centerPosition;
    }
    function convertPopoutPosition(_x, _width){
        if(centerIndex < 0 || centerIndex >= innerChildren.length){
            return 0;
        }
        var centerObject = innerChildren[centerIndex];
        var centerPosition = centerObject.x + centerObject.width/2;
        var output = _x + _width/2;
        return output - centerPosition;
    }
    innerChildren:[
        Rectangle{
            width: Math.max(playerText.width, 200);
            height: childrenRect.height;
            color: Colour.trans;
            Text{
                id: playerText;
                property bool center: true;
                color: Colour.fg
                anchors.horizontalCenter: parent.horizontalCenter;
                horizontalAlignment: Text.AlignLeft;
                text: GlobalState.activePlayerActual.trackTitle;
                width: Math.min(implicitWidth, 600);
                clip: true;
            }
            signal clicked()
            onClicked: () => {
                GlobalState.popupMiddle("player", root.convertPopoutPosition(x, width));
            }
        }
    ]

}
