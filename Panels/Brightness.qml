import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQml.Models
import "../Components/" as Components
pragma ComponentBehavior: Bound

Rectangle{
    id: root;
    width: 200;
    height: 80;
    color: Components.Colour.trans;

    Components.Slider{
        barColor: Components.Colour.accent;
        backgroundColor: Components.Colour.trans;
        emptyColor: Components.Colour.accent_dark; 
        overShootColor: Components.Colour.accent_dark; 
        value:  root.brightness;
        width: root.width;
        from: 0;
        to: root.maxBrightness;
        stepSize: root.maxBrightness * 0.05;
        textLeft: "0%";
        textRight: "100%";
    }
}
