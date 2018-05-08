import Foundation

enum RetrievalError: Error {
    case badRequest
    case invalidData
    case serverError
    case readError
    case unknownError
}

protocol DataRetrieving {
    associatedtype T

    func get(from url: URL,
             decoding strategy: DecodingStrategy,
             onComplete: @escaping (Result<T, RetrievalError>) -> Void)
}

struct AnyDataRetrievable<T>: DataRetrieving {
    private var _get: (URL, DecodingStrategy, @escaping (Result<T, RetrievalError>) -> Void) -> Void

    init<Instance: DataRetrieving>(_ concrete: Instance)
        where Instance.T == T {
            self._get = { url, strategy, onComplete in
                concrete.get(from: url, decoding: strategy, onComplete: onComplete)
            }
    }

    func get(from url: URL,
             decoding strategy: DecodingStrategy,
             onComplete: @escaping (Result<T, RetrievalError>) -> Void) {
        _get(url, strategy, onComplete)
    }
}
