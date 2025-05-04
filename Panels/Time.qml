import Quickshell
import QtQuick
import "../Components/" as Components

Rectangle{
    color: Components.Colour.trans;
    width: 200;
    height: 50;
    Text{
        anchors.centerIn: parent;
        color: Components.Colour.fg;
        text: Qt.formatDateTime(Components.GlobalState.clock.date, "dddd d - MMMM");
    }
}
