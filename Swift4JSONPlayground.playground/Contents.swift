
import Foundation

//: Basic example

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

//: Optional attribute

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

//: Different name in JSON and struct

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

//: Different type in JSON and struct

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

//: Nested JSON

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

//: Different date formats
jsonString = """
{
    "date_short": "10/03/17",
    "date_medium": "10/03/17 10:28",
    "date_long": "2017-10-03T10:28:07.231Z"
}
"""

incomingData = jsonString.data(using: .utf8)!

struct MrDate: Codable {
    let dateShort: Date
    let dateMedium: Date
    let dateLong: Date

    var description: String {
        return "dateShort:\(dateShort), dateLong:\(dateMedium), dateLong:\(dateLong)"
    }

    enum CodingKeys: String, CodingKey {
        case dateShort = "date_short"
        case dateMedium = "date_medium"
        case dateLong = "date_long"
    }
}

enum DateFormat: String {
    case short = "MM/dd/yy"
    case medium = "MM/dd/yy hh:mm"
    case long = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
}
extension DateFormatter {
    convenience init(format: DateFormat) {
        self.init()

        self.dateFormat = format.rawValue
        self.locale = Locale(identifier: "en_US_POSIX")
        self.timeZone = TimeZone(abbreviation: "GMT")
    }
    static var short: DateFormatter {
        return DateFormatter(format: .short)
    }
    static var medium: DateFormatter {
        return DateFormatter(format: .medium)
    }
    static var long: DateFormatter {
        return DateFormatter(format: .long)
    }
}

let myDecoder: JSONDecoder = {
    let decoder = JSONDecoder()

    decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
        let container = try decoder.singleValueContainer()
        let dateToDecode = try container.decode(String.self)

        var date: Date?

        if let d = DateFormatter.short.date(from: dateToDecode) {
            date = d
        } else if let d = DateFormatter.medium.date(from: dateToDecode) {
            date = d
        } else if let d = DateFormatter.long.date(from: dateToDecode) {
            date = d
        }

        guard let d = date else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateToDecode)")
        }

        return d
    })
    return decoder
}()

do {
    let mrDate = try myDecoder.decode(MrDate.self, from: incomingData)
    print(mrDate.description)
} catch let error {
    print("error happened: \(error)")
}
