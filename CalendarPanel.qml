import "Calendar.js" as Calendar
import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

Panel {
    id: root

    property var anchorItem: null
    property var hostWidget: null
    property date today: new Date()
    property int viewYear: today.getFullYear()
    property int viewMonth: today.getMonth()
    property int animationDirection: 1
    readonly property var barIdentity: hostWidget || root
    readonly property string localeName: String(setting("locale", ""))
    readonly property var displayLocale: localeName.length > 0 ? Qt.locale(localeName) : Qt.locale()
    readonly property int weekStart: Calendar.normalizeWeekStart(setting("weekStart", "locale"), displayLocale.firstDayOfWeek)
    readonly property bool reducedMotion: setting("reducedMotion", false) === true
    readonly property var weekdayNumbers: Calendar.weekdayOrder(weekStart)
    readonly property var cells: Calendar.monthCells(viewYear, viewMonth, weekStart, today)
    readonly property bool viewingToday: viewYear === today.getFullYear() && viewMonth === today.getMonth()
    readonly property color foreground: bar ? bar.foreground : Color.foreground
    readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family

    function refreshToday() {
        today = new Date();
    }

    function goToToday() {
        animationDirection = viewYear * 12 + viewMonth < today.getFullYear() * 12 + today.getMonth() ? 1 : -1;
        viewYear = today.getFullYear();
        viewMonth = today.getMonth();
        monthEntrance.restart();
    }

    function moveMonth(delta) {
        var next = Calendar.stepMonth(viewYear, viewMonth, delta);
        animationDirection = delta < 0 ? -1 : 1;
        viewYear = next.year;
        viewMonth = next.month;
        monthEntrance.restart();
    }

    function open() {
        refreshToday();
        controller.show();
        stagedEnter.restart();
    }

    function close() {
        controller.hide();
    }

    function toggle() {
        opened ? close() : open();
    }

    function switchPanel(direction) {
        return bar && typeof bar.switchPanelFrom === "function" ? bar.switchPanelFrom(barIdentity, direction) : false;
    }

    moduleName: "somnius.serpantinum-calendar"
    ipcTarget: moduleName
    manageIpc: false

    SystemClock {
        precision: SystemClock.Minutes
        onDateChanged: root.refreshToday()
    }

    SequentialAnimation {
        id: monthEntrance

        running: false

        PropertyAction {
            target: monthBody
            property: "opacity"
            value: root.reducedMotion ? 1 : 0
        }

        PropertyAction {
            target: monthBody
            property: "x"
            value: root.reducedMotion ? 0 : root.animationDirection * Style.space(18)
        }

        ParallelAnimation {
            NumberAnimation {
                target: monthBody
                property: "opacity"
                to: 1
                duration: root.reducedMotion ? 0 : 180
                easing.type: Easing.OutCubic
            }

            NumberAnimation {
                target: monthBody
                property: "x"
                to: 0
                duration: root.reducedMotion ? 0 : 240
                easing.type: Easing.OutBack
                easing.overshoot: 0.45
            }

        }

    }

    // Staged layered entrance. Each semantic region (header, weekday row,
    // day grid, footer) enters in a short cascade so the panel reads as a
    // sequence of arrivals rather than one blunt fade. Overlapping tails keep
    // the cascade fluid. Reduced motion collapses it to a single brief fade.
    SequentialAnimation {
        id: stagedEnter

        running: false

        ScriptAction {
            script: {
                headerRegion.opacity = root.reducedMotion ? 1 : 0;
                headerRegion.translate.y = root.reducedMotion ? 0 : Style.space(10);
                weekdayRow.opacity = root.reducedMotion ? 1 : 0;
                weekdayRow.translate.y = root.reducedMotion ? 0 : Style.space(8);
                dayGrid.opacity = root.reducedMotion ? 1 : 0;
                dayGrid.translate.y = root.reducedMotion ? 0 : Style.space(8);
                todayRegion.opacity = root.reducedMotion ? (root.viewingToday ? 0.45 : 1) : 0;
                todayRegion.translate.y = root.reducedMotion ? 0 : Style.space(8);
            }
        }

        ParallelAnimation {
            SequentialAnimation {
                ParallelAnimation {
                    NumberAnimation {
                        target: headerRegion
                        property: "opacity"
                        to: 1
                        duration: root.reducedMotion ? 0 : 220
                        easing.type: Easing.OutCubic
                    }

                    NumberAnimation {
                        target: headerRegion
                        property: "translate.y"
                        to: 0
                        duration: root.reducedMotion ? 0 : 260
                        easing.type: Easing.OutBack
                        easing.overshoot: 0.6
                    }

                }

            }

            SequentialAnimation {
                PauseAnimation {
                    duration: root.reducedMotion ? 0 : 60
                }

                ParallelAnimation {
                    NumberAnimation {
                        target: weekdayRow
                        property: "opacity"
                        to: 1
                        duration: root.reducedMotion ? 0 : 220
                        easing.type: Easing.OutCubic
                    }

                    NumberAnimation {
                        target: weekdayRow
                        property: "translate.y"
                        to: 0
                        duration: root.reducedMotion ? 0 : 240
                        easing.type: Easing.OutCubic
                    }

                }

            }

            SequentialAnimation {
                PauseAnimation {
                    duration: root.reducedMotion ? 0 : 120
                }

                ParallelAnimation {
                    NumberAnimation {
                        target: dayGrid
                        property: "opacity"
                        to: 1
                        duration: root.reducedMotion ? 0 : 260
                        easing.type: Easing.OutCubic
                    }

                    NumberAnimation {
                        target: dayGrid
                        property: "translate.y"
                        to: 0
                        duration: root.reducedMotion ? 0 : 300
                        easing.type: Easing.OutBack
                        easing.overshoot: 0.55
                    }

                }

            }

            SequentialAnimation {
                PauseAnimation {
                    duration: root.reducedMotion ? 0 : 180
                }

                ParallelAnimation {
                    NumberAnimation {
                        target: todayRegion
                        property: "opacity"
                        to: root.viewingToday ? 0.45 : 1
                        duration: root.reducedMotion ? 0 : 220
                        easing.type: Easing.OutCubic
                    }

                    NumberAnimation {
                        target: todayRegion
                        property: "translate.y"
                        to: 0
                        duration: root.reducedMotion ? 0 : 240
                        easing.type: Easing.OutCubic
                    }

                }

            }

        }

    }

    KeyboardPanel {
        id: popup

        anchorItem: root.anchorItem
        owner: root.barIdentity
        bar: root.bar
        open: root.opened
        centerOnBar: true
        focusTarget: keys
        contentWidth: fittedContentWidth(Style.space(410))
        contentHeight: fittedContentHeight(content.implicitHeight)

        PanelKeyCatcher {
            id: keys

            anchors.fill: parent
            onMoveRequested: function(dx, dy) {
                if (dx !== 0)
                    root.moveMonth(dx);
                else if (dy !== 0)
                    root.moveMonth(dy * 12);
            }
            onActivateRequested: root.goToToday()
            onCloseRequested: root.close()
            onTabRequested: function(direction) {
                root.switchPanel(direction);
            }
            onTextKey: function(text) {
                if (text === "t" || text === "T")
                    root.goToToday();

            }

            Column {
                id: content

                width: parent.width
                spacing: Style.space(12)

                Row {
                    id: headerRegion

                    width: parent.width
                    height: Style.space(48)

                    Rectangle {
                        width: Style.space(42)
                        height: parent.height
                        radius: Math.max(0, Style.cornerRadius)
                        color: previousMouse.containsMouse ? Style.hoverFillFor(root.foreground, Color.accent) : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "‹"
                            color: root.foreground
                            font.family: root.fontFamily
                            font.pixelSize: Style.font.title
                        }

                        MouseArea {
                            id: previousMouse

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.moveMonth(-1)
                        }

                    }

                    Text {
                        width: parent.width - Style.space(84)
                        anchors.verticalCenter: parent.verticalCenter
                        text: displayLocale.standaloneMonthName(root.viewMonth + 1, Locale.LongFormat) + " " + root.viewYear
                        color: root.foreground
                        font.family: root.fontFamily
                        font.pixelSize: Style.font.title
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Rectangle {
                        width: Style.space(42)
                        height: parent.height
                        radius: Math.max(0, Style.cornerRadius)
                        color: nextMouse.containsMouse ? Style.hoverFillFor(root.foreground, Color.accent) : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "›"
                            color: root.foreground
                            font.family: root.fontFamily
                            font.pixelSize: Style.font.title
                        }

                        MouseArea {
                            id: nextMouse

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.moveMonth(1)
                        }

                    }

                }

                Item {
                    id: monthViewport

                    width: parent.width
                    height: weekdayRow.height + Style.space(6) + dayGrid.height
                    clip: true

                    Column {
                        id: monthBody

                        width: parent.width
                        spacing: Style.space(6)

                        Row {
                            id: weekdayRow

                            width: parent.width

                            Repeater {
                                model: root.weekdayNumbers

                                Text {
                                    required property int modelData

                                    width: weekdayRow.width / 7
                                    text: String(root.displayLocale.dayName(modelData === 0 ? 7 : modelData, Locale.ShortFormat)).slice(0, 2).toUpperCase()
                                    color: root.foreground
                                    opacity: 0.58
                                    font.family: root.fontFamily
                                    font.pixelSize: Style.font.caption
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                }

                            }

                        }

                        Grid {
                            id: dayGrid

                            width: parent.width
                            columns: 7

                            Repeater {
                                model: root.cells

                                Item {
                                    required property var modelData

                                    width: dayGrid.width / 7
                                    height: Style.space(42)
                                    scale: root.reducedMotion ? 1 : (root.opened ? 1 : 0.86)

                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: Style.space(34)
                                        height: width
                                        radius: width / 2
                                        color: modelData.isToday ? Color.accent : "transparent"
                                        border.width: modelData.isToday ? 1 : 0
                                        border.color: root.foreground
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.day
                                        color: modelData.isToday ? Color.background : root.foreground
                                        opacity: modelData.inMonth || modelData.isToday ? 1 : 0.28
                                        font.family: root.fontFamily
                                        font.pixelSize: Style.font.body
                                        font.bold: modelData.isToday
                                    }

                                    Behavior on scale {
                                        NumberAnimation {
                                            duration: root.reducedMotion ? 0 : 220
                                            easing.type: Easing.OutBack
                                        }

                                    }

                                }

                            }

                        }

                    }

                }

                Rectangle {
                    id: todayRegion

                    anchors.horizontalCenter: parent.horizontalCenter
                    width: todayLabel.implicitWidth + Style.space(24)
                    height: Style.space(34)
                    radius: height / 2
                    color: todayMouse.containsMouse ? Style.hoverFillFor(root.foreground, Color.accent) : "transparent"
                    opacity: root.viewingToday ? 0.45 : 1
                    enabled: !root.viewingToday

                    Text {
                        id: todayLabel

                        anchors.centerIn: parent
                        text: "Today · " + root.displayLocale.toString(root.today, "d MMMM")
                        color: root.foreground
                        font.family: root.fontFamily
                        font.pixelSize: Style.font.caption
                        font.bold: true
                    }

                    MouseArea {
                        id: todayMouse

                        anchors.fill: parent
                        hoverEnabled: parent.enabled
                        cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: root.goToToday()
                    }

                }

            }

        }

    }

}
