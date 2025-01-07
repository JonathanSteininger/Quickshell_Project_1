pragma Singleton

import Quickshell 
import QtQuick

Singleton {
    function popupLeft(id: string, point: point): void{
        var lower = id.toLowerCase();
        left = leftMap.findIndex((child) => child == lower);
        leftPos.x = point.x;
        leftPos.y = point.y;
    }
    property int left: -1;
    property point leftPos: Qt.point(0, 60);
    property list<string> leftMap:[
        "audio",
        "time"
    ]

}
