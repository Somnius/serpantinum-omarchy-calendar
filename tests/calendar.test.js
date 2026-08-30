const assert = require("node:assert/strict")
const fs = require("node:fs")
const vm = require("node:vm")

const source = fs.readFileSync(new URL("../Calendar.js", `file://${__dirname}/`), "utf8")
const calendar = {}
vm.createContext(calendar)
vm.runInContext(source, calendar)

assert.equal(calendar.stepMonth(2025, 11, 1).year, 2026)
assert.equal(calendar.stepMonth(2025, 11, 1).month, 0)
assert.equal(calendar.stepMonth(2025, 0, -1).year, 2024)
assert.equal(calendar.stepMonth(2025, 0, -1).month, 11)
assert.deepEqual(Array.from(calendar.weekdayOrder(1)), [1, 2, 3, 4, 5, 6, 0])
assert.equal(calendar.normalizeWeekStart("sunday", 1), 0)
assert.equal(calendar.normalizeWeekStart("locale", 6), 6)
assert.equal(calendar.normalizeWeekStart("locale", 7), 0)

const leap = calendar.monthCells(2024, 1, 1, new Date(2024, 1, 29))
assert.equal(leap.length, 42)
assert.equal(leap.filter(cell => cell.inMonth).length, 29)
assert.equal(leap.filter(cell => cell.isToday).length, 1)

const sunday = calendar.monthCells(2026, 2, 0, new Date(2026, 2, 1))
assert.equal(sunday[0].day, 1)
assert.equal(sunday[0].isToday, true)

console.log("calendar model tests passed")
