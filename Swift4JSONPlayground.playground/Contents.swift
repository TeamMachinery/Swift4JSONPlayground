//: Playground - noun: a place where people can play

import Foundation

//basic example

var jsonString = "{ \"id\": 15, \"name\": \"fifteen\" }"

var incomingData = jsonString.data(using: .utf8)!

struct MrNumber: Codable {
    let id: Int
    let name: String

    var description: String {
        return "id:\(id), name:\(name)"
    }
}

let decoder = JSONDecoder()

do {
    let mrnumber = try decoder.decode(MrNumber.self, from: incomingData)
    print(mrnumber.description)
} catch let error {
    print("error happened: \(error)")
}

//optional attribute

jsonString = "{ \"id\": 15 }"

incomingData = jsonString.data(using: .utf8)!

struct MrNumberOptional: Codable {
    let id: Int
    let name: String?

    var description: String {
        if let name = name {
            return "id:\(id), name:\(name)"
        } else {
            return "id:\(id)"
        }
    }
}

do {
    let mrnumber = try decoder.decode(MrNumberOptional.self, from: incomingData)
    print(mrnumber.description)
} catch let error {
    print("error happened: \(error)")
}

//different name in JSON and struct

jsonString = "{ \"number_id\": 15, \"name\": \"fifteen\" }"

incomingData = jsonString.data(using: .utf8)!

struct MrNumberDifferentName: Codable {

    enum CodingKeys: String, CodingKey {
        case id = "number_id"
        case name
    }

    let id: Int
    let name: String

    var description: String {
        return "id:\(id), name:\(name)"
    }
}

do {
    let mrnumber = try decoder.decode(MrNumberDifferentName.self, from: incomingData)
    print(mrnumber.description)
} catch let error {
    print("error happened: \(error)")
}

//different type in JSON and struct

jsonString = "{ \"number_id\": \"15\", \"name\": \"fifteen\" }"

incomingData = jsonString.data(using: .utf8)!

struct MrNumberString: Codable {

    enum CodingKeys: String, CodingKey {
        case idString = "number_id"
        case name
    }

    let idString: String
    var id: Int {
        return Int(idString)!
    }
    let name: String

    var description: String {
        return "id:\(id), name:\(name)"
    }
}

do {
    let mrnumber = try decoder.decode(MrNumberString.self, from: incomingData)
    print(mrnumber.description)
} catch let error {
    print("error happened: \(error)")
}

//nested JSON

jsonString = "{ \"id\": 15, \"name\": \"fifteen\", \"children\": [{\"id\": 16, \"name\": \"sixteen\"}, {\"id\": 17, \"name\": \"seventeen\"}] }"

incomingData = jsonString.data(using: .utf8)!

struct MrNumberNested: Codable {


    var id: Int
    let name: String
    let children: [MrNumberNested]?

    var description: String {
        if let children = children {
            return "id:\(id), name:\(name), children:\(children.map { $0.description })"
        } else {
            return "id:\(id), name:\(name)"
        }
    }
}

do {
    let mrnumber = try decoder.decode(MrNumberNested.self, from: incomingData)
    print(mrnumber.description)
} catch let error {
    print("error happened: \(error)")
}


