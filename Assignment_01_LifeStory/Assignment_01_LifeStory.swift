let firstName: String = "Alimzhan"
let lastName: String = "Sagynayev"
let birthYear: Int = 2006
let currentYear: Int = 2026
let isStudent: Bool = true
let height: Double = 1.83

let hobby: String = "going to the gym"
let numberOfHobbies: Int = 1
let favoriteNumber: Int = 7
let isHobbyCreative: Bool = false

let futureGoals: String = "I want to become a Chief AI Officer."

let age = currentYear - birthYear

var studentStatus = "I am not currently a student."
if isStudent {
    studentStatus = "I am currently a student."
}

var hobbyType = "not a creative hobby"
if isHobbyCreative {
    hobbyType = "a creative hobby"
}

var hobbyWord = "hobbies"
if numberOfHobbies == 1 {
    hobbyWord = "hobby"
}

let lifeStory = """
My name is \(firstName) \(lastName). I am \(age) years old and I was born in \(birthYear).
\(studentStatus) My height is \(height) meters.
I enjoy \(hobby), which is \(hobbyType). I have \(numberOfHobbies) \(hobbyWord) in total, and my favorite number is \(favoriteNumber).
In the future, \(futureGoals)
"""

print(lifeStory)
