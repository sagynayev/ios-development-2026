// =============================================================
//  Station ALMA-7: Rescue Protocol
//  iOS Mobile Development · Module 3 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER CODE section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Use the exact function names from the assignment PDF.
// =============================================================


// MARK: - =================== STARTER CODE ===================
// MARK: - Do not modify anything in this section

typealias Reading = (sensor: String, value: Int)

/// Splits a string at the first occurrence of the separator.
/// splitOnce("O2:87", by: ":") -> ("O2", "87")
/// splitOnce("hello", by: ":") -> nil
func splitOnce(_ line: String, by separator: Character) -> (String, String)? {
    guard let index = line.firstIndex(of: separator) else { return nil }
    let left = String(line[..<index])
    let right = String(line[line.index(after: index)...])
    return (left, right)
}

let rawLog = [
    "O2:87", "TEMP:-12", "O2:9x", "PRESS:101", "TEMP:abc", "O2:",
    "RAD:3", "O2:64", ":55", "TEMP:31", "PRESS:98", "O2:71",
    "RAD:-1", "TEMP:4", "PRESS:1o2", "O2:90"
]

class Tank {
    var level: Int
    init(level: Int) { self.level = level }
}

class Module {
    let name: String
    var oxygenTank: Tank?
    init(name: String, oxygenTank: Tank?) {
        self.name = name
        self.oxygenTank = oxygenTank
    }
}

class CrewMember {
    let name: String
    let role: String
    let priority: Int      // 1 = evacuated first
    var module: Module?    // nil = in open space
    init(name: String, role: String, priority: Int, module: Module?) {
        self.name = name
        self.role = role
        self.priority = priority
        self.module = module
    }
}

let lab  = Module(name: "Lab",  oxygenTank: Tank(level: 40))
let hab  = Module(name: "Hab",  oxygenTank: Tank(level: 12))
let dock = Module(name: "Dock", oxygenTank: nil)

let crew = [
    CrewMember(name: "Timur",   role: "Engineer",  priority: 3, module: lab),
    CrewMember(name: "Dana",    role: "Scientist", priority: 4, module: dock),
    CrewMember(name: "Aigerim", role: "Commander", priority: 1, module: hab),
    CrewMember(name: "Nurlan",  role: "Pilot",     priority: 2, module: nil)
]

var roster: [String: CrewMember] = [:]
for member in crew { roster[member.name] = member }

print("ALMA-7 systems online: \(rawLog.count) log lines, \(crew.count) crew members.")

// MARK: - ================= END OF STARTER CODE =================


func parseReading(_ raw: String) -> Reading? {
    guard let parts = splitOnce(raw, by: ":"),
          !parts.0.isEmpty,
          let value = Int(parts.1),
          value >= 0 || parts.0 == "TEMP" else {
        return nil
    }

    return (sensor: parts.0, value: value)
}

func parseLog(_ lines: [String]) -> (valid: [Reading], invalidCount: Int) {
    var valid: [Reading] = []
    var invalidCount = 0

    for line in lines {
        if let reading = parseReading(line) {
            valid.append(reading)
        } else {
            invalidCount += 1
        }
    }

    return (valid: valid, invalidCount: invalidCount)
}

print("parseReading test 1:", String(describing: parseReading("O2:87")))
print("parseReading test 2:", String(describing: parseReading("TEMP:-12")))
print("parseReading test 3:", String(describing: parseReading("RAD:-1")))
print("parseReading test 4:", String(describing: parseReading(":55")))

let parsedLog = parseLog(rawLog)
print("parseLog test 1: valid = \(parsedLog.valid.count), invalid = \(parsedLog.invalidCount)")
print("parseLog test 2:", parseLog(["O2:50", "broken"]))

let A = parsedLog.invalidCount


func select(_ readings: [Reading], where isIncluded: (Reading) -> Bool) -> [Reading] {
    var selected: [Reading] = []

    for reading in readings {
        if isIncluded(reading) {
            selected.append(reading)
        }
    }

    return selected
}

func values(of readings: [Reading]) -> [Int] {
    var result: [Int] = []

    for reading in readings {
        result.append(reading.value)
    }

    return result
}

let oxygenReadings = select(parsedLog.valid) { $0.sensor == "O2" }
let temperatureReadings = select(parsedLog.valid) { $0.sensor == "TEMP" }
print("select test 1 (O2):", oxygenReadings)
print("select test 2 (TEMP):", temperatureReadings)
print("values test 1:", values(of: oxygenReadings))
print("values test 2:", values(of: temperatureReadings))

func stats(of values: [Int]) -> (min: Int, max: Int, average: Double)? {
    guard let first = values.first else {
        return nil
    }

    var minimum = first
    var maximum = first
    var sum = 0

    for value in values {
        if value < minimum {
            minimum = value
        }
        if value > maximum {
            maximum = value
        }
        sum += value
    }

    let average = Double(sum) / Double(values.count)
    return (min: minimum, max: maximum, average: average)
}

func stats(_ values: Int...) -> (min: Int, max: Int, average: Double)? {
    stats(of: values)
}

print("stats array test 1:", String(describing: stats(of: values(of: oxygenReadings))))
print("stats array test 2:", String(describing: stats(of: [])))
print("stats variadic test 1:", String(describing: stats(3, 8, 1)))
print("stats variadic test 2:", String(describing: stats()))

let oxygenAverage = stats(of: values(of: oxygenReadings))?.average ?? 0
let B = Int(oxygenAverage)

let sorted1 = parsedLog.valid.sorted(by: { (left: Reading, right: Reading) -> Bool in
    return left.value > right.value
})

let sorted2 = parsedLog.valid.sorted(by: { left, right in
    return left.value > right.value
})

let sorted3 = parsedLog.valid.sorted(by: { left, right in
    left.value > right.value
})

let sorted4 = parsedLog.valid.sorted(by: { $0.value > $1.value })
let sorted5 = parsedLog.valid.sorted { $0.value > $1.value }

let allSortsMatch = values(of: sorted1) == values(of: sorted2)
    && values(of: sorted2) == values(of: sorted3)
    && values(of: sorted3) == values(of: sorted4)
    && values(of: sorted4) == values(of: sorted5)
print("All five sorts match:", allSortsMatch)
print("Descending values:", values(of: sorted5))


func heatUp(_ t: Int) -> Int {
    t + 5
}

func coolDown(_ t: Int) -> Int {
    t - 3
}

func hold(_ t: Int) -> Int {
    t
}

func chooseProtocol(for temp: Int) -> (Int) -> Int {
    if temp < 18 {
        return heatUp
    } else if temp > 24 {
        return coolDown
    } else {
        return hold
    }
}

func runUntilStable(
    from start: Int,
    maxSteps: Int = 10
) -> (finalTemp: Int, steps: Int, isStable: Bool) {
    var temperature = start
    var steps = 0

    while (temperature < 18 || temperature > 24) && steps < maxSteps {
        let protocolFunction = chooseProtocol(for: temperature)
        temperature = protocolFunction(temperature)
        steps += 1
    }

    let isStable = temperature >= 18 && temperature <= 24
    return (finalTemp: temperature, steps: steps, isStable: isStable)
}

print("Temperature functions:", heatUp(10), coolDown(30), hold(20))
print("Chosen protocol test 1:", chooseProtocol(for: 10)(10))
print("Chosen protocol test 2:", chooseProtocol(for: 30)(30))
print("Stabilization test 1:", runUntilStable(from: 31))
print("Stabilization test 2:", runUntilStable(from: -100, maxSteps: 5))

let lowestValidValue = stats(of: values(of: parsedLog.valid))?.min ?? 0
let C = runUntilStable(from: lowestValidValue).steps


func oxygenLevel(of member: CrewMember) -> Int? {
    member.module?.oxygenTank?.level
}

func status(of member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        let location = member.module?.name ?? "open space"
        return "\(member.name): no data (\(location))"
    }

    if level < 20 {
        return "\(member.name): \(level)% CRITICAL"
    } else {
        return "\(member.name): \(level)% OK"
    }
}

print("oxygenLevel test 1:", String(describing: oxygenLevel(of: crew[0])))
print("oxygenLevel test 2:", String(describing: oxygenLevel(of: crew[3])))
for member in crew {
    print(status(of: member))
}

@discardableResult
func transferOxygen(
    from source: inout Int,
    to target: inout Int,
    amount: Int
) -> Int {
    if amount <= 0 {
        return 0
    }

    let available = min(amount, source)
    let freeSpace = max(0, 100 - target)
    let transferred = min(available, freeSpace)

    if transferred <= 0 {
        return 0
    }

    source -= transferred
    target += transferred
    return transferred
}

if let labTank = lab.oxygenTank, let habTank = hab.oxygenTank {
    let moved = transferOxygen(from: &labTank.level, to: &habTank.level, amount: 30)
    print("Main oxygen transfer:", moved)
    print("Lab = \(labTank.level), Hab = \(habTank.level)")
}

var testSource = 20
var testTarget = 95
print("Transfer test 2:", transferOxygen(from: &testSource, to: &testTarget, amount: 10))
print("Transfer test 2 levels:", testSource, testTarget)

let D = hab.oxygenTank?.level ?? 0

func evacuationOrder(
    _ names: String...,
    roster: [String: CrewMember]
) -> [String] {
    var found: [CrewMember] = []

    for name in names {
        guard let member = roster[name] else {
            print("Unknown crew member: \(name)")
            continue
        }
        found.append(member)
    }

    let orderedMembers = found.sorted { $0.priority < $1.priority }
    var orderedNames: [String] = []
    for member in orderedMembers {
        orderedNames.append(member.name)
    }
    return orderedNames
}

print("Evacuation test 1:", evacuationOrder(
    "Dana", "Ghost", "Aigerim", "Timur",
    roster: roster
))
print("Evacuation test 2:", evacuationOrder("Nurlan", "Timur", roster: roster))


// reportoxygen ломается когда у участника нет модуля
// reportoxygen ломается когда в модуле нет кислородного бака
// firstcritical ломается когда нет данных о кислороде
// firstcritical ломается когда нет критического участника
// firstcritical возвращает последнего критического участника вместо первого

func reportOxygen(for member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        return "\(member.name): no data"
    }
    return "\(member.name): \(level)%"
}

func firstCritical(in crew: [CrewMember]) -> String? {
    for member in crew {
        guard let level = oxygenLevel(of: member) else {
            continue
        }
        if level < 20 {
            return member.name
        }
    }
    return nil
}

print("Safe report test 1:", reportOxygen(for: crew[0]))
print("Safe report test 2:", reportOxygen(for: crew[3]))
print("First critical test 1:", String(describing: firstCritical(in: crew)))

let testModuleOne = Module(name: "Test 1", oxygenTank: Tank(level: 5))
let testModuleTwo = Module(name: "Test 2", oxygenTank: Tank(level: 7))
let firstTestMember = CrewMember(name: "First", role: "Test", priority: 1, module: testModuleOne)
let secondTestMember = CrewMember(name: "Second", role: "Test", priority: 2, module: testModuleTwo)
print("First critical test 2:", String(describing: firstCritical(in: [firstTestMember, secondTestMember])))


let launchCode = "\(A)-\(B)-\(C)-\(D)"
print("LAUNCH CODE: \(launchCode)")


func makeAlarm(threshold: Int) -> (Int) -> Bool {
    var alarmCount = 0

    return { oxygen in
        if oxygen < threshold {
            alarmCount += 1
            print("Alarm #\(alarmCount)")
            return true
        }
        return false
    }
}

let alarm = makeAlarm(threshold: 20)
print("Alarm result 1:", alarm(12))
print("Alarm result 2:", alarm(40))
print("Alarm result 3:", alarm(5))


/*
ответ один
guard let завершает функцию если данных нет
после проверки значение доступно до конца функции
if let ограничивает значение своим блоком

ответ два
variadic принимает отдельные аргументы
готовый массив является одним значением и автоматически не раскрывается

ответ три
inout требует отдельный доступ на запись
одну переменную нельзя одновременно передать в два изменяемых параметра

ответ четыре
слева находится optional int поэтому запасное значение тоже должно быть int
строка no data имеет другой тип

ответ пять
функция принимает int и возвращает другую функцию
возвращенная функция принимает int и возвращает int

бонус
счетчик захватывается замыканием и продолжает храниться после завершения функции
*/
