import QtQuick
import qs.Commons
import qs.Ui

// A single character slot inside a GlyphRow. On `roll()` it plays a quick
// downward roll: character dips and fades, the new character swaps in, then the
// slot settles back with a faint overshoot. In reduced-motion mode the swap is
// immediate and geometry stays put.
Item {
    id: root

    property string text: ""
    property string fontFamily: Style.font.family
    property real fontSize: Style.font.body
    property color color: Color.foreground
    property bool reducedMotion: false

    function roll() {
        if (reducedMotion)
            return;
        rollAnim.start();
    }

    readonly property real dip: Style.spaceReal(4)

    OpticalGlyph {
        id: glyph
        anchors.centerIn: parent
        text: root.text
        fontFamily: root.fontFamily
        fontSize: root.fontSize
        color: root.color
        opacity: 1
        y: 0
    }

    SequentialAnimation {
        id: rollAnim
        running: false

        ParallelAnimation {
            NumberAnimation {
                target: glyph
                property: "y"
                to: root.dip
                duration: 90
                easing.type: Easing.InQuad
            }

            NumberAnimation {
                target: glyph
                property: "opacity"
                to: 0
                duration: 90
                easing.type: Easing.InQuad
            }
        }

        PauseAnimation {
            duration: 20
        }

        ParallelAnimation {
            NumberAnimation {
                target: glyph
                property: "y"
                to: -root.dip * 0.6
                duration: 200
                easing.type: Easing.OutBack
                easing.overshoot: 0.7
            }

            NumberAnimation {
                target: glyph
                property: "opacity"
                to: 1
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

        NumberAnimation {
            target: glyph
            property: "y"
            to: 0
            duration: 260
            easing.type: Easing.OutQuint
        }
    }
}
