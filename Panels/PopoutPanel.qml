import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "../Components/" as Components
PopupWindow{
    id: root;
    default property alias data: stack.data;
    anchor.edges: Edges.Left | Edges.Bottom;
    anchor.gravity: Edges.Bottom | Edges.Right;
    anchor.rect.width: anchor.window.width;
    anchor.rect.height: anchor.window.height;
    width: Quickshell.screens[0].width * 0.5;
    height: Quickshell.screens[0].height * 0.8;
    visible: true;
    color: Components.Colour.trans;
    mask: regionTop;

    property string windowGravity: "right";

    required property int currentPopout;
    required property int popoutX;
    required property int popoutY;
    
    property var regionTop: Region{
        item: topBarIgnorer;
        intersection: Intersection.Xor; 
    }
    property var regionPopout: Region{
        item: stack;
    }

    Rectangle{
        id: topBarIgnorer;
        height: 5;
        width: root.width;
        color: Components.Colour.trans;
    }
    signal hidePopout()
    onHidePopout: {
        //swap to popout region when closing window to restore imediate mouse clicks.
        mask = regionPopout;
        changeCurrentPopout(-1);
    }

    signal changeCurrentPopout(value:int)
    signal changeVisibility(value:bool)
    signal changePos(x:int,y:int)

    onVisibleChanged: {
        if(visible){
            //use top bar ignorer when turning visible
            mask = regionTop;
        }
    }
    MouseArea{
        anchors.fill: parent;
        propagateComposedEvents: true;
        onClicked: (mouse) =>{
            root.hidePopout();
        }
        onExited: () => {
            root.hidePopout();
        }
        hoverEnabled: true;
        Components.StackingCanvas{
            id: stack
            x: {
                switch(root.windowGravity){
                    case "left":
                    return root.width - root.popoutX - targetWidth + padding;
                    case "bottom":
                    return root.popoutX - targetWidth /2 + root.width/2 + (root.popoutX > 10 ? -padding : (root.popoutX < -10 ? padding : 0));
                }
                return root.popoutX - padding;

            }
            y: root.popoutY;
            color: Components.Colour.bg;
            borderColor: Components.Colour.accent;

            cornerSize: 20;
            padding: 10;
            borderSize: 2;

            duration: 400;
            property real targetWidth: width;
            property real targetHeight: height;
            onSetWidth: (value) => {
                targetWidth = value;
            }
            onSetHeight: (value) => {
                targetHeight= value;
            }

            currentIndex: root.currentPopout;

            onDeselect: {
                root.changeVisibility(false);
            }
            onSelect: {
                root.changeVisibility(true);
            }

            onCurrentIndexChanged: {
                if(currentIndex == -1){
                    height = 60;
                    root.changePos(root.popoutX, -60)
                }
            }
        }
    }
}
