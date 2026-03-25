import Foundation

enum NetworkError: Error, Equatable {
    case invalidURL
    case invalidResponse
    case httpStatus(code: Int)
    case decodingFailed
    case notConnected
    case timedOut
    case hostUnreachable
    case secureConnectionFailed
    case networkUnavailable
    case cancelled

    var userMessage: String {
        switch self {
        case .invalidURL:
            return "Некорректный адрес запроса."
        case .invalidResponse:
            return "Сервер вернул неожиданный ответ."
        case .httpStatus(let code):
            return "Ошибка сервера (код \(code))."
        case .decodingFailed:
            return "Не удалось разобрать данные."
        case .notConnected:
            return "Нет подключения к интернету."
        case .timedOut:
            return "Превышено время ожидания ответа сервера."
        case .hostUnreachable:
            return "Не удаётся достучаться до сервера (DNS или блокировка)."
        case .secureConnectionFailed:
            return "Ошибка защищённого соединения (TLS/сертификат)."
        case .networkUnavailable:
            return "Сеть недоступна или запрос прерван."
        case .cancelled:
            return "Загрузка отменена."
        }
    }

    static func map(_ error: Error) -> NetworkError {
        if error is CancellationError || (error as? URLError)?.code == .cancelled {
            return .cancelled
        }
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .dataNotAllowed:
                return .notConnected
            case .networkConnectionLost:
                return .networkUnavailable
            case .timedOut:
                return .timedOut
            case .cannotFindHost, .dnsLookupFailed, .cannotConnectToHost:
                return .hostUnreachable
            case .secureConnectionFailed, .serverCertificateUntrusted, .serverCertificateHasBadDate,
                 .serverCertificateHasUnknownRoot, .clientCertificateRejected, .clientCertificateRequired:
                return .secureConnectionFailed
            default:
                return .networkUnavailable
            }
        }
        if let net = error as? NetworkError {
            return net
        }
        return .networkUnavailable
    }
}
