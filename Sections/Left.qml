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
    borderSize: 0.6;
    color: Colour.bg;
    tiltRight: false
    tiltStrength: 1
    implicitHeight: 50;
    //property string currentjson: "";
    property list<WorkspaceSection> workspaceSections: [];
    property list<WorkspaceSection> workspaceSectionsGarbage: [];
    property WorkspaceSection currentlyFocusedWorkspace: undefined;
    property var componentFactory: Qt.createComponent("../Dynamic/WorkspaceSection.qml");

    Text{
        id: timer;

        color: Colour.fg;
        width: 120;
        font.family: "Iosevka";
        font.pointSize: 14;
        horizontalAlignment: Text.AlignHCenter;
        signal clicked();
        onClicked: () => console.log("Open Time panel");
        Process {
            id: dateProc;
            command: ["date", "+%r"];
            running: true;
            stdout: SplitParser {
                onRead: data => timer.text = data;
            }
        }
        Timer{
            interval: 1000;
            running: true;
            repeat: true;
            onTriggered: {
                dateProc.running = true;
            }
        }
    }
    function manageWorkspaces(event) {
        console.log(`data: ${event.data}`, `name: ${event.name}`);
        if(event.name == "workspacev2"){
            var data = event.data.split(",");
            updateActiveWorkspace(data[0]);
        }else if ( event.name == "focusedmon"){
            updateActiveWorkspaceProc.running = true;
        }
        if(event.name == "destroyworkspacev2"){
            console.log("DESTROY", event.data);
            var data = event.data.split(",");
            removeWorkspace(data[0]);
        }
        if(event.name == "createworkspacev2"){
            console.log("CREATE", event.data);
            var data = event.data.split(",");
            addWorkspace(...data);
        }
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
    function updateActiveWorkspace(id){
        if(currentlyFocusedWorkspace != undefined){
            currentlyFocusedWorkspace.color = Colour.fg;
        }
        currentlyFocusedWorkspace = workspaceSections.find((child) => child.wid == id);
        if(currentlyFocusedWorkspace != undefined){
            currentlyFocusedWorkspace.color = Colour._active;
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
            children = children.slice(0, 2);
            children.push(...workspaceSections);
            _update();
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
        fillWorkspaces();
        Hyprland.rawEvent.connect(manageWorkspaces);
    }
    function fillWorkspaces() {
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
    }
    function sort(workspaces) {
        var output = [];
    }
}

