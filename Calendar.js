function positiveModulo(value, divisor) {
  return ((value % divisor) + divisor) % divisor
}

function normalizeWeekStart(value, localeFallback) {
  if (typeof value === "string") {
    var named = value.toLowerCase()
    if (named === "sunday") return 0
    if (named === "monday") return 1
    if (named === "saturday") return 6
  }
  var numeric = Number(value)
  if (isFinite(numeric) && numeric >= 0 && numeric <= 6) return Math.floor(numeric)
  var fallback = Number(localeFallback)
  // QLocale uses Qt.Monday (1) through Qt.Sunday (7), while JavaScript
  // Date.getDay() uses Sunday (0) through Saturday (6).
  if (fallback === 7) return 0
  return isFinite(fallback) && fallback >= 1 && fallback <= 6 ? Math.floor(fallback) : 1
}

function stepMonth(year, month, delta) {
  var result = new Date(year, month + delta, 1)
  return { year: result.getFullYear(), month: result.getMonth() }
}

function sameDay(a, b) {
  return a.getFullYear() === b.getFullYear()
    && a.getMonth() === b.getMonth()
    && a.getDate() === b.getDate()
}

function monthCells(year, month, weekStart, today) {
  var first = new Date(year, month, 1)
  var offset = positiveModulo(first.getDay() - weekStart, 7)
  var start = new Date(year, month, 1 - offset)
  var cells = []
  for (var index = 0; index < 42; index++) {
    var date = new Date(start.getFullYear(), start.getMonth(), start.getDate() + index)
    cells.push({
      year: date.getFullYear(),
      month: date.getMonth(),
      day: date.getDate(),
      inMonth: date.getMonth() === month && date.getFullYear() === year,
      isToday: sameDay(date, today)
    })
  }
  return cells
}

function weekdayOrder(weekStart) {
  var days = []
  for (var index = 0; index < 7; index++) days.push(positiveModulo(weekStart + index, 7))
  return days
}
