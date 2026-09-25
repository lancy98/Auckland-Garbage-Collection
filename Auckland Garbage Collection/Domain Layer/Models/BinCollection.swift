import Foundation

struct BinCollection: Decodable, Identifiable, Sendable {
    enum Kind: String, Decodable, Sendable {
        case rubbish
        case recycling
        case foodScraps

        var title: String {
            switch self {
            case .rubbish: String(localized: "Rubbish")
            case .recycling: String(localized: "Recycling")
            case .foodScraps: String(localized: "Food scraps")
            }
        }

        var symbol: String {
            switch self {
            case .rubbish: "trash"
            case .recycling: "arrow.3.trianglepath"
            case .foodScraps: "leaf"
            }
        }
    }

    let kind: Kind
    let dateText: String
    let date: String
    let collectionDate: Date

    var id: String { "\(kind.rawValue)-\(date)" }

    var formattedDate: String {
        collectionDate.formatted(
            Date.FormatStyle(
                date: .complete,
                time: .omitted,
                timeZone: Self.aucklandTimeZone
            )
        )
    }

    private static var aucklandTimeZone: TimeZone {
        TimeZone(identifier: "Pacific/Auckland") ?? .gmt
    }

    private enum CodingKeys: String, CodingKey {
        case kind = "type"
        case dateText
        case date
    }

    init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        kind = try values.decode(Kind.self, forKey: .kind)
        dateText = try values.decode(String.self, forKey: .dateText)
        date = try values.decode(String.self, forKey: .date)

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = Self.aucklandTimeZone
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.isLenient = false

        guard let parsedDate = formatter.date(from: date),
              formatter.string(from: parsedDate) == date else {
            throw DecodingError.dataCorruptedError(
                forKey: .date,
                in: values,
                debugDescription: "Expected a valid collection date in yyyy-MM-dd format."
            )
        }
        collectionDate = parsedDate
    }
}
