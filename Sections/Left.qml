import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../Components/"
import "../Dynamic/"
import Quickshell.Hyprland

ButtonStrip{
    id: leftPanel;
    anchors.left: parent.left;
    borderColor: Colour.accent;
    borderSize: 1;
    color: Colour.bg;
    tiltRight: false;
    tiltStrength: 1;
    implicitHeight: 50;
    //property string currentjson: "";
    property list<WorkspaceSection> workspaceSections: [];
    property list<WorkspaceSection> workspaceSectionsGarbage: [];
    property var currentlyFocusedWorkspace: undefined;
    //used to generate workspace sections.
    property var componentFactory: Qt.createComponent("../Dynamic/WorkspaceSection.qml");
    function convertPopoutPosition(xpos: int): int{
        //-15 because thats the popout windows corner.
        return shift + xpos -15;
    }

    innerChildren: [
        Text{
            id: timer;
            color: Colour.fg;
            width: 120;
            font.family: "Iosevka";
            font.pointSize: 14;
            text: `${`0${GlobalState.clock.hours%12 == 0 ? 12 : GlobalState.clock.hours%12 }`.substr(-2)}:${`0${GlobalState.clock.minutes}`.substr(-2)} ${GlobalState.clock.hours >=12 ? "PM" : "AM"}`;
            horizontalAlignment: Text.AlignHCenter;
            signal clicked();
            onClicked: () => GlobalState.popupLeft("time", leftPanel.convertPopoutPosition(x));
        }
    ]
    function manageWorkspaces(event) {
        if(event.name == "workspacev2"){
            var data = event.data.split(",");
            updateActiveWorkspace(data[0]);
        }else if ( event.name == "focusedmon"){
            updateActiveWorkspaceProc.running = true;
        }
        if(event.name == "destroyworkspacev2"){
            var data = event.data.split(",");
            removeWorkspace(data[0]);
        }
        if(event.name == "createworkspacev2"){
            var data = event.data.split(",");
            addWorkspace(...data);
        }
    }
    function updateActiveWorkspace(id){
        if(currentlyFocusedWorkspace != undefined){
            currentlyFocusedWorkspace.color = Colour.fg;
        }
        var temp = workspaceSections.find((child) => child.wid == id);
        if (temp != undefined){
            currentlyFocusedWorkspace = temp;
            if(currentlyFocusedWorkspace != undefined){
                currentlyFocusedWorkspace.color = Colour._active;
            }
        }
    }
    function removeWorkspace(workspace_id: int) {
        var index = workspaceSections.findIndex((child) => child.wid == workspace_id);
        if (index != -1){
            workspaceSectionsGarbage.push(workspaceSections[index]);
            var shallow = workspaceSections.filter((child) => child.wid != workspace_id);
            workspaceSections = shallow;
            updateWorkspaces();
        }
    }
    function addWorkspace(workspace_id: int, workspace_name) {
        var element = componentFactory.createObject();
        element.color = Colour.fg;
        element.width = 25;
        element.text = workspace_name;
        element.wid = workspace_id;
        element.wname = workspace_name;
        var insertindex = workspaceSections.findIndex((child) => child.wid > element.wid);
        workspaceSections.splice(insertindex, 0, element);
        updateWorkspaces();
    }
    function updateWorkspaces(commited = false){
        if(commited){
            var firstWorkspaceIndex=innerChildren.findIndex((child) => child instanceof WorkspaceSection);
            if(firstWorkspaceIndex != -1){
                innerChildren = innerChildren.slice(0, firstWorkspaceIndex);
            }
            innerChildren.push(...workspaceSections);
            workspaceSectionsGarbage.forEach((child) => child.destroy());
            workspaceSectionsGarbage = [];
        }else{
            redrawCommitment.running = true;
        }
    }
    Timer{
        id: redrawCommitment
        interval: 40;
        running: false;
        onTriggered: updateWorkspaces(true);
    }
    Component.onCompleted: {
        Hyprland.rawEvent.connect(manageWorkspaces);
        //for some reason I need to delay it. otherwise workspaces read from Hyprland is 0.
        //fillWorkspaces();
        workspaceFillTimer.running = true;
    }
    Timer{
        id: workspaceFillTimer;
        interval: 40;
        running: false;
        onTriggered: leftPanel.fillWorkspaces();
        
    }
    function fillWorkspaces() {
        Hyprland.refreshWorkspaces();
        var workspaces = Hyprland.workspaces.values;
        //workspaces = workspaces.sort((a,b) => a.id - b.id);
        for (var i = 0; i < workspaces.length; i++){
            var workspace = workspaces[i];
            var element = componentFactory.createObject();
            element.width = 25;
            element.text = workspace.name;
            element.wid = workspace.id;
            element.wname = workspace.name;
            workspaceSections.push(element);
        }
        workspaceSections.sort((a,b) => a.wid - b.wid);
        updateWorkspaces(true);
        updateActiveWorkspaceProc.running = true;
    }
    function sort(workspaces) {
        var output = [];
    }
    Process {
        id: updateActiveWorkspaceProc;
        running: true;
        //command: ["hyprctl", "--instance", "0", "activeworkspace", "-j"];
        command: ["sh", "-c", "hyprctl --instance 0 activeworkspace -j | jq '.id'"];
        stdout: SplitParser {
            onRead: data => updateActiveWorkspace(data);
        }
    }
}

