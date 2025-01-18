pragma Singleton

import Quickshell 
import QtQuick

Singleton{
    readonly property string iconPathLocal: "Icons/";

    readonly property string volume_mute: `${iconPathLocal}speaker-slash.svg`;
    readonly property string volume_x: `${iconPathLocal}speaker-x.svg`;
    readonly property string volume_low: `${iconPathLocal}speaker-low.svg`;
    readonly property string volume_high: `${iconPathLocal}speaker-high.svg`;

    readonly property string shuffle: `${iconPathLocal}shuffle.svg`;
    readonly property string repeat_track: `${iconPathLocal}repeat-once.svg`;
    readonly property string repeat: `${iconPathLocal}repeat.svg`;

    readonly property string brightness: `${iconPathLocal}sun.svg`;
    readonly property string cpu: `${iconPathLocal}cpu.svg`;
    readonly property string temp: `${iconPathLocal}thermometer-simple.svg`;

    readonly property string network_up: `${iconPathLocal}trend-up.svg`;
    readonly property string network_down: `${iconPathLocal}trend-down.svg`;

    readonly property string battery_warning: `${iconPathLocal}battery-warning-vertical.svg`;
    readonly property string battery_empty: `${iconPathLocal}battery-vertical-empty-fill.svg`;
    readonly property string battery_low: `${iconPathLocal}battery-vertical-low-fill.svg`;
    readonly property string battery_medium: `${iconPathLocal}battery-vertical-medium-fill.svg`;
    readonly property string battery_high: `${iconPathLocal}battery-vertical-high-fill.svg`;
    readonly property string battery_full: `${iconPathLocal}battery-vertical-full-fill.svg`;
    readonly property string battery_charging: `${iconPathLocal}battery-charging-vertical.svg`;


    readonly property string play: `${iconPathLocal}play-fill.svg`;
    readonly property string pause: `${iconPathLocal}pause-fill.svg`;
    readonly property string next: `${iconPathLocal}skip-forward-fill.svg`;
    readonly property string prev: `${iconPathLocal}skip-back-fill.svg`;

    readonly property string arrow_right: `${iconPathLocal}arrow-fat-right-fill.svg`;
    readonly property string arrow_left: `${iconPathLocal}arrow-fat-left-fill.svg`;


    readonly property string music_note: `${iconPathLocal}music-notes-fill.svg`;


    readonly property string headphones: `${iconPathLocal}headphones-fill.svg`;
    readonly property string speaker: `${iconPathLocal}speaker-hifi.svg`;
    readonly property string speaker_unknown: `${iconPathLocal}speaker-simple-none.svg`;
    readonly property string display: `${iconPathLocal}monitor.svg`;

    readonly property string microphone: `${iconPathLocal}microphone.svg`;
    readonly property string microphone_mute: `${iconPathLocal}microphone-slash.svg`;
}
