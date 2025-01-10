import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQml.Models
import "../Components/" as Components
import Quickshell.Services.Mpris

Rectangle{
    id: root;
    width: 500;
    height: 1000;
    function formatTime(seconds: real): string{
        var output = "";
        var hours = Math.floor(seconds / (60*60));
        if (hours != 0){
            output = `${hours}:`;
        }
        var minutes = `0${Math.floor(seconds/60)}`.substr(-2);
        var _seconds= `0${Math.floor(seconds%60)}`.substr(-2);
        return `${output}${minutes}:${_seconds}`
    }
    color: Components.Colour.trans;
            ColumnLayout{
    Repeater{
        model: Mpris.players;
        Rectangle{
            width: root.width;
            height: childrenRect.height;
            ColumnLayout{
                property var _data: modelData;
                width: root.width;
                Text{
                    text: "player: " + parent._data.identity;
                }
                Text{
                    text: "length: " + root.formatTime(parent._data.length);
                }
                Timer{
                    running: root.visible && parent._data.isPlaying;
                    interval: 1000;
                    repeat: true;
                    onTriggered: parent._data.positionChanged();
                }
                Text{
                    text: "position: " + root.formatTime(parent._data.position);
                }
                Text{
                    text: "title: " + parent._data.trackTitle;
                }

                Text{
                    text: `rate: ${parent._data.minRate}  ${parent._data.rate}  ${parent._data.maxRate}`;
                }
                Text{
                    text: `Shuffle: ${parent._data.shuffle}`;
                }
                Text{
                    text: `Loop: ${format()}`;
                    function format(){
                        var state = parent._data.loopState;
                        if(state == MprisLoopState.None){
                            return "No looping";
                        }
                        if(state == MprisLoopState.Playlist){
                            return "Playlist loop";
                        }
                        if(state == MprisLoopState.Track){
                            return "Track loop";
                        }
                        return "what?"
                    }
                }
                Button{
                    width: 200;
                    text: format();
                    onClicked:{
                        parent._data.isPlaying = !parent._data.isPlaying;
                    }
                    function format(){
                        var state = parent._data.playbackState;
                        if(state == MprisPlaybackState.Paused){
                            return "Paused";
                        }
                        if(state == MprisPlaybackState.Playing){
                            return "playing";
                        }
                        if(state == MprisPlaybackState.Stopped){
                            return "Stopped";
                        }
                    }
                }
                Image {
                    Layout.preferredHeight: 100;
                    fillMode: Image.PreserveAspectFit;
                    horizontalAlignment: Image.AlignLeft;
                    verticalAlignment: Image.AlignTop;
                    source: parent._data.trackArtUrl != null ? parent._data.trackArtUrl : "";
                }
                Text{
                    text: "artist: " + parent._data.trackArtist;
                }

                Text{
                    text: "volume: " + parent._data.volume;
                }
            }
        }
    }
}
    Component.onCompleted: {
        log();
        Mpris.players.objectInsertedPost.connect(log);
    }
    function log(object, index){
        console.log("players:", Mpris.players.values.length);
    }
}
