import QtQuick
import QtQuick.Controls
import qs.modules.theme
import qs.config

Button {
    id: root
    property bool visibleWhen: true

    anchors.fill: parent
    hoverEnabled: true
    visible: visibleWhen

    background: Rectangle {
        color: parent.pressed ? Colors.error : (parent.hovered ? Colors.surfaceBright : Colors.surface)
        radius: Config.roundness > 0 ? Config.roundness + 4 : 0

        Behavior on color {
            ColorAnimation {
                duration: Config.animDuration
            }
        }
    }

    contentItem: Text {
        text: Icons.cancel
        font.family: Icons.font
        font.pixelSize: 16
        color: parent.pressed ? Colors.overError : (parent.hovered ? Colors.overBackground : Colors.error)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        Behavior on color {
            ColorAnimation {
                duration: Config.animDuration
            }
        }
    }
}