import SwiftUI
import UIKit

extension Color {
    static let appPrimary = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.161, green: 0.690, blue: 0.949, alpha: 1)
            : UIColor(red: 0.055, green: 0.647, blue: 0.914, alpha: 1)
    })
    static let appOnSurface = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.925, green: 0.941, blue: 0.969, alpha: 1)
            : UIColor(red: 0.059, green: 0.090, blue: 0.165, alpha: 1)
    })
    static let appTextMuted = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.612, green: 0.651, blue: 0.702, alpha: 1)
            : UIColor(red: 0.392, green: 0.455, blue: 0.471, alpha: 1)
    })
    static let appBackground = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.071, green: 0.082, blue: 0.122, alpha: 1)
            : UIColor(red: 0.980, green: 0.984, blue: 0.988, alpha: 1)
    })
    static let appCardBg = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.129, green: 0.141, blue: 0.184, alpha: 1)
            : UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1)
    })
    static let appBorderColor = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.278, green: 0.302, blue: 0.361, alpha: 1)
            : UIColor(red: 0.886, green: 0.910, blue: 0.941, alpha: 1)
    })
    static let appError = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.957, green: 0.353, blue: 0.353, alpha: 1)
            : UIColor(red: 0.937, green: 0.267, blue: 0.267, alpha: 1)
    })
    static let appSuccess = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.149, green: 0.776, blue: 0.561, alpha: 1)
            : UIColor(red: 0.063, green: 0.725, blue: 0.506, alpha: 1)
    })
    static let appWarning = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.984, green: 0.702, blue: 0.173, alpha: 1)
            : UIColor(red: 0.961, green: 0.620, blue: 0.043, alpha: 1)
    })
}

enum AppTheme: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
}

struct PlateEntry: Codable, Identifiable {
    let id = UUID()
    let plateNumber: String
    let symbol: String
    let brand: String
    let model: String
    let color: String
    let year: String
    let usage: String
    let firstName: String
    let lastName: String
    let motherName: String
    let phone: String
    let address: String
    let chassis: String
    let engine: String
    let acquisition: String
    let firstReg: String
    let outOfService: String

    enum CodingKeys: String, CodingKey {
        case plateNumber = "ActualNB"
        case symbol = "CodeDesc"
        case brand = "Brand"
        case model = "Model"
        case color = "CouleurDesc"
        case year = "PRODDATE"
        case usage = "UtilisDesc"
        case firstName = "Prenom"
        case lastName = "Nom"
        case motherName = "NomMere"
        case phone = "TelProp"
        case address = "Addresse"
        case chassis = "Chassis"
        case engine = "Moteur"
        case acquisition = "dateaquisition"
        case firstReg = "PreMiseCirc"
        case outOfService = "HORSSERVICE"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        plateNumber = try c.decodeIfPresent(String.self, forKey: .plateNumber) ?? ""
        symbol = try c.decodeIfPresent(String.self, forKey: .symbol) ?? ""
        brand = try c.decodeIfPresent(String.self, forKey: .brand) ?? ""
        model = try c.decodeIfPresent(String.self, forKey: .model) ?? ""
        color = try c.decodeIfPresent(String.self, forKey: .color) ?? ""
        year = try c.decodeIfPresent(String.self, forKey: .year) ?? ""
        usage = try c.decodeIfPresent(String.self, forKey: .usage) ?? ""
        firstName = try c.decodeIfPresent(String.self, forKey: .firstName) ?? ""
        lastName = try c.decodeIfPresent(String.self, forKey: .lastName) ?? ""
        motherName = try c.decodeIfPresent(String.self, forKey: .motherName) ?? ""
        phone = try c.decodeIfPresent(String.self, forKey: .phone) ?? ""
        address = try c.decodeIfPresent(String.self, forKey: .address) ?? ""
        chassis = try c.decodeIfPresent(String.self, forKey: .chassis) ?? ""
        engine = try c.decodeIfPresent(String.self, forKey: .engine) ?? ""
        acquisition = try c.decodeIfPresent(String.self, forKey: .acquisition) ?? ""
        firstReg = try c.decodeIfPresent(String.self, forKey: .firstReg) ?? ""
        outOfService = try c.decodeIfPresent(String.self, forKey: .outOfService) ?? ""
    }

    var ownerName: String {
        [firstName.isEmpty ? nil : firstName, lastName.isEmpty ? nil : lastName]
            .compactMap { $0 }.joined(separator: " ")
    }

    var carModel: String {
        [brand.isEmpty ? nil : brand, model.isEmpty ? nil : model]
            .compactMap { $0 }.joined(separator: " ")
    }

    var statusText: String {
        switch outOfService {
        case "0": return "Active"
        case "1": return "Out of Service"
        case "2": return "Scrapped"
        default: return outOfService
        }
    }

    var statusColor: Color {
        switch outOfService {
        case "0": return .appSuccess
        case "1": return .appWarning
        case "2": return .appError
        default: return .appTextMuted
        }
    }

    var hasOwnerInfo: Bool {
        !ownerName.isEmpty || !phone.isEmpty || !address.isEmpty
    }
}

struct SearchResult {
    let entries: [PlateEntry]
    let count: Int
    let error: String?
}
