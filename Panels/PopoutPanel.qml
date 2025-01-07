import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "../Components/" as Components

PopupWindow{
    id: leftPopout
    anchor.edges: Edges.Left | Edges.Top;
    anchor.gravity: Edges.Bottom | Edges.Right;
    anchor.rect.width: test.width;
    anchor.rect.height: test.height;
    width: Quickshell.screens[0].width * 0.5;
    height: Quickshell.screens[0].height * 0.8;
    visible: Components.GlobalState.left != -1;
    color: "#77ffffff"
    mask: Region{
        item: topBarIgnorer;
        intersection: Intersection.Xor; 
    }
    Rectangle{
        id: topBarIgnorer;
        height: test.height;
        width: leftPopout.width;
        color: "#11000000";
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
