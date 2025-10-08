import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.modules.desktop
import qs.modules.services
import qs.config

PanelWindow {
    id: desktop

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    color: "transparent"

    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.namespace: "quickshell:desktop"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore

    visible: Config.desktop.enabled

    Component.onCompleted: {
        DesktopService.maxRowsHint = Qt.binding(() => iconContainer.maxRows);
    }

    Item {
        id: iconContainer
        anchors.fill: parent
        anchors.leftMargin: Config.desktop.spacing
        anchors.rightMargin: Config.desktop.spacing

        property real cellWidth: Config.desktop.iconSize + Config.desktop.spacing
        
        property int maxRows: {
            var minSpacing = 32;
            var iconHeight = Config.desktop.iconSize + 40;
            var availableHeight = parent.height;
            
            var rows = Math.floor(availableHeight / (iconHeight + minSpacing));
            console.log("Desktop maxRows calculated:", rows, "availableHeight:", availableHeight);
            return rows < 1 ? 1 : rows;
        }
        
        property real cellHeight: parent.height / maxRows
        property int maxColumns: Math.floor(width / cellWidth)

        onMaxRowsChanged: {
            console.log("Desktop grid: maxRows =", maxRows, "maxColumns =", maxColumns);
        }

        Repeater {
            model: DesktopService.items

            delegate: DesktopIcon {
                required property string name
                required property string path
                required property string type
                required property string icon
                required property bool isDesktopFile
                required property int gridX
                required property int gridY
                required property int index

                itemName: name
                itemPath: path
                itemType: type
                itemIcon: icon

                x: gridX * iconContainer.cellWidth
                y: gridY * iconContainer.cellHeight

                Behavior on x {
                    enabled: !dragging
                    NumberAnimation {
                        duration: Config.animDuration
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on y {
                    enabled: !dragging
                    NumberAnimation {
                        duration: Config.animDuration
                        easing.type: Easing.OutCubic
                    }
                }

                onPositionChanged: (newGridX, newGridY) => {
                    var clampedX = Math.max(0, Math.min(newGridX, iconContainer.maxColumns - 1));
                    var clampedY = Math.max(0, Math.min(newGridY, iconContainer.maxRows - 1));
                    
                    DesktopService.updateIconPosition(itemPath, clampedX, clampedY);
                    DesktopService.items.setProperty(index, "gridX", clampedX);
                    DesktopService.items.setProperty(index, "gridY", clampedY);
                }

                onActivated: {
                    console.log("Activated:", itemName);
                }

                onContextMenuRequested: {
                    console.log("Context menu requested for:", itemName);
                }
            }
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: 200
        height: 60
        color: Qt.rgba(0, 0, 0, 0.7)
        radius: Config.roundness
        visible: !DesktopService.initialLoadComplete

        Text {
            anchors.centerIn: parent
            text: "Loading desktop..."
            color: "white"
            font.family: Config.defaultFont
            font.pixelSize: Config.theme.fontSize
        }
    }
}
