import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../Components/" 

Text{
    property int wid: -1;
    property string wname: "name";
    property string iconPath: "";
    text: "1"
    horizontalAlignment: Text.AlignHCenter;
    color: Colour.fg;
    font.family: "Iosevka";
    font.pointSize: 14;
    signal clicked();

    onClicked: {
        gotoWorkspace.running = true;
    }

    Process{
        id: gotoWorkspace;
        command: ["hyprctl", "--instance", "0", "dispatch", "workspace", wid];
        running: false
    }
    function myDestroy(){
        destroy();
    }
}
