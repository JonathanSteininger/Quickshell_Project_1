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

    property var cinemaDisplays: [
        {
            path: "/dev/usb/hiddev1",
            maxBrightness: 0,
            brightness: 0,
            errored: false
        }
    ]

    /*
     {
         id: 0,
         maxBrightness: 0,
         brightness: 0,
         brightnessID: -1,
         errored: false
     }
     */
    //ddcutil --display 0 
    //setvcp <feature-code> arg
    //getvcp <feature-code> 
    //-t for brief output.
    property var monitors: [
    ]

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




    Process{
        id: cinemaDisplayProc;
        running: false;
        property string devicePath;
        command: ["acdcontrol", devicePath];
        stdout: SplitParser{
            onRead: data => {
                var _sections = data.split(" ");
                var output = "no battery?";
                for (var i = 0; i < _sections.length; i++){
                    if (_sections[i].includes(":")){
                        output = _sections[i];
                    }
                }
                var time = output;
                charging.text = `${time}`;
            }
        }
        stderr: SplitParser{
            onRead: (data) => {
                console.log("Cinema display proc failed.");
                console.log("battery remaining  error:", data);
            }
        }
        onExited: (exitCode, exitStatus) => {
            if(exitCode != 0){
                console.log("error code returned from cinema display process:", exitCode);
            }
        }
    }
}
