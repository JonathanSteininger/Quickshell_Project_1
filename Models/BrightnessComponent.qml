import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle{
    id: root;
    required property int displayNumber;
    property int brightness;
    property int maxBrightness;
    property int minBrightness;
    property int featureCode;

    onBrightnessChanged:{
    }

    //get brightness
    Process{
        id: brightnessProc
        command: ["ddcutil", "-t","--display", root.displayNumber, "getvcp", root.featureCode];
        running: false;
        stdout: SplitParser{
            onRead: data => {
                root.brightness = data.split(" ").[3];
            }
        }
        stderr: SplitParser{
            onRead: (data) => {
                console.error("Failed to get brightness");
            }
        }
        onExited: (exitCode, exitStatus) => {
            if(exitCode != 0){
                console.error("brightness error code: ", exitCode);
                charging.destroy();
            }
        }
    }
    Process{
        id: setBrightnessProc
        command: ["ddcutil", "--display", displayNumber, get];
        running: false;
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
                console.log("battery remaining failed... or some other error.");
                console.log("battery remaining  error:", data);
                charging.destroy();
            }
        }
        onExited: (exitCode, exitStatus) => {
            if(exitCode != 0){
                console.log("error code returned from battery remaining process:", exitCode);
                charging.destroy();
            }
        }
    }
    Process{
        id: maxBrightnessProc
        command: ["ddcutil", "--display", displayNumber, get];
        running: false;
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
                console.log("battery remaining failed... or some other error.");
                console.log("battery remaining  error:", data);
                charging.destroy();
            }
        }
        onExited: (exitCode, exitStatus) => {
            if(exitCode != 0){
                console.log("error code returned from battery remaining process:", exitCode);
                charging.destroy();
            }
        }
    }
    Process{
        id: minBrigthnessProc
        command: ["ddcutil", "--display", displayNumber, get];
        running: false;
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
                console.log("battery remaining failed... or some other error.");
                console.log("battery remaining  error:", data);
                charging.destroy();
            }
        }
        onExited: (exitCode, exitStatus) => {
            if(exitCode != 0){
                console.log("error code returned from battery remaining process:", exitCode);
                charging.destroy();
            }
        }
    }
    Process{
        id: featureCodeProc;
        command: ["ddcutil", "--display", displayNumber, get];
        running: false;
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
                console.log("battery remaining failed... or some other error.");
                console.log("battery remaining  error:", data);
                charging.destroy();
            }
        }
        onExited: (exitCode, exitStatus) => {
            if(exitCode != 0){
                console.log("error code returned from battery remaining process:", exitCode);
                charging.destroy();
            }
        }
    }
}
