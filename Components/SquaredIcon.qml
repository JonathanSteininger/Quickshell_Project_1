import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQml
import QtQuick.Effects

Item{
    id: root;
    property string icon: "";
    height: 32;
    width: height;
    property string iconColor: "white";
    IconImage{
        id:image;
        anchors.horizontalCenter: parent.horizontalCenter; 
        source: `root:${parent.icon}`;
        backer.sourceSize: Qt.size(root.height*2,root.height*2);
        implicitSize: parent.height;
        visible: false;
    }
    MultiEffect { 
        id: effect;
        anchors.fill: image;
        source: image;
        brightness: 1.0;
        visible: false;
    }
    MultiEffect { 
        anchors.fill: image;
        source: effect;
        colorizationColor: root.iconColor;
        colorization: 1.0;
    }
    signal clicked();
}
