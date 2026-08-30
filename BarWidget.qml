import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
    id: root

    property date now: new Date()
    readonly property string horizontalFormat: String(setting("format", "ddd d MMM  HH:mm"))
    readonly property string verticalFormat: String(setting("verticalFormat", "HH\nmm"))
    readonly property string label: Qt.formatDateTime(now, vertical ? verticalFormat : horizontalFormat)
    readonly property bool opened: panelLoader.item ? panelLoader.item.opened : false
    readonly property bool popoutSwitchClosing: panelLoader.item ? panelLoader.item.popoutSwitchClosing : false
    readonly property real openPanelIndicatorWidth: root.vertical ? button.labelWidth : Math.max(1, glyphRow.contentWidth)
    readonly property real openPanelIndicatorHeight: Math.max(Style.space(10), Math.round(Style.bar.iconSlot * 0.55))
    readonly property bool reducedMotion: setting("reducedMotion", false) === true

    // previous rendered text, so a tick can roll only the changed characters
    property string prevText: label

    function injectPanel() {
        var panel = panelLoader.item;
        if (!panel)
            return ;

        panel.bar = root.bar;
        panel.settings = root.settings;
        panel.anchorItem = button;
        panel.hostWidget = root;
    }

    function open() { if (panelLoader.item) panelLoader.item.open(); }
    function close() { if (panelLoader.item) panelLoader.item.close(); }
    function toggle() { if (panelLoader.item) panelLoader.item.toggle(); }
    function closeForPopoutSwitch() { if (panelLoader.item) panelLoader.item.closeForPopoutSwitch(); }

    function rollClock() {
        var old = prevText;
        var next = root.label;
        prevText = next;
        if (reducedMotion || vertical)
            return;

        var n = Math.max(old.length, next.length);
        for (var i = 0; i < n; i++) {
            var a = i < old.length ? old.charAt(i) : "";
            var b = i < next.length ? next.charAt(i) : "";
            if (a !== b)
                glyphRow.rollAt(i);
        }
    }

    moduleName: "somnius.serpantinum-calendar"
    implicitWidth: root.vertical ? Style.bar.sizeVertical : Math.max(12, glyphRow.contentWidth + Style.spaceReal(18))
    implicitHeight: root.vertical ? root.verticalLineCount * Style.bar.iconSlot : Style.bar.sizeHorizontal
    onBarChanged: injectPanel()
    onSettingsChanged: injectPanel()

    SystemClock {
        precision: SystemClock.Minutes
        onDateChanged: root.rollClock()
    }

    Loader {
        id: panelLoader

        active: true
        visible: false
        source: Qt.resolvedUrl("CalendarPanel.qml")
        onLoaded: {
            root.injectPanel();
            Qt.callLater(root.injectPanel);
        }
    }

    IpcHandler {
        function open() { root.open(); }
        function close() { root.close(); }
        function show() { root.open(); }
        function hide() { root.close(); }
        function toggle() { root.toggle(); }
        target: root.moduleName
    }

    WidgetButton {
        id: button

        anchors.fill: parent
        bar: root.bar
        text: root.vertical ? "" : ""
        labelVisible: false
        hasVisualContent: true
        horizontalMargin: 9
        verticalPadding: 7
        tooltipText: "Open calendar"
        onPressed: function(mouseButton) {
            if (mouseButton === Qt.LeftButton)
                root.toggle();
        }
        onWheelMoved: function(delta) {
            if (!panelLoader.item)
                return;
            panelLoader.item.moveMonth(delta > 0 ? -1 : 1);
        }

        GlyphRow {
            id: glyphRow

            visible: !root.vertical
            anchors.fill: parent
            text: root.label
            fontFamily: button.fontFamily
            fontSize: button.fontSize
            color: button.foreground
            reducedMotion: root.reducedMotion
        }

        Column {
            visible: root.vertical
            anchors.fill: parent

            Repeater {
                id: vlines
                model: root.label.split("\n")

                OpticalGlyph {
                    required property string modelData
                    width: button.width
                    height: Style.bar.iconSlot
                    text: modelData
                    fontFamily: button.fontFamily
                    fontSize: modelData.length > 3 ? button.fontSize * 0.9 : button.fontSize
                    color: button.foreground
                }
            }
        }
    }

    readonly property int verticalLineCount: root.label.split("\n").length
}
