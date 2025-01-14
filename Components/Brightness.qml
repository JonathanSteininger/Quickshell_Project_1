pragma Singleton

import Quickshell 
import QtQuick
import Quickshell.Io

Singleton{
    id: root;
    property real brightness: 69;
    property real maxBrightness: 100;

    signal updateMaxBrightness()
    signal updateBrightness()
    signal setBrightness(value: real)
    signal increaseBrightness(value: real)
    signal decreaseBrightness(value: real)

    onUpdateBrightness: {
    }
    onUpdateMaxBrightness: {
    }
    onSetBrightness: (value) => {
    }
    onIncreaseBrightness: (value) => {
    }
    onDecreaseBrightness: (value) => {
    }
    Process{
        id: brightnessProc;
        running: true;
        command: ["sh", "-c", "brightnessProc g"];
        stdout: SplitParser{
            onRead: (data) => {
                root.brightness = parseFloat(data);
            }
        }
        stderr: SplitParser{
            onRead: (data) => {
                root.brightness = null;
                console.log("Brightness failed: ", data);
            }
        }
    }
    Process{
        id: maxBrightnessProc;
        running: true;
        command: ["sh", "-c", "brightnessProc m"];
        stdout: SplitParser{
            onRead: (data) => {
                root.maxBrightness = parseFloat(data);
            }
        }
        stderr: SplitParser{
            onRead: (data) => {
                root.brightness = null;
                console.log("Brightness failed: ", data);
            }
        }
    }
    Process{
        id: setBrightness;
        running: true;
        command: ["sh", "-c", "brightnessProc m"];
        stdout: SplitParser{
            onRead: (data) => {
                root.brightness = parseFloat(data);
            }
        }
        stderr: SplitParser{
            onRead: (data) => {
                root.brightness = null;
                console.log("Brightness failed: ", data);
            }
        }
    }
}
