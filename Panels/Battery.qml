import QtQuick
import Quickshell
import qs.Components
import Quickshell.Services.UPower

Item{
    implicitWidth: 270;
    implicitHeight: 40;
    Text{
        anchors.centerIn: parent;
        function getText(){
            //console.log(GlobalState.battery.mainBattery.state)
            //console.log(UPowerDeviceState.PendingCharge,UPowerDeviceState.Charging,UPowerDeviceState.Discharging,UPowerDeviceState.Unknown,UPowerDeviceState.PendingDischarge,);
            switch (GlobalState.battery.mainBattery.state){
                case UPowerDeviceState.Charging:
                    return "Time till full:"
                case UPowerDeviceState.Discharging:
                    return "Time till Empty:"
                default:
                    return 0
            }
        }
        function getTime(){
            //console.log(GlobalState.battery.mainBattery.state)
            //console.log(UPowerDeviceState.PendingCharge,UPowerDeviceState.Charging,UPowerDeviceState.Discharging,UPowerDeviceState.Unknown,UPowerDeviceState.PendingDischarge,);
            switch (GlobalState.battery.mainBattery.state){
                case UPowerDeviceState.Charging:
                    return GlobalState.battery.mainBattery.timeToFull
                case UPowerDeviceState.Discharging:
                    return GlobalState.battery.mainBattery.timeToEmpty
                default:
                    return 0
            }
        }
        property real totalTime: getTime();
        property string startingText: getText();
        property int hours:Math.floor(totalTime / (60*60)) ;
        property int minutes:totalTime / 60 % 60;
        property int seconds:totalTime % 60;
        text: `${startingText} ${hours != 0 ? `${hours}:` : ''}${minutes}:${seconds}`;
        color: Colour.fg;
        font.family: "Iosevka";
        font.pointSize: 14;
    }
}
