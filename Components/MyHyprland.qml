import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../Components/"
import "../Dynamic/"
import Quickshell.Hyprland

Hyprland{
    onRawEvent: {
        console.log(event);
    }

}
