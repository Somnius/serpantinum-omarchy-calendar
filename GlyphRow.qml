import QtQuick
import qs.Commons
import qs.Ui

// A horizontal row of per-character OpticalGlyph slots. When `text` changes,
// each slot whose character differs plays a short downward roll (fade out,
// swap, settle back with a faint overshoot) while unchanged characters hold
// still. Performs no repeat timers; it animates only on an actual character
// change. Exposes `rollAt(index)` so the host can choose which slots roll.
Item {
    id: self

    property string text: ""
    property string fontFamily: Style.font.family
    property real fontSize: Style.font.body
    property color color: Color.foreground
    property bool reducedMotion: false

    readonly property real paintedWidth: layout.childrenRect.width

    // Total painted width of the row, for widget/indicator sizing.
    readonly property real contentWidth: layout.childrenRect.width

    function rollAt(index) {
        var item = repeater.itemAt(index);
        if (item)
            item.roll();
    }

    function charAt(i) {
        return i < self.text.length ? self.text.charAt(i) : "";
    }

    Row {
        id: layout
        anchors.centerIn: parent
        spacing: 0

        Repeater {
            id: repeater
            model: self.text.length

            delegate: GlyphSlot {
                required property int index

                width: self.slotWidth(self.charAt(index))
                height: Style.bar.iconSlot
                text: self.charAt(index)
                fontFamily: self.fontFamily
                fontSize: self.fontSize
                color: self.color
                reducedMotion: self.reducedMotion
            }
        }
    }

    function slotWidth(ch) {
        if (ch === " ")
            return Style.spaceReal(6);
        m.text = ch;
        return m.tightBoundingRect.width + 1;
    }

    TextMetrics {
        id: m
        font.family: self.fontFamily
        font.pixelSize: Math.max(1, Math.round(self.fontSize))
    }
}
