import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../Components/"

ButtonStrip{
    id: leftPanel;
    anchors.left: parent.left;
    borderColor: Colour.accent;
    borderSize: 0.6;
    color: Colour.bg;
    tiltRight: false
    tiltStrength: 1
    implicitHeight: 50;
    property string currentjson: "";

    Text{
        id: test;
        color: Colour.fg;
        width: 120;
        font.family: "Iosevka";
        font.pointSize: 14;
        horizontalAlignment: Text.AlignHCenter;
        signal clicked();
        onClicked: () => console.log("Open Time panel");
        Process {
            id: dateProc;
            command: ["date", "+%r"];
            running: true;
            stdout: SplitParser {
                onRead: data => test.text = data;
            }
        }
        Timer{
            interval: 1000;
            running: true;
            repeat: true;
            onTriggered: {
                dateProc.running = true;
            }
        }
    }

    Text{
        color: Colour.fg
        text: "rectangle 2"
        signal clicked()
        onClicked: () => console.log("clicked", text);
    }
    Text{
        color: Colour.fg
        text: "rectangle 3"
        signal clicked()
        onClicked: () => console.log("clicked", text);
    }
}
