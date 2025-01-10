pragma Singleton

import Quickshell 

Singleton {
    function addOpacity(opacity: string, colour: string): string{
        return `#${opacity}${colour.substring(1)}`;
    }
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

    property string trans: "#00000000";
}
