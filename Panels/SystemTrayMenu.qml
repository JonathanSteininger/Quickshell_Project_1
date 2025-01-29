import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Shapes
import QtQml.Models
import "../Components/" as Components
import Quickshell.Services.SystemTray
pragma ComponentBehavior: Bound

Rectangle{
    id: root;
    width: 450;
    height: container.height + 10;
    property QsMenuOpener opener: QsMenuOpener{ menu: menuData;};
    required property var menuData;
    MouseArea{
        width: root.width;
        height: root.height;
    }

    color: Components.Colour.trans;
    ListView{
        id: container 
        width: parent.width;
        height: childrenRect.height;
        model: root.opener.children.values;
        delegate: Rectangle{
            property string _text: text;
            width: parent.width;
            height: 40;
            Button{
                anchors.fill: parent;
                text: parent._text;
            }
            Component.onCompleted:{
            }
        }
    }
}
