import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle{
    id: root;
    color: "#00000000";
    height: 80;
    required property string backgroundColor;
    required property string textColor;
    required property string barColor;
    required property string emptyColor;
    required property string overShootColor;
    required property real overShootLocation;
    required property real stepSize;
    property alias value: slider.value;
    property alias from: slider.from;
    property alias to: slider.to;
    signal moved();
    required property string textLeft;
    required property string textRight;
    property string textPressed: "";
    required property string font;
    required property real textSizeBottom;
    required property real textSizePressed;
    property bool disableBars: false;
    component LineBehavior: Behavior{
        PropertyAnimation{
            duration: 200;
            easing.type: Easing.InOutQuad;
        }
    }
    Rectangle{
        implicitWidth: 30;
        implicitHeight: 20;
        radius: 5;
        y: slider.y - height;
        x: slider.handle.x - slider.handle.width/2;
        color: root.backgroundColor;
        visible: slider.pressed && root.textPressed != "";
        Text {
            anchors.centerIn: parent;
            font.pointSize: root.textSizePressed;
            color: root.textColor;
            font.family: root.font;
            text: root.textPressed;
        }
    }
    Slider{
        id: slider;
        width: root.width;
        height: 10;
        anchors.verticalCenter: parent.verticalCenter;
        anchors.horizontalCenter: parent.horizontalCenter;
        snapMode: root.stepSize == 0 ? Slider.NoSnap : Slider.SnapAlways;
        stepSize: root.stepSize;
        onMoved: {
            root.moved();
        }
        background: Rectangle{
            x: slider.leftPaddingChanged;
            y: slider.topPadding + slider.availableHeight /2 - height /2;
            implicitHeight: 5;
            implicitWidth: 200;
            width: slider.availableWidth;
            height: slider.availableHeight;
            radius: 5;
            color: Colour.trans;
            Rectangle{
                height: parent.height;
                width: parent.width /3 * 2;
                x: 0;
                color: root.emptyColor;
                bottomLeftRadius: parent.radius;
                topLeftRadius: parent.radius;
            }
            Rectangle{
                height: parent.height;
                property real shift: 0.2;
                width: parent.width /3 * (1 + shift) - slider.handle.width/2;
                x: parent.width /3 * (2 - shift) + slider.handle.width/2;
                gradient: Gradient{
                    orientation: Gradient.Horizontal;
                    GradientStop{ position: 0.0; color: root.emptyColor}
                    GradientStop{ position: 0.4; color: root.overShootColor}
                    GradientStop{ position: 1.0; color: root.overShootColor}
                }
                bottomRightRadius: parent.radius;
                topRightRadius: parent.radius;
            }
            Rectangle{
                height: parent.height;
                width: slider.handle.x + slider.handle.width/2;
                x: 0;
                color: root.barColor;
                bottomLeftRadius: parent.radius;
                topLeftRadius: parent.radius;
            }
            Rectangle{
                height: parent.height;
                width: parent.width;
                x: 0;
                border.width: 1;
                border.color: root.barColor;
                color: Colour.trans;
                radius: parent.radius;
            }
            Repeater{
                id: lines;
                property int steps: (slider.to - slider.from) / slider.stepSize;
                model: root.stepSize == 0 || disableBars ? 0 : (steps + 1);
                Rectangle{
                    required property int index;
                    property int extra: index % Math.round(lines.steps/3*2) == 0? 3 : 0;
                    property int selectedExtra: 5;
                    width: 2;
                    implicitHeight: index % 5 == 0 ? 8: 5;
                    height: (Math.round(lines.steps*slider.position) == index ? implicitHeight + selectedExtra : implicitHeight) + extra;
                    color: Math.round(lines.steps*slider.position) >= index ? root.barColor : root.overShootColor;
                    LineBehavior on color{}
                    LineBehavior on height{}
                    x: (parent.width - slider.handle.width) / lines.steps * index + slider.handle.width/2;
                    y: parent.y + parent.height + 3;
                }
            }

        }
        handle: Rectangle{
            implicitWidth: 10;
            implicitHeight: 10;
            color: root.barColor;
            border.width: 1;
            border.color: root.emptyColor;
            height: implicitHeight + 4;
            width: implicitWidth + 4;
            anchors.verticalCenter: slider.verticalCenter;
            radius: 10;
            x: (slider.width - width) * slider.position + 0.5;
        }
    }
    Text {
        visible: root.textLeft != "";
        anchors.bottom: parent.bottom;
        //y: slider.y + slider.height + 20;
        color: root.textColor;
        font.family: root.font;
        text: root.textLeft;
    }
    Text {
        visible: root.textRight != "";
        anchors.right: parent.right;
        anchors.bottom: parent.bottom;
        //y: slider.y + slider.height + 20;
        color: root.textColor;
        font.family: root.font;
        text: root.textRight;
    }
}
