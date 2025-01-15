import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQml
import Qt5Compat.GraphicalEffects

Rectangle{
    property string icon: "";
    anchors.verticalCenter: rightPanel.verticalCenter;
    height: 32;
    width: height;
    color: Colour.trans;
    property string iconColor: Colour.fg;
    IconImage{
        id:image;
        anchors.horizontalCenter: parent.horizontalCenter; 
        source: `root:${parent.icon}`;
        implicitSize: parent.height;
        visible:false;
    }
    ColorOverlay{
        anchors.fill: image;
        source: image;
        color: iconColor;
        smooth: true;
        antialiasing: true;
        visible:true;
    }
    signal clicked();
}
