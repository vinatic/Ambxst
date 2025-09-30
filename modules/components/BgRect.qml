import QtQuick
import Quickshell.Widgets
import qs.modules.theme
import qs.config
import qs.modules.components

Rectangle {
    color: Colors.background
    radius: Config.roundness
    border.color: Colors[Config.theme.borderColor] || Colors.surfaceBright
    border.width: Config.theme.borderSize

    layer.enabled: true
    layer.effect: Shadow {}
}
