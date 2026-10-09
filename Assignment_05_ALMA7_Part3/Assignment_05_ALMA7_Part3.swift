// =============================================================
//  Station ALMA-7, Part III: The Repair Fleet
//  iOS Mobile Development · Module 5 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part3_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section. LegacyBeacon in
//     particular must be reached with an extension, not edited.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • The Health Rule must exist in exactly ONE place in this file.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Drone records recovered from the fleet registry.
/// One `kind` does not correspond to any drone type you will build.
let fleetData: [(kind: String, id: String, charge: Int)] = [
    (kind: "welder",  id: "W-1", charge: 80),
    (kind: "scanner", id: "S-1", charge: 45),
    (kind: "cargo",   id: "C-1", charge: 100),
    (kind: "welder",  id: "W-2", charge: 15),
    (kind: "scanner", id: "S-2", charge: 60),
    (kind: "tug",     id: "T-1", charge: 50)
]

/// Hull sensors. These are NOT drones — they never move and never work a shift.
let sensorData: [(id: String, charge: Int)] = [
    (id: "hull-cam", charge: 12),
    (id: "thermal",  charge: 77)
]

/// Hardware from the original station. You may not add anything to this
/// declaration — no methods, no protocols, no properties.
struct LegacyBeacon {
    let name: String
    let signalStrength: Int
}

let beacon = LegacyBeacon(name: "ALMA-BEACON", signalStrength: 8)

print("Fleet registry online: \(fleetData.count) drone records, \(sensorData.count) sensors, beacon \(beacon.name).")

// MARK: - ================= END OF STARTER DATA =================


// класс нужен чтобы все владельцы ячейки видели общий заряд
final class PowerCell {
    private var charge: Int

    init(charge: Int) {
        self.charge = min(max(charge, 0), 100)
    }

    func level() -> Int {
        charge
    }

    func spend(_ amount: Int) -> Bool {
        if amount <= 0 || amount > charge {
            return false
        }

        charge -= amount
        return true
    }

    func recharge(by amount: Int) {
        if amount <= 0 {
            return
        }
        charge = min(100, charge + amount)
    }
}

let cell = PowerCell(charge: 150)
print("PowerCell clamped level:", cell.level())
print("PowerCell spend test:", cell.spend(30), "level:", cell.level())
cell.recharge(by: 50)
print("PowerCell recharge test:", cell.level())

// cell.charge = 100
// ошибка charge недоступен из за private

class Drone {
    let id: String
    let cell: PowerCell

    init(id: String, cell: PowerCell) {
        self.id = id
        self.cell = cell
    }

    var powerCost: Int {
        10
    }

    var statusLine: String {
        "\(id): \(cell.level())% \(cell.level().powerBar)"
    }

    func performTask() -> Int {
        0
    }

    // final запрещает подклассам менять общий порядок выполнения
    final func runOnce() -> Int {
        if cell.spend(powerCost) == false {
            return 0
        }
        return performTask()
    }
}

final class WelderDrone: Drone {
    override var powerCost: Int {
        25
    }

    override func performTask() -> Int {
        40
    }

    func weldSeam() -> String {
        "\(id) welded a seam"
    }
}

class ScannerDrone: Drone {
    override var powerCost: Int {
        10
    }

    override var statusLine: String {
        super.statusLine + " [scanner]"
    }

    override func performTask() -> Int {
        15
    }
}

final class CargoDrone: Drone {
    override var powerCost: Int {
        20
    }

    override func performTask() -> Int {
        25
    }
}

func makeDrone(kind: String, id: String, charge: Int) -> Drone? {
    let powerCell = PowerCell(charge: charge)

    switch kind {
    case "welder":
        return WelderDrone(id: id, cell: powerCell)
    case "scanner":
        return ScannerDrone(id: id, cell: powerCell)
    case "cargo":
        return CargoDrone(id: id, cell: powerCell)
    default:
        return nil
    }
}

print("Factory test 1:", String(describing: makeDrone(kind: "welder", id: "TEST-W", charge: 50)))
print("Factory test 2:", String(describing: makeDrone(kind: "unknown", id: "TEST-X", charge: 50)))

var fleet: [Drone] = []
for record in fleetData {
    guard let drone = makeDrone(
        kind: record.kind,
        id: record.id,
        charge: record.charge
    ) else {
        print("Skipped unknown drone kind: \(record.kind), id: \(record.id)")
        continue
    }
    fleet.append(drone)
}

print("Fleet size:", fleet.count)
for drone in fleet {
    print("Created:", drone.statusLine)
}


func runShift(_ fleet: [Drone], rounds: Int) -> Int {
    if rounds <= 0 {
        return 0
    }

    var totalWork = 0
    for _ in 0..<rounds {
        for drone in fleet {
            totalWork += drone.runOnce()
        }
    }
    return totalWork
}

let A = runShift(fleet, rounds: 3)
print("Shift test 1, three rounds:", A)
print("Shift test 2, zero rounds:", runShift(fleet, rounds: 0))

var B = 0
var C = 0
for drone in fleet {
    print("After shift:", drone.statusLine)
    B += drone.cell.level()

    if drone.cell.level() >= drone.powerCost {
        C += 1
    }
}
print("Remaining total charge:", B)
print("Drones ready for one more task:", C)


protocol Diagnosable {
    var componentID: String { get }
    var statusCode: Int { get }
    func diagnose() -> String
}

protocol Rechargeable {
    mutating func recharge(by amount: Int)
}

extension Drone: Diagnosable, Rechargeable {
    var componentID: String {
        id
    }

    var statusCode: Int {
        statusCode(for: cell.level())
    }

    // класс меняет объект через ссылку поэтому mutating ему не нужен
    func recharge(by amount: Int) {
        cell.recharge(by: amount)
    }
}

struct SensorModule: Diagnosable, Rechargeable {
    let id: String
    var chargeLevel: Int

    var componentID: String {
        id
    }

    var statusCode: Int {
        statusCode(for: chargeLevel)
    }

    mutating func recharge(by amount: Int) {
        if amount > 0 {
            chargeLevel = min(100, chargeLevel + amount)
        }
    }
}

var sensors: [SensorModule] = []
for data in sensorData {
    sensors.append(SensorModule(id: data.id, chargeLevel: data.charge))
}

func diagnosticsReport(_ components: [Diagnosable]) -> String {
    var report = ""
    for component in components {
        if report.isEmpty == false {
            report += "\n"
        }
        report += component.diagnose()
    }
    return report
}

// массив drone не может хранить sensor потому что sensor является структурой
// массив протокола может хранить несвязанные классы и структуры
var components: [Diagnosable] = []
for drone in fleet {
    components.append(drone)
}
for sensor in sensors {
    components.append(sensor)
}

print("Diagnostics without beacon:")
print(diagnosticsReport(components))
print("Small diagnostics test:")
print(diagnosticsReport([sensors[0], sensors[1]]))


extension Diagnosable {
    func diagnose() -> String {
        "\(componentID): code \(statusCode)"
    }

    func statusCode(for chargeLevel: Int) -> Int {
        if chargeLevel < 20 {
            return 2
        } else if chargeLevel < 50 {
            return 1
        } else {
            return 0
        }
    }
}

extension LegacyBeacon: Diagnosable {
    var componentID: String {
        name
    }

    var statusCode: Int {
        statusCode(for: signalStrength)
    }

    func diagnose() -> String {
        "LEGACY BEACON \(componentID): code \(statusCode)"
    }
}

components.append(beacon)
print("Diagnostics with beacon:")
print(diagnosticsReport(components))

var D = 0
for component in components {
    D += component.statusCode
}
print("Status code sum:", D)

extension Int {
    var powerBar: String {
        let safeValue = Swift.min(Swift.max(self, 0), 100)
        let filledCount = safeValue / 10
        var bar = ""

        for position in 0..<10 {
            if position < filledCount {
                bar += "#"
            } else {
                bar += "."
            }
        }
        return bar
    }
}

print("Power bar test 1:", (42).powerBar)
print("Power bar test 2:", (-5).powerBar)
print("Power bar test 3:", (250).powerBar)

var rechargeableDrone = WelderDrone(id: "R-W", cell: PowerCell(charge: 20))
rechargeableDrone.recharge(by: 30)
print("Class recharge test:", rechargeableDrone.cell.level())
var rechargeableSensor = SensorModule(id: "R-S", chargeLevel: 90)
rechargeableSensor.recharge(by: 30)
print("Struct recharge test:", rechargeableSensor.chargeLevel)


// отчет один
// автор ожидал тридцать единиц работы
// метод совпадает с методом суперкласса но не имеет override
// исправление добавить override
class PatchDrone: Drone {
    override func performTask() -> Int {
        30
    }
}

let patchDrone = PatchDrone(id: "P-1", cell: PowerCell(charge: 100))
print("Report 1 fixed:", patchDrone.runOnce())

// отчет два
// автор ожидал изменить весь порядок работы
// от final класса нельзя наследоваться и final метод нельзя переопределить
// исправление наследоваться от drone и менять только стоимость и результат
final class HeavyWelder: Drone {
    override var powerCost: Int {
        40
    }

    override func performTask() -> Int {
        80
    }
}

let heavyWelder = HeavyWelder(id: "HW-1", cell: PowerCell(charge: 100))
print("Report 2 fixed:", heavyWelder.runOnce())

// отчет три
// автор ожидал вызвать метод welderdrone через значение типа drone
// тип drone не содержит этот метод
// условное приведение проверяет настоящий тип во время выполнения
// as возвращает optional потому что приведение может завершиться неудачно
let reportFleet: [Drone] = [
    WelderDrone(id: "W-9", cell: PowerCell(charge: 100))
]
let first = reportFleet[0]
if let welder = first as? WelderDrone {
    print("Report 3 fixed:", welder.weldSeam())
}

// отчет четыре
// автор ожидал получить label конкретной структуры
// метод только из extension выбирается по статическому типу
// исправление добавить метод в требования протокола
protocol Labelled {
    var componentID: String { get }
    func label() -> String
}

extension Labelled {
    func label() -> String {
        "generic component"
    }
}

struct Thruster: Labelled {
    let componentID: String

    func label() -> String {
        "thruster \(componentID)"
    }
}

let parts: [Labelled] = [Thruster(componentID: "T-1")]
print("Report 4 fixed:", parts[0].label())


let missionCode = "\(A)-\(B)-\(C)-\(D)"
print("MISSION CODE: \(missionCode)")


// вариант runtime останавливает программу если базовый метод не переопределен
class RuntimeAbstractDrone {
    func performTask() -> Int {
        fatalError("Use a concrete drone subclass")
    }
}

final class RuntimeWelderDrone: RuntimeAbstractDrone {
    override func performTask() -> Int {
        40
    }
}

let runtimeWelder = RuntimeWelderDrone()
print("Runtime abstract-style test:", runtimeWelder.performTask())
// runtimeabstractdrone performtask компилируется но завершает программу во время выполнения

// вариант compile time использует протокол который нельзя создать напрямую
protocol DroneDesign {
    var id: String { get }
    var cell: PowerCell { get }
    var powerCost: Int { get }
    func performTask() -> Int
}

extension DroneDesign {
    func runOnce() -> Int {
        if cell.spend(powerCost) == false {
            return 0
        }
        return performTask()
    }
}

struct WelderDroneValue: DroneDesign {
    let id: String
    let cell: PowerCell

    var powerCost: Int {
        25
    }

    func performTask() -> Int {
        40
    }
}

let valueWelder = WelderDroneValue(
    id: "VALUE-W",
    cell: PowerCell(charge: 100)
)
print("Protocol design test 1:", valueWelder.runOnce())
print("Protocol design test 2, remaining charge:", valueWelder.cell.level())
// dronedesign нельзя создать потому что протокол не имеет экземпляров

// класс удобен для общей identity и изменяемого состояния
// протокол объединяет классы и структуры и не создает бессмысленный базовый объект
// для этой системы подходит протокол а для общей identity подходит класс

/*
ответ один
класс меняет свойства объекта через ссылку обычным методом
структура является значением поэтому изменяющему методу нужен mutating

ответ два
наследование передает подклассу состояние и готовое поведение суперкласса
протокол дает общий интерфейс несвязанным классам структурам и перечислениям

ответ три
final у класса запрещает наследование
final у метода запрещает переопределение
final у runonce сохраняет единый безопасный порядок расхода энергии

ответ четыре
label не был требованием протокола поэтому выбирался метод extension
после добавления требования вызывается реализация конкретного типа
*/
