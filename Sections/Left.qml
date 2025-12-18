import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../Components/"
import "../Dynamic/"
import Quickshell.Hyprland

ButtonStrip{
    id: leftPanel;
    anchors.left: parent.left;
    borderColor: Colour.accent;
    borderSize: 1;
    color: Colour.bg;
    tiltRight: false;
    tiltStrength: 1;
    implicitHeight: 50;
    function convertPopoutPosition(xpos: int): int{
        //-15 because thats the popout windows corner.
        return shift + xpos -15;
    }
    Text{
        id: timer;
        color: Colour.fg;
        width: 120;
        font.family: "Iosevka";
        font.pointSize: 14;
        text: Qt.formatDateTime(GlobalState.clock.date, "h:mm:ss AP");
        horizontalAlignment: Text.AlignHCenter;
        signal clicked();
        onClicked: () => GlobalState.popupLeft("time", leftPanel.convertPopoutPosition(x));
    }
    Repeater{
        model: ScriptModel{
            values: Hyprland.workspaces.values.filter((thing) => thing);
        }
        delegate: Item{
            required property HyprlandWorkspace modelData;
            property real padding: 3;
            implicitWidth: childrenRect.width + padding*2;
            Text{
                anchors.centerIn: parent;
                text: parent.modelData.name;
                color: parent.modelData.active ? Colour._active : Colour.fg;
                font.family: "Iosevka";
                font.pointSize: 14;
            }
            signal clicked();
            //onClicked: modelData.activate();
            onClicked: Hyprland.dispatch(`workspace ${modelData.id}`);
        }
    }
}
