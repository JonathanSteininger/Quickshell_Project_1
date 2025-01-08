import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "../Components/" as Components
PopupWindow{
    id: root
    anchor.edges: Edges.Left | Edges.Top;
    anchor.gravity: Edges.Bottom | Edges.Right;
    anchor.rect.width: test.width;
    anchor.rect.height: test.height;
    width: Quickshell.screens[0].width * 0.5;
    height: Quickshell.screens[0].height * 0.8;
    visible: Components.GlobalState.showLeft;
    color: "#88ffffff"
    mask: regionTop;
    
    property var regionTop: Region{
        item: topBarIgnorer;
        intersection: Intersection.Xor; 
    }
    property var regionPopout: Region{
        item: stack;
    }

    Rectangle{
        id: topBarIgnorer;
        height: test.height;
        width: root.width;
        color: "#21000000";
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
        Components.GlobalState.left = -1;
    }
    onVisibleChanged: {
        if(visible){
            //use top bar ignorer when turning visible
            mask = regionTop;
        }
    }
    Components.StackingCanvas{
        id: stack
        x: Components.GlobalState.leftPos.x;
        y: Components.GlobalState.leftPos.y;
         
        cornerSize: 20;
        padding: 15;
        borderSize: 2;

        duration: 400;

        currentIndex: Components.GlobalState.left;

        Audio {}
        Time {}

        onDeselect: {
            Components.GlobalState.showLeft = false;
        }
        onSelect: {
            Components.GlobalState.showLeft = true;
        }

        onCurrentIndexChanged: {
            if(currentIndex == -1){
                Components.GlobalState.leftPos.y = -height;    
                height: 60;
            }
        }
    }
}
/*
PopupWindow{
    id: leftPopout
    anchor.edges: Edges.Left | Edges.Top;
    anchor.gravity: Edges.Bottom | Edges.Right;
    anchor.rect.width: test.width;
    anchor.rect.height: test.height;
    width: Quickshell.screens[0].width * 0.5;
    height: Quickshell.screens[0].height * 0.8;
    visible: Components.GlobalState.left != -1;
    color: "#00ffffff"
    mask: Region{
        item: topBarIgnorer;
        intersection: Intersection.Xor; 
    }
    Rectangle{
        id: topBarIgnorer;
        height: test.height;
        width: leftPopout.width;
        color: "#00000000";
    }
    MouseArea{
        anchors.fill: parent;
        onClicked: (mouse) =>{
            Components.GlobalState.left = -1;
        }
        onExited: () => {
            Components.GlobalState.left = -1;
        }
        hoverEnabled: true;
    }
    StackLayout{
        id: layout;
        y: Components.GlobalState.leftPos.y;
        x: Components.GlobalState.leftPos.x;
        currentIndex: Components.GlobalState.left;
        Behavior on y { 
            PropertyAnimation{
                duration: 200;
                easing.type: Easing.InOutQuad;
            }
        }
        Behavior on x { 
            PropertyAnimation{
                duration: 200;
                easing.type: Easing.InOutQuad;
            }
        }
        Behavior on width { 
            PropertyAnimation{
                duration: 200;
                easing.type: Easing.InOutQuad;
            }
        }
        Behavior on height { 
            PropertyAnimation{
                duration: 200;
                easing.type: Easing.InOutQuad;
            }
        }
        onCurrentIndexChanged: {
            if(currentIndex < 0 || currentIndex >= children.length){
                Components.GlobalState.left = -1;
                return
            }
            //x = children[currentIndex].x1;
            //y = children[currentIndex].y1;
            width = children[currentIndex]._width;
            height = children[currentIndex]._height;
            console.log(children[currentIndex].width);
            console.log(width);
        }
        Audio{}
        Time{}
    }
}
*/
