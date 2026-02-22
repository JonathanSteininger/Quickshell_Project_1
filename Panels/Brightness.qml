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
    Repeater{
        model: Components.GlobalState.brigthnessDevices;
        delegate: Rectangle {
            required property var modelData;
            Text {
                text: modelData.brightness;
            }
            Slider{
                from: modelData.min_brightness;
                to: modelData.max_brightness;
                value: modelData.brightness;
                onPositionChanged: {
                    modelData.setBrightness(Math.floor(value));
                }
            }
        }
    }

}
