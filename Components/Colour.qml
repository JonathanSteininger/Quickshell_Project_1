pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    function addOpacity(colour: color, opacity: real): color{
        var newColor = Qt.color(colour);
        newColor.a = opacity;
        return newColor;
    }
    /*
    property string _active: "#F05941";
    property string bg_solid: "#320A09";
    property string bg: addOpacity("CC", bg_solid);
    property string fg: "#FFD3B0";
    property string dark: "#0D0F01";
    property string accent: "#872341";
    property string accent_dark: "#351921";
    property string selectedDark: "#5E2324";
    property string _active2: "#5D2341";
    property string _active3: "#963B38";
    */

    property color trans: "#00000000";

    property color _active: pywalJson.colors.color4;
    property color bg_solid: pywalJson.special.background;
    property color bg: addOpacity(bg_solid, 0.8);
    property color fg: pywalJson.special.foreground;
    property color dark: "#0D0F01";
    property color accent: pywalJson.colors.color2;
    property color accent_dark: accent.darker(2);
    property color selectedDark: _active.darker(2);
    property color _active2: "red";
    property color _active3: pywalJson.colors.color3;

    /*
    property color background: pywalJson.colors.color1;
    property color foreground: pywalJson.colors.color7;
    property color borders: pywalJson.colors.color6;
    property color active: pywalJson.colors.color10;
    property color active_bright: "#E1DD85";
    property color trueBorder: pywalJson.colors.color3;

    property color focused: pywalJson.colors.color5;
    property color closed: pywalJson.colors.color8;

    property real opacity: pywalJson.alpha * 0.01;

    property color background_trans: Qt.alpha(background, opacity);
    property color foreground_trans: Qt.alpha(foreground, opacity);
    property color borders_trans: Qt.alpha(borders, opacity);
    property color active_trans: Qt.alpha(active, opacity);
    property color trueBorder_trans: Qt.alpha(trueBorder, opacity);
    */
   Timer{ 
       id: firstLoadReload;
       running: false;
       repeat: false;
       interval: 100;
       onTriggered: Quickshell.reload(false);
   }
    FileView{
        id: fileViewer;
        path: `${Quickshell.env("HOME")}/.cache/wal/colors.json`;
        watchChanges: true;
        preload: true;
        JsonAdapter{
            id: pywalJson;
            property string wallpaper: "/hyprdev/.config/hypr/backgrounds/fantasy-background.jpg";
            property real alpha: 80;
            property JsonObject special: JsonObject {
                property string background: "#0E130E"
                property string foreground: "#aacdd8"
                property string cursor: "#aacdd8"
            }
            property JsonObject colors: JsonObject {
                property string color0: "#0E130E"
                property string color1: "#4B6E69"
                property string color2: "#7D9161"
                property string color3: "#387188"
                property string color4: "#4A798C"
                property string color5: "#2776C7"
                property string color6: "#5E95A1"
                property string color7: "#aacdd8"
                property string color8: "#768f97"
                property string color9: "#4B6E69"
                property string color10: "#7D9161"
                property string color11: "#387188"
                property string color12: "#4A798C"
                property string color13: "#2776C7"
                property string color14: "#5E95A1"
                property string color15: "#aacdd8"
            }
        }
    }
}
