import QtQuick

Scope{
    function lerp(start: real, end: real, position: real){
        var diff = end - start;
        var output = start + diff * position;

        //maxSize
        if (output > end) {
            return end;
        //MinSize
        } else if(output < start){
            return start;
        }
        return output;
    }
}
