pragma Singleton

import Quickshell 
import QtQuick

Singleton {
    property int popupOffset: 8;



    function popupLeft(id: string, point: point): void{
        var lower = id.toLowerCase();
        left = leftMap.findIndex((child) => child == lower);
        leftPos.x = point.x;
        leftPos.y = point.y;
    }
    property bool showLeft: false;
    property int left: -1;
    property point leftPos: Qt.point(0, -80);

    property list<string> leftMap:[
        "audio",
        "time"
    ]





    function popupMiddle(id: string, point: point): void{
        var lower = id.toLowerCase();
        middle = middleMap.findIndex((child) => child == lower);
        middlePos.x = point.x;
        middlePos.y = point.y;
    }
    property int middle: -1;
    property bool showMiddle: false;
    property point middlePos: Qt.point(0, -80);

    property list<string> middleMap:[
        "audio",
        "time"
    ]




    function popupRight(id: string, point: point): void{
        var lower = id.toLowerCase();
        right = rightMap.findIndex((child) => child == lower);
        rightPos.x = point.x;
        rightPos.y = point.y;
    }
    property int right: -1;
    property bool showRight: false;
    property point rightPos: Qt.point(0, -80);

    property list<string> rightMap:[
        "audio",
        "time"
    ]




}
