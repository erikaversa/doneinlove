pragma Singleton
import QtQuick 2.15

QtObject {
    // Colours
    readonly property color background:     "#f9f9f8"
    readonly property color surface:        "#ffffff"
    readonly property color primary:        "#1a1a18"
    readonly property color muted:          "#6b6a65"
    readonly property color border:         "#e5e3de"
    readonly property color accent:         "#7F77DD"
    readonly property color danger:         "#E24B4A"
    readonly property color success:        "#1D9E75"

    // Typography
    readonly property string fontFamily:    "system-ui"
    readonly property int fontSizeSmall:    12
    readonly property int fontSizeBody:     14
    readonly property int fontSizeLarge:    18
    readonly property int fontSizeTitle:    22

    // Spacing
    readonly property int spacingXS:        4
    readonly property int spacingS:         8
    readonly property int spacingM:         16
    readonly property int spacingL:         24
    readonly property int spacingXL:        40

    // Radius
    readonly property int radiusS:          6
    readonly property int radiusM:          8
    readonly property int radiusL:          12
}
