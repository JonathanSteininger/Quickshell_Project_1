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
    MouseArea{
        anchors.fill: parent;
        onClicked: (mouse) =>{
            root.hidePopout();
        }
        onExited: () => {
            root.hidePopout();
        }
        hoverEnabled: true;
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
    Components.StackingCanvas{
        id: stack
        x: root.popoutX;
        y: root.popoutY;
        color: Components.Colour.bg;
        borderColor: Components.Colour.accent;
         
        cornerSize: 20;
        padding: 15;
        borderSize: 2;

        duration: 400;

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
