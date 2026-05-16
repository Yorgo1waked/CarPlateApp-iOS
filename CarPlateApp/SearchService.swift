import Foundation
import CryptoKit

struct SearchService {

    private let url = URL(string: "https://www.carplatelebanon.com/")!
    private let nextAction = "40c6096741dceb5df9e3b3b4898a95d597f5b59a4d"

    func search(plateNumber: String, symbol: String?) async -> SearchResult {
        do {
            let body = try buildBody(plateNumber: plateNumber, symbol: symbol)
            let data = try await performRequest(body: body)
            return try parseResponse(data)
        } catch {
            return SearchResult(entries: [], count: 0, error: error.localizedDescription)
        }
    }

    private func buildBody(plateNumber: String, symbol: String?) throws -> Data {
        let ts = Int64(Date().timeIntervalSince1970 * 1000)
        let tsStr = String(ts)
        let entropy = String(sha256Hex(tsStr).prefix(6))

        var dict: [String: Any] = [
            "plateNumber": plateNumber,
            "limit": 50,
            "timestamp": ts,
            "entropy": entropy,
        ]
        if let s = symbol { dict["symbol"] = s }

        let payload = try JSONSerialization.data(withJSONObject: dict)
        let payloadStr = String(data: payload, encoding: .utf8)!
        return try JSONSerialization.data(withJSONObject: [payloadStr])
    }

    private func performRequest(body: Data) async throws -> Data {
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue(nextAction, forHTTPHeaderField: "Next-Action")
        req.setValue("text/plain;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        req.setValue("*/*", forHTTPHeaderField: "Accept")
        req.setValue("https://www.carplatelebanon.com", forHTTPHeaderField: "Origin")
        req.setValue("https://www.carplatelebanon.com/", forHTTPHeaderField: "Referer")
        req.setValue(
            "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Mobile/15E148 Safari/604.1",
            forHTTPHeaderField: "User-Agent"
        )
        req.httpBody = body
        req.timeoutInterval = 15

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else {
            throw SearchError.invalidResponse
        }
        guard http.statusCode == 200 else {
            throw SearchError.serverError(http.statusCode)
        }
        return data
    }

    private func sha256Hex(_ s: String) -> String {
        SHA256.hash(data: Data(s.utf8)).map { String(format: "%02x", $0) }.joined()
    }

    private func parseResponse(_ data: Data) throws -> SearchResult {
        guard let raw = String(data: data, encoding: .utf8) else {
            throw SearchError.parse("Response not UTF-8")
        }

        let linePattern = try NSRegularExpression(pattern: "^2:T[0-9a-fA-F]+,(.+)$")

        for line in raw.components(separatedBy: "\n") {
            let t = line.trimmingCharacters(in: .whitespaces)

            var b64: String?

            if let m = linePattern.firstMatch(in: t, range: NSRange(t.startIndex..., in: t)) {
                let captured = String(t[Range(m.range(at: 1), in: t)!])
                if let end = captured.range(of: "1:\"") {
                    b64 = String(captured[..<end.lowerBound]).trimmingCharacters(in: .whitespaces)
                } else {
                    b64 = captured.trimmingCharacters(in: .whitespaces)
                }
            } else if t.hasPrefix("1:"), !t.hasPrefix("1:E"), !t.hasPrefix("1:\"$2") {
                b64 = String(t.dropFirst(2)).trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            }

            guard let b64Str = b64 else { continue }

            do {
                let d1 = try decodeB64(b64Str)
                guard let outer = try JSONSerialization.jsonObject(with: d1) as? [String: Any],
                      let dVal = outer["d"] as? String
                else { continue }

                let d2 = try decodeB64(dVal)
                guard let d2s = String(data: d2, encoding: .utf8) else { continue }
                let d3 = try decodeB64(d2s)

                guard let json = try JSONSerialization.jsonObject(with: d3) as? [String: Any] else { continue }
                let success = json["success"] as? Bool ?? false
                if !success {
                    return SearchResult(entries: [], count: 0, error: json["error"] as? String ?? "Search failed")
                }
                let count = json["count"] as? Int ?? 0
                guard let arr = json["data"] as? [[String: Any]] else {
                    return SearchResult(entries: [], count: count, error: nil)
                }
                let jData = try JSONSerialization.data(withJSONObject: arr)
                let entries = try JSONDecoder().decode([PlateEntry].self, from: jData)
                return SearchResult(entries: entries, count: count, error: nil)
            } catch {
                continue
            }
        }
        throw SearchError.parse("No valid data line found")
    }

    private func decodeB64(_ s: String) throws -> Data {
        let cleaned = s.replacingOccurrences(of: "\\s", with: "", options: .regularExpression)
        let rem = cleaned.count % 4
        let padded = rem == 0 ? cleaned : cleaned + String(repeating: "=", count: 4 - rem)
        guard let data = Data(base64Encoded: padded) else {
            throw SearchError.parse("Base64 decode failed")
        }
        return data
    }

    enum SearchError: LocalizedError {
        case invalidResponse
        case serverError(Int)
        case parse(String)

        var errorDescription: String? {
            switch self {
            case .invalidResponse: return "Network error: Invalid response"
            case .serverError(let c): return "Server error: \(c)"
            case .parse(let m): return m
            }
        }
    }
}
