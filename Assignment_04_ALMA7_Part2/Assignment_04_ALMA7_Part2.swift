// =============================================================
//  Station ALMA-7, Part II: The Teleporter Incident
//  iOS Mobile Development · Module 4 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part2_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Default to struct. Use class only where the task says so.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Splits a line into fields.
/// fields("crate:101:120")            -> ["crate", "101", "120"]
/// fields("livestock:lab mice:12:2")  -> ["livestock", "lab mice", "12", "2"]
/// fields("junk")                     -> ["junk"]
func fields(_ line: String, separatedBy separator: Character = ":") -> [String] {
    var result: [String] = []
    var current = ""
    for character in line {
        if character == separator {
            result.append(current)
            current = ""
        } else {
            current.append(character)
        }
    }
    result.append(current)
    return result
}

/// Cargo manifest as recovered from the damaged recorder.
let rawManifest = [
    "crate:101:120",
    "container:KZ-ALM-7:340",
    "livestock:lab mice:12:2",
    "???-corrupted-line",
    "crate:102:75",
    "container:KZ-ALM-9:410",
    "livestock:ficus:3:5",
    "crate:103:260",
    "crate:104:abc",
    ""
]

/// Oxygen readings. One of these deck names is not a real deck.
let deckReadings: [(deck: String, oxygen: Int)] = [
    (deck: "bridge",     oxygen: 78),
    (deck: "lab",        oxygen: 64),
    (deck: "greenhouse", oxygen: 55),
    (deck: "cargo",      oxygen: 12),
    (deck: "medbay",     oxygen: 90),
    (deck: "engine",     oxygen: 41)
]

/// Crew records, straight from the personnel file.
let crewData: [(name: String, deck: String, oxygen: Int)] = [
    (name: "Timur",   deck: "engine", oxygen: 62),
    (name: "Dana",    deck: "lab",    oxygen: 48),
    (name: "Aigerim", deck: "bridge", oxygen: 91),
    (name: "Nurlan",  deck: "cargo",  oxygen: 17)
]

print("ALMA-7 recorder online: \(rawManifest.count) manifest lines, \(deckReadings.count) readings, \(crewData.count) crew records.")

// MARK: - ================= END OF STARTER DATA =================


enum Deck: String, CaseIterable {
    case bridge
    case lab
    case cargo
    case medbay
    case engine

    var evacuationPriority: Int {
        switch self {
        case .bridge:
            return 1
        case .medbay:
            return 2
        case .lab:
            return 3
        case .engine:
            return 4
        case .cargo:
            return 5
        }
    }
}

for deck in Deck.allCases {
    print("Deck \(deck.rawValue), priority \(deck.evacuationPriority)")
}

enum AlarmLevel: Int {
    case green = 0
    case yellow
    case orange
    case red

    static func level(forTotalMass mass: Int) -> AlarmLevel {
        let nonNegativeMass = max(0, mass)
        let rawLevel = min(nonNegativeMass / 500, AlarmLevel.red.rawValue)
        return AlarmLevel(rawValue: rawLevel) ?? .red
    }
}

print("Alarm test 1:", AlarmLevel.level(forTotalMass: 0))
print("Alarm test 2:", AlarmLevel.level(forTotalMass: 940))
print("Alarm test 3:", AlarmLevel.level(forTotalMass: 4000))


enum ManifestEntry {
    case crate(id: Int, massKg: Int)
    case container(code: String, massKg: Int)
    case livestock(species: String, count: Int, massPerUnitKg: Int)
    case unknown(raw: String)
}

func parseEntry(_ line: String) -> ManifestEntry {
    let parts = fields(line)
    guard let tag = parts.first else {
        return .unknown(raw: line)
    }

    switch tag {
    case "crate":
        guard parts.count == 3,
              let id = Int(parts[1]),
              let massKg = Int(parts[2]) else {
            return .unknown(raw: line)
        }
        return .crate(id: id, massKg: massKg)

    case "container":
        guard parts.count == 3,
              let massKg = Int(parts[2]) else {
            return .unknown(raw: line)
        }
        return .container(code: parts[1], massKg: massKg)

    case "livestock":
        guard parts.count == 4,
              let count = Int(parts[2]),
              let massPerUnitKg = Int(parts[3]) else {
            return .unknown(raw: line)
        }
        return .livestock(
            species: parts[1],
            count: count,
            massPerUnitKg: massPerUnitKg
        )

    default:
        return .unknown(raw: line)
    }
}

func mass(of entry: ManifestEntry) -> Int {
    switch entry {
    case let .crate(_, massKg):
        return massKg
    case let .container(_, massKg):
        return massKg
    case let .livestock(_, count, massPerUnitKg):
        return count * massPerUnitKg
    case .unknown:
        return 0
    }
}

print("Manifest parse test 1:", parseEntry("crate:101:120"))
print("Manifest parse test 2:", parseEntry("broken"))
print("Mass test 1:", mass(of: parseEntry("container:KZ-ALM-7:340")))
print("Mass test 2:", mass(of: parseEntry("livestock:lab mice:12:2")))

var manifest: [ManifestEntry] = []
var totalManifestMass = 0
var unknownEntryCount = 0

for line in rawManifest {
    let entry = parseEntry(line)
    manifest.append(entry)
    totalManifestMass += mass(of: entry)

    if case .unknown = entry {
        unknownEntryCount += 1
    }
}

print("Total manifest mass:", totalManifestMass)
print("Unknown manifest lines:", unknownEntryCount)
let A = totalManifestMass


struct CrewSnapshot {
    let name: String
    var deck: Deck
    var oxygen: Int

    mutating func breathe(_ amount: Int) {
        if amount > 0 {
            oxygen = max(0, oxygen - amount)
        }
    }

    mutating func move(to deck: Deck) {
        self.deck = deck
    }

    mutating func reviveInMedbay() {
        self = CrewSnapshot(name: name, deck: .medbay, oxygen: 100)
    }

    static func rookie(named name: String) -> CrewSnapshot {
        CrewSnapshot(name: name, deck: .bridge, oxygen: 100)
    }
}

var crewRoster: [CrewSnapshot] = []
for record in crewData {
    guard let deck = Deck(rawValue: record.deck) else {
        print("Unknown deck for \(record.name): \(record.deck)")
        continue
    }

    let snapshot = CrewSnapshot(
        name: record.name,
        deck: deck,
        oxygen: record.oxygen
    )
    crewRoster.append(snapshot)
}

print("Crew roster count:", crewRoster.count)
print("First crew snapshot:", crewRoster[0])

let originalSnapshot = crewRoster[0]
var copiedSnapshot = originalSnapshot
print("Copy test before: original \(originalSnapshot.oxygen), copy \(copiedSnapshot.oxygen)")
copiedSnapshot.breathe(10)
copiedSnapshot.move(to: .medbay)
print("Copy test after: original \(originalSnapshot.oxygen), copy \(copiedSnapshot.oxygen)")

func breathingCopy(of snapshot: CrewSnapshot, amount: Int) -> CrewSnapshot {
    var changedSnapshot = snapshot
    changedSnapshot.breathe(amount)
    return changedSnapshot
}

print("Plain parameter before:", copiedSnapshot.oxygen)
let functionResult = breathingCopy(of: copiedSnapshot, amount: 10)
print("Plain parameter result:", functionResult.oxygen)
print("Plain parameter after original:", copiedSnapshot.oxygen)

func breatheInPlace(_ snapshot: inout CrewSnapshot, amount: Int) {
    snapshot.breathe(amount)
}

print("inout before:", copiedSnapshot.oxygen)
breatheInPlace(&copiedSnapshot, amount: 10)
print("inout after:", copiedSnapshot.oxygen)

var rookie = CrewSnapshot.rookie(named: "Rookie")
print("Rookie before revive:", rookie)
rookie.breathe(60)
rookie.reviveInMedbay()
print("Rookie after revive:", rookie)


final class TeleportPod {
    let id: String
    var chargeLevel: Int
    var occupant: CrewSnapshot?

    // классы не получают автоматический memberwise initializer
    init(id: String, chargeLevel: Int) {
        self.id = id
        self.chargeLevel = chargeLevel
        self.occupant = nil
    }

    func load(_ crew: CrewSnapshot) -> Bool {
        if occupant != nil || chargeLevel < 20 {
            return false
        }
        occupant = crew
        return true
    }

    func fire() -> CrewSnapshot? {
        guard let transportedCrew = occupant else {
            return nil
        }

        chargeLevel -= 20
        occupant = nil
        return transportedCrew
    }

    deinit {
        print("TeleportPod \(id) deinitialized")
    }
}

let teleportPod = TeleportPod(id: "P-1", chargeLevel: 100)

if let timur = crewRoster.first(where: { $0.name == "Timur" }) {
    print("Load Timur:", teleportPod.load(timur), "charge:", teleportPod.chargeLevel)
    print("Fire Timur:", String(describing: teleportPod.fire()), "charge:", teleportPod.chargeLevel)
}

if let dana = crewRoster.first(where: { $0.name == "Dana" }) {
    print("Load Dana:", teleportPod.load(dana), "charge:", teleportPod.chargeLevel)
    print("Fire Dana:", String(describing: teleportPod.fire()), "charge:", teleportPod.chargeLevel)
}

if let nurlan = crewRoster.first(where: { $0.name == "Nurlan" }) {
    print("Load Nurlan:", teleportPod.load(nurlan), "charge:", teleportPod.chargeLevel)
    print("Fire Nurlan:", String(describing: teleportPod.fire()), "charge:", teleportPod.chargeLevel)
}

print("Fire empty pod:", String(describing: teleportPod.fire()), "charge:", teleportPod.chargeLevel)
let C = teleportPod.chargeLevel

// присваивание класса копирует ссылку а присваивание структуры копирует значение
let secondPodReference = teleportPod
secondPodReference.chargeLevel = 35
print("Class reference test, first:", teleportPod.chargeLevel)
print("Class reference test, second:", secondPodReference.chargeLevel)

var firstCrewValue = crewRoster[0]
var secondCrewValue = firstCrewValue
secondCrewValue.oxygen = 1
print("Struct value test, first:", firstCrewValue.oxygen)
print("Struct value test, second:", secondCrewValue.oxygen)


final class Station {
    let callSign: String

    var hullIntegrity: Int {
        willSet {
            print("Hull integrity: \(hullIntegrity) -> \(newValue)")
        }
        didSet {
            if hullIntegrity > 100 {
                hullIntegrity = 100
            } else if hullIntegrity < 0 {
                hullIntegrity = 0
            }
        }
    }

    var oxygenByDeck: [Deck: Int]

    lazy var fullDiagnostics: String = {
        print("Running full scan...")
        return "\(self.callSign): hull \(self.hullIntegrity), oxygen \(self.totalOxygen)"
    }()

    var totalOxygen: Int {
        var total = 0
        for oxygen in oxygenByDeck.values {
            total += oxygen
        }
        return total
    }

    var averageOxygen: Int {
        get {
            if oxygenByDeck.isEmpty {
                return 0
            }
            return totalOxygen / oxygenByDeck.count
        }
        set {
            var decks: [Deck] = []
            for deck in oxygenByDeck.keys {
                decks.append(deck)
            }
            for deck in decks {
                oxygenByDeck[deck] = newValue
            }
        }
    }

    init(callSign: String, hullIntegrity: Int, readings: [(deck: String, oxygen: Int)]) {
        self.callSign = callSign
        self.hullIntegrity = min(max(hullIntegrity, 0), 100)

        var oxygenValues: [Deck: Int] = [:]
        for reading in readings {
            guard let deck = Deck(rawValue: reading.deck) else {
                print("Skipped unknown deck reading: \(reading.deck)")
                continue
            }
            oxygenValues[deck] = reading.oxygen
        }
        self.oxygenByDeck = oxygenValues
    }
}

let station = Station(callSign: "ALMA-7", hullIntegrity: 84, readings: deckReadings)
let B = station.averageOxygen
print("Station total oxygen:", station.totalOxygen)
print("Station starting average:", B)

print("Diagnostics first access:", station.fullDiagnostics)
print("Diagnostics second access:", station.fullDiagnostics)

let quietStation = Station(callSign: "QUIET", hullIntegrity: 100, readings: [])
print("Quiet station created; its lazy diagnostics were not requested:", quietStation.callSign)

station.averageOxygen = 60
print("Average setter test:", station.averageOxygen)
print("Total after average setter:", station.totalOxygen)

station.hullIntegrity = 130
print("Clamped hull after 130:", station.hullIntegrity)
station.hullIntegrity = -40
print("Clamped hull after -40:", station.hullIntegrity)
station.hullIntegrity = 55
print("Hull after 55:", station.hullIntegrity)
// изменение свойства внутри didset не запускает observers повторно

// отчет один
// автор ожидал уменьшение кислорода у элементов массива
// цикл создает локальную копию структуры поэтому массив не меняется
// исправление изменять элементы массива по индексу
var reportRoster = crewRoster
for index in reportRoster.indices {
    reportRoster[index].oxygen -= 10
}
print("Report 1 fixed, first oxygen:", reportRoster[0].oxygen)

// отчет два
// автор ожидал два независимых объекта
// обе константы указывают на один объект класса поэтому первое значение тоже становится нулем
// исправление создать второй объект
let reportPodA = TeleportPod(id: "A", chargeLevel: 100)
let reportPodB = TeleportPod(id: "A-copy", chargeLevel: reportPodA.chargeLevel)
reportPodB.chargeLevel = 0
print("Report 2 fixed pod A:", reportPodA.chargeLevel)
print("Report 2 fixed pod B:", reportPodB.chargeLevel)

// отчет три
// метод структуры меняет свойство поэтому без mutating код не компилируется
struct Logbook {
    var entries: [String] = []

    mutating func add(_ entry: String) {
        entries.append(entry)
    }
}

var logbook = Logbook()
logbook.add("Teleporter online")
logbook.add("Transfer complete")
print("Report 3 fixed:", logbook.entries)

// отчет четыре
// let запрещает менять все значение структуры
// для класса let запрещает менять ссылку но свойства объекта менять можно
// исправление объявить структуру через var
var reportSnapshot = CrewSnapshot.rookie(named: "Dana")
reportSnapshot.oxygen = 40
let reportPod = TeleportPod(id: "B", chargeLevel: 50)
reportPod.chargeLevel = 10
print("Report 4 struct:", reportSnapshot.oxygen)
print("Report 4 class:", reportPod.chargeLevel)


internal final class FlightRecorder {
    // private запрещает прямой доступ снаружи типа
    private var entries: [String] = []

    // private setter разрешает чтение но запрещает запись снаружи
    private(set) var isSealed = false

    // internal разрешает доступ внутри текущего модуля
    internal var entryCount: Int {
        entries.count
    }

    // internal открывает только вычисляемое представление записей
    internal var transcript: String {
        var result = ""
        for entry in entries {
            if !result.isEmpty {
                result += " | "
            }
            result += entry
        }
        return result
    }

    // internal разрешает добавление через метод с проверкой состояния
    @discardableResult
    internal func add(_ entry: String) -> Bool {
        if isSealed {
            return false
        }
        entries.append(entry)
        return true
    }

    // internal разрешает запечатать журнал но не позволяет отменить это
    internal func seal() {
        isSealed = true
    }

    // fileprivate разрешает доступ только внутри этого файла
    fileprivate func auditEntries() -> [String] {
        entries
    }
}

func auditTranscript(of recorder: FlightRecorder) -> String {
    var result = "AUDIT: "
    let entries = recorder.auditEntries()
    for entry in entries {
        if result != "AUDIT: " {
            result += " -> "
        }
        result += entry
    }
    return result
}

let recorder = FlightRecorder()
print("Recorder add 1:", recorder.add("Power restored"))
print("Recorder add 2:", recorder.add("Pod tested"))
print("Recorder count:", recorder.entryCount)
print("Recorder transcript:", recorder.transcript)
print(auditTranscript(of: recorder))
recorder.seal()
print("Add after seal:", recorder.add("Rewrite history"))
print("Recorder sealed:", recorder.isSealed)

// recorder.entries.removeAll()
// ошибка entries недоступен из за private
// recorder.isSealed = false
// ошибка setter свойства issealed недоступен

let D = AlarmLevel.level(forTotalMass: A).rawValue
let integrityCode = "\(A)-\(B)-\(C)-\(D)"
print("INTEGRITY CODE: \(integrityCode)")


var retainedPod: TeleportPod? = nil
do {
    let blockPod = TeleportPod(id: "BLOCK", chargeLevel: 50)
    retainedPod = blockPod
    print("Inside do block:", blockPod.id)
}
print("After do block, second reference still exists:", retainedPod?.id ?? "none")
retainedPod = nil
// deinit вызывается после удаления последней сильной ссылки

func referencesSamePod(_ first: TeleportPod, _ second: TeleportPod) -> Bool {
    first === second
}

let identityPod = TeleportPod(id: "IDENTITY", chargeLevel: 50)
let identityAlias = identityPod
let equalLookingPod = TeleportPod(id: "IDENTITY", chargeLevel: 50)
print("Identity test 1:", referencesSamePod(identityPod, identityAlias))
print("Identity test 2:", referencesSamePod(identityPod, equalLookingPod))


/*
ответ один
структура получает memberwise initializer автоматически
класс не получает такой initializer поэтому ему нужен явный init

ответ два
mutating разрешает методу структуры менять свойства или весь self
методы класса работают через ссылку поэтому mutating не нужен

ответ три
для структуры let фиксирует все значение
для класса let фиксирует ссылку но изменяемые свойства объекта менять можно

ответ четыре
lazy свойство должно быть var потому что значение записывается при первом обращении
lazy меняет поведение когда создание значения имеет побочный эффект

ответ пять
private скрыл бы helper от свободной функции
fileprivate разрешает доступ свободной функции в этом файле

бонус
deinit вызывается после удаления последней сильной ссылки
identity работает только со ссылками классов
структура не имеет identity объекта
*/
