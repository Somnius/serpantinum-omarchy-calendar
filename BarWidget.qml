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
    readonly property real openPanelIndicatorWidth: button.labelWidth
    readonly property real openPanelIndicatorHeight: Math.max(Style.space(10), Math.round(Style.bar.iconSlot * 0.55))

    function injectPanel() {
        var panel = panelLoader.item;
        if (!panel)
            return ;

        panel.bar = root.bar;
        panel.settings = root.settings;
        panel.anchorItem = button;
        panel.hostWidget = root;
    }

    function open() {
        if (panelLoader.item)
            panelLoader.item.open();

    }

    function close() {
        if (panelLoader.item)
            panelLoader.item.close();

    }

    function toggle() {
        if (panelLoader.item)
            panelLoader.item.toggle();

    }

    function closeForPopoutSwitch() {
        if (panelLoader.item)
            panelLoader.item.closeForPopoutSwitch();

    }

    moduleName: "somnius.serpantinum-calendar"
    implicitWidth: button.implicitWidth
    implicitHeight: button.implicitHeight
    onBarChanged: injectPanel()
    onSettingsChanged: injectPanel()

    SystemClock {
        precision: SystemClock.Minutes
        onDateChanged: root.now = date
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
        function open() {
            root.open();
        }

        function close() {
            root.close();
        }

        function show() {
            root.open();
        }

        function hide() {
            root.close();
        }

        function toggle() {
            root.toggle();
        }

        target: root.moduleName
    }

    WidgetButton {
        id: button

        anchors.fill: parent
        bar: root.bar
        text: root.label
        horizontalMargin: 9
        verticalPadding: 7
        fixedHeight: root.vertical ? Math.max(Style.bar.iconSlot * 2, implicitHeight) : -1
        tooltipText: "Open calendar"
        onPressed: function(mouseButton) {
            if (mouseButton === Qt.LeftButton)
                root.toggle();

        }
        onWheelMoved: function(delta) {
            if (!panelLoader.item)
                return ;

            panelLoader.item.moveMonth(delta > 0 ? -1 : 1);
        }
    }

}
