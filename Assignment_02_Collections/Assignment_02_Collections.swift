let fruits = ["apple", "banana", "orange", "pear", "mango"]
print("Third fruit:", fruits[2])

var favoriteNumbers: Set<Int> = [3, 7, 12]
favoriteNumbers.insert(21)
print("Updated favorite numbers:", favoriteNumbers)

let languageReleaseYears = [
    "Swift": 2014,
    "Python": 1991,
    "Java": 1995
]
print("Swift release year:", languageReleaseYears["Swift", default: 0])

var colors = ["red", "green", "blue", "yellow"]
colors[1] = "purple"
print("Updated colors:", colors)

let firstNumbers: Set<Int> = [1, 2, 3, 4]
let secondNumbers: Set<Int> = [3, 4, 5, 6]
let commonNumbers = firstNumbers.intersection(secondNumbers)
print("Intersection:", commonNumbers)

var studentScores = [
    "Dana": 82,
    "Timur": 75,
    "Tokha": 91
]
studentScores.updateValue(95, forKey: "Dana")
print("Updated scores:", studentScores)

let firstFruits = ["apple", "banana"]
let secondFruits = ["cherry", "date"]
let allFruits = firstFruits + secondFruits
print("Merged array:", allFruits)

var countryPopulations = [
    "Kazakhstan": 20_000_000,
    "Japan": 123_000_000,
    "Canada": 41_000_000
]
countryPopulations["Australia"] = 27_000_000
print("Updated populations:", countryPopulations)

let firstAnimals: Set<String> = ["cat", "dog"]
let secondAnimals: Set<String> = ["dog", "mouse"]
let unitedAnimals = firstAnimals.union(secondAnimals)
let finalAnimals = unitedAnimals.subtracting(secondAnimals)
print("Final set:", finalAnimals)

let studentGrades = [
    "Dana": [85, 92, 88],
    "Timur": [78, 81, 90],
    "Tokha": [95, 94, 97]
]
let danasGrades = studentGrades["Dana", default: []]
print("Dana's second grade:", danasGrades[1])
