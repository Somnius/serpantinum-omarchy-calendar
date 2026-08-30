# Serpantinum Calendar for Omarchy

An animated clock and month calendar that feels at home in Omarchy. It is an
unofficial clean-room implementation inspired by Serpantinum's visual energy,
not a source port. See [NOTICE.md](NOTICE.md) for provenance and rights notes.

## What it does

- Shows a configurable date/time label in horizontal or vertical Omarchy bars.
- Opens a theme-aware, animated six-week month grid.
- Navigates months with buttons, the mouse wheel, or Left/Right (and `h`/`l`).
- Navigates years with Up/Down (and `k`/`j`).
- Returns to today with Enter, Space, `t`, or the Today button.
- Uses the configured locale for month/day names and the locale's normal first
  weekday by default.
- Can disable its decorative motion with `reducedMotion`.

## Requirements

Omarchy Quattro 4.x with its bundled Quickshell shell. There are **no extra
packages, services, fonts, scripts, or network dependencies**. The plugin
deliberately reuses the `qs.Ui`, `qs.Commons`, Quickshell clock, theme, popup,
keyboard, and bar facilities already installed by Omarchy.

## Install

Once this repository is published, use Omarchy's plugin manager:

```sh
omarchy plugin add https://github.com/Somnius/serpantinum-omarchy-calendar --enable
```

During local development, validate this checkout and then install it using the
local workflow supported by your installed `omarchy plugin --help`. Do not copy
files into `/usr/share/omarchy`; that directory belongs to the Omarchy package.

Move the enabled widget if desired; its installed user-owned files hot-reload:

```sh
omarchy bar move somnius.serpantinum-calendar --section center
```

## Configuration

Settings are inline fields on this widget's entry in
`~/.config/omarchy/shell.json`. Omarchy owns and reloads that file. Example:

```json
{
  "id": "somnius.serpantinum-calendar",
  "format": "ddd d MMM  HH:mm",
  "verticalFormat": "HH\nmm",
  "locale": "en_GB",
  "weekStart": "locale",
  "reducedMotion": false
}
```

| Setting | Default | Meaning |
|---|---|---|
| `format` | `ddd d MMM  HH:mm` | Qt date/time format for a horizontal bar. |
| `verticalFormat` | `HH\nmm` | Qt date/time format for a vertical bar. |
| `locale` | empty | Locale name such as `en_GB`; empty uses the desktop locale. |
| `weekStart` | `locale` | `locale`, `sunday`, `monday`, `saturday`, or weekday number `0`–`6`. |
| `reducedMotion` | `false` | Removes month entrance and day scaling animation. |

Invalid `weekStart` values safely fall back to the selected locale. Qt controls
the accepted locale names and date/time format tokens.

## Controls

| Input | Action |
|---|---|
| Left click clock | Open or close calendar |
| Wheel on clock | Previous or next month |
| Left/Right or `h`/`l` | Previous or next month |
| Up/Down or `k`/`j` | Previous or next year |
| Enter, Space, or `t` | Return to today |
| Escape | Close |
| Tab / Shift+Tab | Switch between compatible open bar panels |

## Development and verification

```sh
omarchy plugin validate .
node tests/calendar.test.js
qmllint -I /usr/share/omarchy/shell BarWidget.qml CalendarPanel.qml
```

The JavaScript test covers year boundaries, weekday ordering, leap February,
today marking, and Sunday-start alignment. Visual and lifecycle testing still
requires a live Omarchy shell: open/close repeatedly, navigate across years,
test horizontal and vertical bars, change themes and scale, enable reduced
motion, and verify outside-click dismissal and panel switching.

## Status

This is an early calendar-core release. It intentionally excludes weather,
diary, school schedules, network access, and external commands. Those concerns
do not belong in the smallest dependable calendar plugin.

## License

The independently written plugin code is MIT licensed. The Serpantinum projects
and their assets are not bundled or relicensed. Read [NOTICE.md](NOTICE.md)
before contributing or redistributing.
