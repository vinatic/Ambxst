import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.theme
import qs.modules.components
import qs.modules.services
import qs.config

Item {
    id: root

    required property string itemName
    required property string itemPath
    required property string itemType
    required property string itemIcon
    property bool isDesktopFile: false
    property int gridX: 0
    property int gridY: 0

    signal activated()
    signal contextMenuRequested()
    signal positionChanged(int newGridX, int newGridY)

    width: Config.desktop.iconSize + Config.desktop.spacing
    height: Config.desktop.iconSize + 40

    property bool dragging: false
    property real dragStartX: 0
    property real dragStartY: 0

    Rectangle {
        id: background
        anchors.fill: parent
        anchors.margins: 4
        color: mouseArea.containsMouse || mouseArea.pressed || root.dragging ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.3) : "transparent"
        radius: Config.roundness / 2
        
        Behavior on color {
            ColorAnimation {
                duration: Config.animDuration / 2
                easing.type: Easing.OutCubic
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        drag.target: root.dragging ? root : null
        drag.axis: Drag.XAndYAxis

        onPressed: mouse => {
            if (mouse.button === Qt.LeftButton) {
                root.dragStartX = root.x;
                root.dragStartY = root.y;
            }
        }

        onPositionChanged: mouse => {
            if (pressed && mouse.button === Qt.LeftButton && !root.dragging) {
                var distance = Math.sqrt(Math.pow(mouse.x - mouseArea.pressX, 2) + Math.pow(mouse.y - mouseArea.pressY, 2));
                if (distance > 10) {
                    root.dragging = true;
                    root.z = 1000;
                }
            }
        }

        onReleased: mouse => {
            if (root.dragging) {
                var cellWidth = Config.desktop.iconSize + Config.desktop.spacing;
                var cellHeight = Config.desktop.iconSize + 40;
                
                var newGridX = Math.round(root.x / cellWidth);
                var newGridY = Math.round(root.y / cellHeight);
                
                root.positionChanged(newGridX, newGridY);
                root.dragging = false;
                root.z = 0;
            }
        }

        onDoubleClicked: mouse => {
            if (mouse.button === Qt.LeftButton && !root.dragging) {
                root.activated();
                
                if (root.isDesktopFile) {
                    console.log("Executing desktop file:", root.itemPath);
                    DesktopService.executeDesktopFile(root.itemPath);
                } else if (root.itemType === 'folder') {
                    console.log("Opening folder:", root.itemPath);
                    DesktopService.openFile(root.itemPath);
                } else {
                    console.log("Opening file:", root.itemPath);
                    DesktopService.openFile(root.itemPath);
                }
            }
        }

        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                root.contextMenuRequested();
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 4

        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Config.desktop.iconSize
            Layout.preferredHeight: Config.desktop.iconSize

            Loader {
                anchors.centerIn: parent
                width: Config.desktop.iconSize
                height: Config.desktop.iconSize
                sourceComponent: Config.tintIcons ? tintedIconComponent : normalIconComponent
            }
        }

        Text {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            text: root.itemName
            color: Colors[Config.desktop.textColor] || Colors.overBackground
            font.family: Config.defaultFont
            font.pixelSize: Config.theme.fontSize - 2
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideRight

            Rectangle {
                anchors.fill: parent
                anchors.margins: -2
                color: Qt.rgba(0, 0, 0, 0.6)
                radius: 4
                z: -1
            }
        }
    }

    Component {
        id: normalIconComponent
        Image {
            source: "image://icon/" + root.itemIcon
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            smooth: true

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                border.color: Colors.outline
                border.width: parent.status === Image.Error ? 1 : 0
                radius: 4

                Text {
                    anchors.centerIn: parent
                    text: root.itemType === 'folder' ? "📁" : "📄"
                    visible: parent.parent.status === Image.Error
                    font.pixelSize: Config.desktop.iconSize / 2
                }
            }
        }
    }

    Component {
        id: tintedIconComponent
        Tinted {
            sourceItem: Image {
                source: "image://icon/" + root.itemIcon
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                smooth: true
            }
        }
    }
}
